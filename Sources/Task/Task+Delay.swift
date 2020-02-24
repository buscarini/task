//
//  Task+Delay.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

@inlinable
public func delayed<E, A>(_ delay: TimeInterval, _ task: Task<E, A>) -> Task<E, A> {
	Task<E, A>({ (reject, resolve) in
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			task.fork(reject, resolve)
		}
	})
}

extension Task {
	@inlinable
	public func delay(_ time: TimeInterval) -> Task<E, T> {
		delayed(time, self)
	}
}
