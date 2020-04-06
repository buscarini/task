//
//  Sequential.swift
//  TYRSharedUtils
//
//  Created by José Manuel Sánchez Peñarroja on 03/04/2020.
//  Copyright © 2020 Tyris. All rights reserved.
//

import Foundation

public class Sequential {
	public private(set) var isRunning = false {
		didSet {
			self.onStateChange?(self.isRunning)
		}
	}
	public var onStateChange: ((Bool) -> Void)?
	
	public init() {
	}
}

// MARK: Public Methods
public extension Sequential {
	
	func run<E, A>(
		_ task: Task<E, A>
	) {
		self.fork(task, { _ in }, { _ in })
	}
	
	func fork<E, A>(
		_ task: Task<E, A>,
		_ reject: @escaping Task<E, A>.ErrorCallback,
		_ resolve: @escaping Task<E, A>.ResultCallback
	) {
		guard self.isRunning == false else {
			return
		}
		
		self.isRunning = true
		
		task.fork({ e in
			self.isRunning = false
			reject(e)
		}, { a in
			self.isRunning = false
			resolve(a)
		})
	}
}
