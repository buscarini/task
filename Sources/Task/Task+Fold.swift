//
//  Task+Fold.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 29/6/18.
//

import Foundation

extension Task {
	public func fold<B>(_ f: @escaping (E) -> B, _ g: @escaping (T) -> B) -> Task<Never, B> {
		return Task<Never, B>({ reject, resolve in
			return self.fork({ error in
				resolve(f(error))
			},
			{ value in
				resolve(g(value))
			})
		}, cancel: cancel)
	}
}
