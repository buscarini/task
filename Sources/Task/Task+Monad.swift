//
//  Task+Monad.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

extension Task {
	
	@inlinable
	public func flatMap<U>(_ f: @escaping (T) -> (Task<E, U>)) -> Task<E, U> {
		self.biFlatMap({ Task<E, U>.rejected($0) }, f)
	}
	
	@inlinable
	public func replicateM(_ count: Int) -> Task<E, [T]> {
		Array(1...count).traverse { _ in
			self
		}
	}
}
