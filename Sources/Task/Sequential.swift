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
	private var onCancel: () -> Void = {}
	
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
		self.onCancel = { [weak task] in
			task?.cancel()
		}
		
		task.fork({ [weak self] e in
			self?.isRunning = false
			self?.onCancel = {}
			reject(e)
		}, { [weak self] a in
			self?.isRunning = false
			self?.onCancel = {}
			resolve(a)
		})
	}
	
	func cancel() {
		self.onCancel()
	}
}
