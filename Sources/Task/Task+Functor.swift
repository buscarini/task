//
//  Task+Functor.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

extension Task {
	
	@inlinable
	public func map<U>(_ f: @escaping (T) -> (U)) -> Task<E, U> {
		self.bimap(id, f)
	}
}
