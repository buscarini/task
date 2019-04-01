//
//  Array+Task.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

extension Array {
	public func traverse<E, T>(_ f: @escaping (Element) -> Task<E, T>) -> Task<E, [T]> {
		return self.reduce(Task.of([])) { acc, item in
			let current = f(item).map { [$0] }
		
			let concat = Task<E, ([T], [T]) -> [T]>.of(+)
			
			return ap(concat, acc, current)
		}
	}
}

public func parallel<E, T>(_ tasks: [Task<E, T>]) -> Task<E, [T]> {
	return tasks.traverse({$0})
}

public func concat<E, A>(_ first: Task<E, [A]>, _ second: Task<E, [A]>) -> Task<E, [A]> {
	return ap(Task.of(+), first, second)
}

public func parallel<E, T>(_ tasks: [Task<E, [T]>]) -> Task<E, [T]> {
	return tasks.reduce(Task.of([])) { acc, item in
		return concat(acc, item)
	}
}

public func sequence<E, T>(_ tasks: [Task<E, T>]) -> Task<E, [T]> {
	return sequence(tasks.map { task in
		task.map { [$0] }
	})
}

public func sequence<E, T>(_ tasks: [Task<E, [T]>]) -> Task<E, [T]> {
	guard let first = tasks.first else {
		return Task<E, [T]>.of([])
	}

	return first.flatMap { values in
		let rest: Task<E, [T]> = sequence(Array(tasks.dropFirst(1)))
		return ap(Task.of(+), Task.of(values), rest)
	}
}

