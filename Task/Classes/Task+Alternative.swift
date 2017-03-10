//
//  Task+Alternative.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

public func or<A>(_ first: Task<A>, _ second: Task<A>) -> Task<A> {
	return Task<A>({ (reject, resolve) in
		first.fork({ _ in
			second.fork(reject, resolve)
		}, resolve)
	})
}

infix operator <|>: AdditionPrecedence
public func <|><A>(first: Task<A>, second: Task<A>) -> Task<A> {
    return or(first, second)
}

