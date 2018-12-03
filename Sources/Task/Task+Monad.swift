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
		return self.biFlatMap(Task<E, U>.rejected, f)
	}
}