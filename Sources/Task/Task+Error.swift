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
	
	public static func `try`(_ f: @escaping () throws -> T) -> Task<Error, T> {
		return Task<Error, T>({ reject, resolve in
			do {
				resolve(try f())
			}
			catch let error {
				reject(error)
			}
		})
	}
}
