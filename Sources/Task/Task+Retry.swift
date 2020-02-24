//
//  Task+Retry.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

@inlinable
public func retry<E, A>(_ times: UInt, _ task: Task<E, A>) -> Task<E, A> {
	guard times > 0 else {
		return task
	}

	return task <|> retry(times-1, task)
}

@inlinable
public func retry<E, A>(times: UInt, modify: (Task<E, A>) -> Task<E, A>, _ task: Task<E, A>) -> Task<E, A> {
	guard times > 0 else {
		return task
	}

	return task <|> modify(retry(times: times-1, modify: modify, task))
}

@inlinable
public func retry<E, A>(times: UInt, delay: TimeInterval, _ task: Task<E, A>) -> Task<E, A> {
	retry(times: times, modify: { task in
		delayed(delay, task)
	}, task)
}

