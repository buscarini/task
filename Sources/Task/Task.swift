//
//  Task.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

open class Task<E, T> {
	public typealias ErrorCallback = (E) -> ()
	public typealias ResultCallback = (T) -> ()
	public typealias EmptyCallback = () -> ()

	public typealias Computation = (@escaping ErrorCallback, @escaping ResultCallback) -> ()

	private let _fork: Computation
	private let _cancel: (() -> ())?
	
	private var _cancelled = false
	private let cancelSyncQueue = DispatchQueue(label: "task_cancel")
	private var cancelled: Bool {
		get {
			var result = false
			
			cancelSyncQueue.sync {
				result = self._cancelled
			}
			return result
		}
		
		set {
			cancelSyncQueue.sync {
				self._cancelled = newValue
			}
		}
	}
	
	public init(_ computation: @escaping Computation, cancel: EmptyCallback? = nil) {
		self._fork = computation
		self._cancel = cancel
	}
	
	public func fork(_ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback) {
		self._fork({ error in
			guard !self.cancelled else { return }
			reject(error)
		}, { result in
			guard !self.cancelled else { return }
			resolve(result)
		})
	}
	
	public func cancel() {
		self.cancelled = true
		self._cancel?()
	}
	
	public static func of(_ value: T) -> Task {
		return Task({ (_, resolve) in
			return resolve(value)
		})
	}
	
	public static func rejected(_ error: E) -> Task {
		return Task({ (reject, _) in
			return reject(error)
		})
	}

	public static func from(_ optional: T?, _ error: E) -> Task {
		if let value = optional {
			return Task.of(value)
		}
		else {
			return Task.rejected(error)
		}
	}
}
