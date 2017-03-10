//
//  Task+Delay.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

public func delayed<A>(_ delay: TimeInterval, _ task: Task<A>) -> Task<A> {
	return Task<A>({ (reject, resolve) in
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			task.fork(reject, resolve)
		}
	})
}

