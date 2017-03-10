//
//  Task+Retry.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

public func retry<A>(_ times: UInt, _ task: Task<A>) -> Task<A> {
	guard times > 0 else {
		return task
	}

	return task <|> retry(times-1, task)
}

public func retryDelayed<A>(times: UInt, delay: TimeInterval, _ task: Task<A>) -> Task<A> {
	guard times > 0 else {
		return task
	}

	return task <|> delayed(delay, retryDelayed(times: times-1, delay: delay, task))
}