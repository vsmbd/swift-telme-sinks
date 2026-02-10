//
//  BatchPolicy.swift
//  TelmeSinks
//
//  Created by vsmbd on 10/02/26.
//

import Foundation

// MARK: - BatchPolicy

/// When to send: flush when buffer count reaches this many records.
public struct BatchPolicy: Sendable {
	// MARK: + Public scope

	public let maxRecordCount: Int

	public init(maxRecordCount: Int = 100) {
		self.maxRecordCount = max(1, maxRecordCount)
	}
}
