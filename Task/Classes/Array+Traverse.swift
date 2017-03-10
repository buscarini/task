//
//  Array+Task.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

extension Array {
	public func traverse<T>(_ f: @escaping (Element) -> Task<T>) -> Task<[T]> {
		return self.reduce(Task.of([])) { acc, item in
			let current = f(item).map { [$0] }
		
			let concat = Task<([T], [T]) -> [T]>.of(+)
			
			return ap(concat, acc, current)
		}
	}
}

public func sequence<T>(_ tasks: [Task<T>]) -> Task<[T]> {
	return tasks.traverse({$0})
}

public func concat<A>(_ first: Task<[A]>, _ second: Task<[A]>) -> Task<[A]> {
	return ap(Task.of(+), first, second)
}

public func sequence<T>(_ tasks: [Task<[T]>]) -> Task<[T]> {
	return tasks.reduce(Task.of([])) { acc, item in
		return concat(acc, item)
	}
}

public func sequenceSerial<T>(_ tasks: [Task<T>]) -> Task<[T]> {
	return sequenceSerial(tasks.map { task in
		task.map { [$0] }
	})
}

public func sequenceSerial<T>(_ tasks: [Task<[T]>]) -> Task<[T]> {
	guard let first = tasks.first else {
		return Task<[T]>.of([])
	}

	return first.flatMap { values in
		let rest: Task<[T]> = sequenceSerial(Array(tasks.dropFirst(1)))
		return ap(Task.of(+), Task.of(values), rest)
	}
}

