//
//  ClickHouseTelmeSinkTests.swift
//  TelmeSinksTests
//
//  Created by vsmbd on 10/02/26.
//

import Foundation
import JSON
import TelmeSinks
import Testing

@Suite("ClickHouseTelmeSink")
struct ClickHouseTelmeSinkTests {
	@Test("Config init stores endpoint headers session")
	func configInit() {
		let url = URL(string: "https://ingest.example/session")!
		let config = ClickHouseTelmeSink.Config(
			endpoint: url,
			headers: ["Authorization": "Bearer x"],
			session: JSON.object(["app": JSON.string("test")])
		)

		#expect(config.endpoint == url)
		#expect(config.headers.value(for: "Authorization") == "Bearer x")

		if case .object(let fields) = config.session {
			#expect(fields["app"] == JSON.string("test"))
		} else {
			#expect(Bool(false), "session should be a JSON object")
		}
	}

	@Test("BatchPolicy default maxRecordCount at least 1")
	func batchPolicyDefault() {
		let policy = BatchPolicy(maxRecordCount: 0)
		#expect(policy.maxRecordCount >= 1)
	}

	@Test("RetryPolicy default values")
	func retryPolicyDefault() {
		let policy = RetryPolicy()
		#expect(policy.maxAttempts >= 1)
		#expect(policy.initialDelay >= 0)
		#expect(policy.maxDelay >= 0)
		#expect(policy.multiplier >= 0)
	}
}
