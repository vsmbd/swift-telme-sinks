//
//  ClickHouseTelmeSinkTests.swift
//  TelmeSinksTests
//
//  Created by vsmbd on 10/02/26.
//

import Foundation
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
			session: ["app": "test"]
		)
		#expect(config.endpoint == url)
		#expect(config.headers["Authorization"] == "Bearer x")
		#expect(config.session["app"] == "test")
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
