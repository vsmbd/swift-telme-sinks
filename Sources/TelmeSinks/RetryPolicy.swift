//
//  RetryPolicy.swift
//  TelmeSinks
//
//  Created by vsmbd on 10/02/26.
//

import Foundation

// MARK: - RetryPolicy

/// Bounded retry: exponential backoff with cap.
public struct RetryPolicy: Sendable {
	// MARK: + Public scope

	public var maxAttempts: Int
	public var initialDelay: TimeInterval
	public var maxDelay: TimeInterval
	public var multiplier: Double

	public init(
		maxAttempts: Int = 3,
		initialDelay: TimeInterval = 1.0,
		maxDelay: TimeInterval = 30.0,
		multiplier: Double = 2.0
	) {
		self.maxAttempts = max(1, maxAttempts)
		self.initialDelay = initialDelay
		self.maxDelay = maxDelay
		self.multiplier = multiplier
	}
}
