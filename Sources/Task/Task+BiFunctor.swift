//
//  Task+BiFunctor.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 13/6/18.
//

import Foundation

extension Task {
	@inlinable
	public func bimap<F, U>(_ f: @escaping (E) -> F, _ g: @escaping (T) -> U) -> Task<F, U> {
		Task<F, U>({ reject, resolve in
			self.fork({ error in
				reject(f(error))
			},
			{ value in
				resolve(g(value))
			})
		}, cancel: cancel)
	}
}
