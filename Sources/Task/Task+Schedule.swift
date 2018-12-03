//
//  Task+Schedule.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 28/6/18.
//

import Foundation

extension Task {
	public func forkOn(_ queue: DispatchQueue) -> Task<E, T> {
		return Task({ (reject, resolve) in
			self.fork({ error in
				queue.async {
					reject(error)
				}
			}, { result in
				queue.async {
					resolve(result)
				}
			})
		})
	}
}
