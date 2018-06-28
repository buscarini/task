//
//  Task+Error.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 13/6/18.
//

import Foundation

extension Task {
	public func mapError<F>(_ f: @escaping (E) -> (F)) -> Task<F, T> {
		return self.bimap(f, id)
	}
	
	public func flatMapError<F>(_ f: @escaping (E) -> (Task<F, T>)) -> Task<F, T> {
		return self.biFlatMap(f, Task<F, T>.of)
	}
}
