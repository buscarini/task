//
//  Task+Zip.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 31/7/18.
//

import Foundation

@inlinable
public func zip<E, A, B>(_ left: Task<E, A>, _ right: Task<E, B>) -> Task<E, (A, B)> {
	liftA2(Task.of({ a in
		{ b in
			(a, b)
		}
	}), left, right)
}

@inlinable
public func zip<E, A, B, C>(with f: @escaping (A, B) -> C)
	-> (Task<E, A>, Task<E, B>)
	-> Task<E, C> {
	{ left, right in
		zip(left, right).map(f)
	}
}

@inlinable
public func zip2<E, A, B>(_ left: Task<E, A>, _ right: Task<E, B>) -> Task<E, (A, B)> {
	zip(left, right)
}

@inlinable
public func zip2<E, A, B, C>(with f: @escaping (A, B) -> C)
	-> (Task<E, A>, Task<E, B>)
	-> Task<E, C> {
	zip(with: f)
}

@inlinable
public func zip3<E, A, B, C>(
  _ xs: Task<E, A>, _ ys: Task<E, B>, _ zs: Task<E, C>
  ) -> Task<E, (A, B, C)> {
  zip2(xs, zip2(ys, zs)) // Task<E, (A, (B, C))>
    .map { a, bc in (a, bc.0, bc.1) }
}

@inlinable
func zip3<E, A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> (Task<E, A>, Task<E, B>, Task<E, C>) -> Task<E, D> {
  { xs, ys, zs in zip3(xs, ys, zs).map(f) }
}

