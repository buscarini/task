//
//  Array+Task.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

extension Array {
	
	@inlinable
	public func traverse<E, T>(_ f: @escaping (Element) -> Task<E, T>) -> Task<E, [T]> {
		self.reduce(Task.of([])) { acc, item in
			let current = f(item).map { [$0] }
		
			let concat = Task<E, ([T], [T]) -> [T]>.of(+)
			
			return ap(concat, acc, current)
		}
	}
}

@inlinable
public func parallel<E, T>(_ tasks: [Task<E, T>]) -> Task<E, [T]> {
	tasks.traverse({$0})
}

@inlinable
public func concat<E, A>(_ first: Task<E, [A]>, _ second: Task<E, [A]>) -> Task<E, [A]> {
	ap(Task.of(+), first, second)
}

@inlinable
public func parallel<E, T>(_ tasks: [Task<E, [T]>]) -> Task<E, [T]> {
	tasks.reduce(Task.of([])) { acc, item in
		concat(acc, item)
	}
}

@inlinable
public func sequence<E, T>(_ tasks: [Task<E, T>]) -> Task<E, [T]> {
	sequence(tasks.map { task in
		task.map { [$0] }
	})
}

@inlinable
public func sequence<E, T>(_ tasks: [Task<E, [T]>]) -> Task<E, [T]> {
	guard let first = tasks.first else {
		return Task<E, [T]>.of([])
	}

	return first.flatMap { values in
		let rest: Task<E, [T]> = sequence(Array(tasks.dropFirst(1)))
		return ap(Task.of(+), Task.of(values), rest)
	}
}

