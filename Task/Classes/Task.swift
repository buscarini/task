//
//  Task.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

open class Task<T> {
	public typealias Computation = (@escaping (Error) -> (), @escaping (T) -> ()) ->()

	public let fork: Computation
	let cleanup: (() -> ())?
	
	public init(_ computation: @escaping Computation, cleanup: (() -> ())? = nil) {
		self.fork = computation
		self.cleanup = cleanup
	}
	
	public static func of(_ value: T) -> Task {
		return Task({ (_, resolve) in
			return resolve(value)
		})
	}
	
	public static func rejected(_ error: Error) -> Task {
		return Task({ (reject, _) in
			return reject(error)
		})
	}
}


