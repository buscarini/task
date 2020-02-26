//
//  Either+Traversable.swift
//  TYRSharedUtils
//
//  Created by José Manuel Sánchez Peñarroja on 1/1/19.
//

import Foundation

public func traverseLeft<A, B, C>(_ either: Either<A, B>, _ f: @escaping (A) -> C?) -> Either<C, B>? {
	
	let inside = either.mapLeft(f)
	
	switch inside {
	case let .left(.some(left)):
		return .left(left)
	case .left(nil):
		return nil
	case let .right(right):
		return .right(right)
	}
}

public extension Array {
	func traverse<E, B>(_ f: @escaping (Element) -> Either<E, B>) -> Either<E, [B]> {
		let initial = Either<E, [B]>.right([])
		return self.reduce(initial) { (acc: Either<E, [B]>, item: Element) in
			return pure(append) <*> acc <*> f(item)
		}
	}
	
	private func append<B>(_ list: [B]) -> (B) -> [B] {
		return { list + [$0] }
	}
	
	func sequence<E, B>() -> Either<E, [B]> where Element == Either<E, B> {
		return self.traverse(id)
	}	
}
