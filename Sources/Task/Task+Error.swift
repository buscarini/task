//
//  Task+Error.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 13/6/18.
//

import Foundation

extension Task {
	@inlinable
	public func mapError<F>(_ f: @escaping (E) -> (F)) -> Task<F, T> {
		self.bimap(f, id)
	}
	
	@inlinable
	public func flatMapError<F>(_ f: @escaping (E) -> (Task<F, T>)) -> Task<F, T> {
		self.biFlatMap(f, { Task<F, T>.of($0) })
	}
	
	@available(*, deprecated, renamed: "init(catching:)")
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
	
	@inlinable
	public func `catch`(_ value: T) -> Task<Never, T> {
		self.flatMapError { _ in
			Task<Never, T>.of(value)
		}
	}
}

public extension Task where E == Error {
	@inlinable
	convenience init (catching: @escaping () throws -> T) {
		self.init({ (reject, resolve) in
			do {
				resolve(try catching())
			}
			catch let error {
				reject(error)
			}
		})
	}
}
