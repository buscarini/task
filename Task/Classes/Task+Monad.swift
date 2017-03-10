//
//  Task+Monad.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

extension Task {
	public func flatMap<U>(_ f: @escaping (T) -> (Task<U>)) -> Task<U> {
		return Task<U>({ (reject: @escaping (Error) -> (), resolve: @escaping (U) -> ()) in
			return self.fork({ error in
				reject(error)
			},
			{ value in
				f(value).fork(reject, resolve)
			})
		}, cleanup: cleanup)
	}
}
