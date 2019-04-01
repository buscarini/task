//
//  Task+Zip.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 31/7/18.
//

import Foundation

public func zip<E, A, B>(_ left: Task<E, A>, _ right: Task<E, B>) -> Task<E, (A, B)> {
	return liftA2(Task.of({ a in
		{ b in
			(a, b)
		}
	}), left, right)
}

public func zip<E, A, B, C>(with f: @escaping (A, B) -> C)
	-> (Task<E, A>, Task<E, B>)
	-> Task<E, C> {
	return { left, right in
		return zip(left, right).map(f)
	}
}

public func zip2<E, A, B>(_ left: Task<E, A>, _ right: Task<E, B>) -> Task<E, (A, B)> {
	return zip(left, right)
}

public func zip2<E, A, B, C>(with f: @escaping (A, B) -> C)
	-> (Task<E, A>, Task<E, B>)
	-> Task<E, C> {
	return zip(with: f)
}

public func zip3<E, A, B, C>(
  _ xs: Task<E, A>, _ ys: Task<E, B>, _ zs: Task<E, C>
  ) -> Task<E, (A, B, C)> {

  return zip2(xs, zip2(ys, zs)) // Task<E, (A, (B, C))>
    .map { a, bc in (a, bc.0, bc.1) }
}

func zip3<E, A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> (Task<E, A>, Task<E, B>, Task<E, C>) -> Task<E, D> {
  return { xs, ys, zs in zip3(xs, ys, zs).map(f) }
}

