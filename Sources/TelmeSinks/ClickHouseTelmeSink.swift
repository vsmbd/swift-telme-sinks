//
//  ClickHouseTelmeSink.swift
//  TelmeSinks
//
//  Created by vsmbd on 10/02/26.
//

import Foundation
import HTTPCore
import JSON
import SwiftCore
import Telme

// MARK: - ClickHouseTelmeSink

/// Batches Telme records and sends them to a reverse-proxy ingest endpoint as JSON (session + records with send_mono_nanos).
/// Buffer access is guarded by a lock; class is @unchecked Sendable to satisfy TelmeRecordSink.
public final class ClickHouseTelmeSink: TelmeRecordSink,
										Entity,
										@unchecked Sendable {
	// MARK: + Private scope

	private enum Key {
		static let session = "session"
		static let records = "records"
		static let sendMonoNanos = "send_mono_nanos"
		static let contentType = "Content-Type"
	}

	private let http: HTTPClient
	private let config: Config
	private let batchPolicy: BatchPolicy
	private let retryPolicy: RetryPolicy
	private var buffer: [TelmeRecord] = []
	private let lock: NSLock = .init()
	private let encoder: JSONEncoder = .init()

	private func appendAndMaybeFlush(_ records: [TelmeRecord]) {
		lock.lock()
		buffer.append(contentsOf: records)

		while buffer.count >= batchPolicy.maxRecordCount {
			let batch = Array(buffer.prefix(batchPolicy.maxRecordCount))
			buffer.removeFirst(batch.count)
			lock.unlock()
			sendBatch(batch, attempt: 1)
			lock.lock()
		}

		lock.unlock()
	}

	private func flushFromBackground() {
		lock.lock()
		let batch = buffer
		buffer = []
		lock.unlock()
		guard batch.isEmpty == false else { return }
		sendBatch(batch, attempt: 1)
	}

	private func sendBatch(
		_ records: [TelmeRecord],
		attempt: Int
	) {
		let sendNanos = MonotonicNanostamp.now.nanoseconds
		guard let bodyData = buildBody(records: records, sendMonoNanos: sendNanos) else { return }

		var headers = config.headers
		headers.setValue("application/json", for: Key.contentType)

		let request = HTTPRequest(
			method: .post,
			url: config.endpoint,
			headers: headers,
			body: bodyData
		)

		_ = http.execute(request, .checkpoint(self)) { [weak self] result in
			guard let self else { return }

			switch result {
			case .success:
				break

			case .failure(let errorInfo):
				if attempt < self.retryPolicy.maxAttempts {
					let delay = self.retryDelay(attempt: attempt)

					DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
						guard let self else { return }

						TaskQueue.background.async(errorInfo.checkpoint.next(self)) { [weak self] _ in
							self?.sendBatch(
								records,
								attempt: attempt + 1
							)
						}
					}
				}
			}
		}
	}

	private func retryDelay(attempt: Int) -> TimeInterval {
		let delay = retryPolicy.initialDelay * pow(
			retryPolicy.multiplier,
			Double(attempt - 1)
		)

		return min(max(delay, 0), retryPolicy.maxDelay)
	}

	private func buildBody(
		records: [TelmeRecord],
		sendMonoNanos: UInt64
	) -> Data? {
		var recordsArray: [JSON] = []

		for record in records {
			guard let recordWithSend = recordJSONAddingSendMonoNanos(
				record,
				sendMonoNanos: sendMonoNanos
			) else { return nil }

			recordsArray.append(recordWithSend)
		}

		var sessionFields = config.session
		sessionFields[Key.sendMonoNanos] = .int(Int(truncatingIfNeeded: sendMonoNanos))
		let sessionJSON: JSON = .object(sessionFields)
		let bodyJSON: JSON = .object([
			Key.session: sessionJSON,
			Key.records: .array(recordsArray)
		])

		return try? bodyJSON.toData(prettyPrinted: false)
	}

	private func recordJSONAddingSendMonoNanos(
		_ record: TelmeRecord,
		sendMonoNanos: UInt64
	) -> JSON? {
		guard let recordJSON = try? JSON.encode(record, encoder: encoder),
			  case .object(var fields) = recordJSON else {
			return nil
		}

		fields[Key.sendMonoNanos] = .int(Int(truncatingIfNeeded: sendMonoNanos))
		return .object(fields)
	}

	// MARK: + Public scope

	public let identifier: UInt64

	public init(
		http: HTTPClient,
		config: Config,
		batchPolicy: BatchPolicy = .init(),
		retryPolicy: RetryPolicy = .init()
	) {
		self.identifier = Self.nextID
		self.http = http
		self.config = config
		self.batchPolicy = batchPolicy
		self.retryPolicy = retryPolicy
	}

	public func sink(_ records: [TelmeRecord]) {
		guard records.isEmpty == false else { return }

		TaskQueue.background.async(.checkpoint(self)) { [weak self] _ in
			self?.appendAndMaybeFlush(records)
		}
	}

	/// Sends whatever is currently in the buffer. Call from the pipeline (e.g. on app lifecycle) to force flush. Work runs on TaskQueue.background.
	public func flush() {
		TaskQueue.background.async(.checkpoint(self)) { [weak self] _ in
			self?.flushFromBackground()
		}
	}
}
