//
//  Task+Monad.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

extension Task {
	public func flatMap<U>(_ f: @escaping (T) -> (Task<E, U>)) -> Task<E, U> {
		return Task<E, U>({ (reject: @escaping (E) -> (), resolve: @escaping (U) -> ()) in
			return self.fork({ error in
				reject(error)
			},
			{ value in
				f(value).fork(reject, resolve)
			})
		}, cancel: cancel)
	}
}
