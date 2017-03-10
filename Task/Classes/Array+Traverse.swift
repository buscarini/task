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

