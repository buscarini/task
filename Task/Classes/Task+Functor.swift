//
//  Task+Functor.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

extension Task {
	public func map<U>(_ f: @escaping (T) -> (U)) -> Task<U> {
		return Task<U>({ (reject: @escaping (Error) -> (), resolve: @escaping (U) -> ()) in
			return self.fork({ error in
				reject(error)
			},
			{ value in
				resolve(f(value))
			})
		}, cleanup: cleanup)
	}
}
