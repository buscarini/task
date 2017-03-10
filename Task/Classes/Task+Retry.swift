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

public func retry<A>(times: UInt, modify: (Task<A>) -> Task<A>, _ task: Task<A>) -> Task<A> {
	guard times > 0 else {
		return task
	}

	return task <|> modify(retry(times: times-1, modify: modify, task))
}

public func retry<A>(times: UInt, delay: TimeInterval, _ task: Task<A>) -> Task<A> {
	return retry(times: times, modify: { task in
		return delayed(delay, task)
	}, task)
}

