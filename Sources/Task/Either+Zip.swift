//
//  Either+Zip.swift
//  TYRSharedUtils
//
//  Created by José Manuel Sánchez Peñarroja on 1/1/19.
//

import Foundation

public func zip<T, U, V>(_ left: Either<T, U>, _ right: Either<T, V>) -> Either<T, (U, V)> {
	switch (left, right) {
	case let (.left(l), _):
		return .left(l)
	case let (_, .left(l)):
		return .left(l)
	case let (.right(l), .right(r)):
		return .right((l, r))
	}
}

public func zip<T, U, V, A>(with f: @escaping (U, V) -> A)
	-> (Either<T, U>, Either<T, V>)
	-> Either<T, A> {
	return { left, right in
		return zip(left, right).map(f)
	}
}

public func zip2<T, U, V>(_ left: Either<T, U>, _ right: Either<T, V>) -> Either<T, (U, V)> {
	return zip(left, right)
}

public func zip2<T, U, V, A>(with f: @escaping (U, V) -> A)
	-> (Either<T, U>, Either<T, V>)
	-> Either<T, A> {
	return zip(with: f)
}

public func zip3<E, A, B, C>(
  _ xs: Either<E, A>, _ ys: Either<E, B>, _ zs: Either<E, C>
  ) -> Either<E, (A, B, C)> {

  return zip2(xs, zip2(ys, zs)) // Either<E, (A, (B, C))>
    .map { a, bc in (a, bc.0, bc.1) }
}

func zip3<E, A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> (Either<E, A>, Either<E, B>, Either<E, C>) -> Either<E, D> {
  return { xs, ys, zs in zip3(xs, ys, zs).map(f) }
}
