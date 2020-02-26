//
//  Either+Applicative.swift
//  TYRSharedUtils
//
//  Created by José Manuel Sánchez Peñarroja on 1/1/19.
//

import Foundation

public func <*><E, A, B>(lhs: Either<E, (A) -> B>, rhs: Either<E, A>) -> Either<E, B> {
	switch (lhs, rhs) {
		case let (.right(f), .right(a)):
			return .right(f(a))
		case let (.left(e), _):
			return .left(e)
		case let (_, .left(e)):
			return .left(e)
	}
}

public func pure<E, A>(_ x: A) -> Either<E, A> {
	return .right(x)
}

