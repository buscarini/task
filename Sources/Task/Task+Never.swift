//
//  Task+Never.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 12/6/18.
//

import Foundation

extension Task where E == Never {
	
	@inlinable
	public func run(_ resolve: @escaping ResultCallback) {
		self.fork(absurd, resolve)
	}
}
