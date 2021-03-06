//
//  Task+BiMonad.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 28/6/18.
//

import Foundation

extension Task {
	@inlinable
	public func biFlatMap<F, U>(_ f: @escaping (E) -> Task<F, U>, _ g: @escaping (T) -> Task<F, U>) -> Task<F, U> {
		Task<F, U>({ (reject: @escaping (F) -> (), resolve: @escaping (U) -> ()) in
			self.fork({ error in
				f(error).fork(reject, resolve)
			},
			{ value in
				g(value).fork(reject, resolve)
			})
		}, cancel: cancel)
	}
}

