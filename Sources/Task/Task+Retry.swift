//
//  Task+Retry.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

public func retry<E, A>(_ times: UInt, _ task: Task<E, A>) -> Task<E, A> {
	guard times > 0 else {
		return task
	}

	return task <|> retry(times-1, task)
}

public func retry<E, A>(times: UInt, modify: (Task<E, A>) -> Task<E, A>, _ task: Task<E, A>) -> Task<E, A> {
	guard times > 0 else {
		return task
	}

	return task <|> modify(retry(times: times-1, modify: modify, task))
}

public func retry<E, A>(times: UInt, delay: TimeInterval, _ task: Task<E, A>) -> Task<E, A> {
	return retry(times: times, modify: { task in
		return delayed(delay, task)
	}, task)
}

