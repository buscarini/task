//
//  Task+Alternative.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation
import NonEmpty

// TODO: Rename to Alt, as Alternative requires an empty function

public func or<E, A>(_ first: Task<E, A>, _ second: Task<E, A>) -> Task<E, A> {
	return Task<E, A>({ (reject, resolve) in
		first.fork({ _ in
			second.fork(reject, resolve)
		}, resolve)
	})
}

infix operator <|>: AdditionPrecedence
public func <|><E, A>(first: Task<E, A>, second: Task<E, A>) -> Task<E, A> {
    return or(first, second)
}

public func firstSuccess<E, A>(_ tasks: NonEmptyArray<Task<E, A>>) -> Task<E, A> {
	return tasks.tail.reduce(tasks.head, { acc, item in
		return acc <|> item
	})
}
