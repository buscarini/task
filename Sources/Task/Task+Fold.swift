//
//  Task+Fold.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 29/6/18.
//

import Foundation

extension Task {
	@inlinable
	public func fold<B>(_ f: @escaping (E) -> B, _ g: @escaping (T) -> B) -> Task<Never, B> {
		Task<Never, B>({ reject, resolve in
			self.fork({ error in
				resolve(f(error))
			},
			{ value in
				resolve(g(value))
			})
		}, cancel: cancel)
	}
}
