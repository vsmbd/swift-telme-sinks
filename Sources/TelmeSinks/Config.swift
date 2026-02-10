//
//  Config.swift
//  TelmeSinks
//
//  Created by vsmbd on 10/02/26.
//

import Foundation
import HTTPCore
import JSON

// MARK: - ClickHouseTelmeSink.Config

extension ClickHouseTelmeSink {
	/// Configuration for the ClickHouse ingest endpoint and request shape.
	public struct Config: Sendable {
		// MARK: + Public scope

		/// Ingest endpoint URL (e.g. reverse proxy that receives session + records).
		public let endpoint: URL

		/// Request headers (e.g. Authorization). Sink sets Content-Type: application/json when sending.
		public let headers: HTTPHeaders

		/// Top-level "session" object in the JSON body. Passed as-is to the proxy; sink merges send_mono_nanos per batch.
		public let session: [String: JSON]

		public init(
			endpoint: URL,
			headers: HTTPHeaders = [:],
			session: [String: JSON] = [:]
		) {
			self.endpoint = endpoint
			self.headers = headers
			self.session = session
		}
	}
}
