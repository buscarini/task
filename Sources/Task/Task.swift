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
	public private(set) var cancelled: Bool {
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
	
	public func fork(_ reject: @escaping ErrorCallback, _ resolve: @escaping ResultCallback, onComplete: (() -> Void)? = nil) {
		self._fork({ error in
			guard !self.cancelled else { return }
			reject(error)
			onComplete?()
		}, { result in
			guard !self.cancelled else { return }
			resolve(result)
			onComplete?()
		})
	}
	
	public func cancel() {
		self.cancelled = true
		self._cancel?()
	}
	
	@inlinable
	public static func of(_ value: @autoclosure @escaping () -> T) -> Task {
		Task({ (_, resolve) in
			resolve(value())
		})
	}
	
	@inlinable
	public static func rejected(_ error: @autoclosure @escaping () -> E) -> Task {
		Task({ (reject, _) in
			reject(error())
		})
	}
	
	@inlinable
	public static func from(_ optional: T?, default value: T) -> Task {
		if let value = optional {
			return Task.of(value)
		}
		else {
			return Task.of(value)
		}
	}

	@inlinable
	public static func from(_ optional: T?, _ error: E) -> Task {
		if let value = optional {
			return Task.of(value)
		}
		else {
			return Task.rejected(error)
		}
	}
	
	@inlinable
	public func optional() -> Task<Never, T?> {
		self
			.map { .some($0) }
			.flatMapError { _ in
				Task<Never, T?>.of(nil)
			}
	}
	
	@inlinable
	public func void() -> Task<E, Void> {
		self.const(())
	}
	
	@inlinable
	public func const<B>(_ value: B) -> Task<E, B> {
		self.map { _ in
			value
		}
	}
}

