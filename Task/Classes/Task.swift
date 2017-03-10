//
//  Task.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

open class Task<T> {
	public typealias Computation = (@escaping (Error) -> (), @escaping (T) -> ()) ->()

	public let fork: Computation
	let cleanup: (() -> ())?
	
	public init(_ computation: @escaping Computation, cleanup: (() -> ())? = nil) {
		self.fork = computation
		self.cleanup = cleanup
	}
	
	public static func of(_ value: T) -> Task {
		return Task({ (_, resolve) in
			return resolve(value)
		})
	}
	
	public static func rejected(_ error: Error) -> Task {
		return Task({ (reject, _) in
			return reject(error)
		})
	}
}

// MARK: Functor
extension Task {
	public func map<U>(_ f: @escaping (T) -> (U)) -> Task<U> {
		return Task<U>({ (reject: @escaping (Error) -> (), resolve: @escaping (U) -> ()) in
			return self.fork({ error in
				reject(error)
			},
			{ value in
				resolve(f(value))
			})
		}, cleanup: cleanup)
	}
}

// MARK: Applicative
public func liftA2<A, B, C>(_ fTask: Task<(A) -> (B) -> C>, _ first: Task<A>, _ second: Task<B>) -> Task<C> {
	return ap(ap(fTask, first),second)
}

public func ap<A, B, C>(_ fTask: Task<(A, B) -> C>, _ first: Task<A>, _ second: Task<B>) -> Task<C> {
	return fTask.flatMap { f in
		return liftA2(Task<(A) -> (B) -> C>.of(curry(f)), first, second)
	}
}

public func ap<A, B>(_ fTask: Task<(A) -> B>, _ other: Task<A>) -> Task<B> {
	return Task<B>({ (reject: @escaping (Error) -> (), resolve: @escaping (B) -> ()) in
		var f: ((A)->B)?
		var val: A?
		
		var rejected = false
		
		let guardReject: (Error) -> () = { x in
		  if (!rejected) {
			rejected = true;
			reject(x)
		  }
		}
		
		let tryResolve = {
			guard let f = f, let val = val else { return }
			resolve(f(val))
		}
		
		fTask.fork(guardReject, { loadedF in
			guard !rejected else {
				return
			}
			
			f = loadedF
			
			tryResolve()
		})
		
		other.fork(guardReject, { loadedVal in
			guard !rejected else {
				return
			}
			
			val = loadedVal
			
			tryResolve()
		})
	}, cleanup: {
		fTask.cleanup?()
		other.cleanup?()
	})
}

// MARK: Monad
extension Task {
	public func flatMap<U>(_ f: @escaping (T) -> (Task<U>)) -> Task<U> {
		return Task<U>({ (reject: @escaping (Error) -> (), resolve: @escaping (U) -> ()) in
			return self.fork({ error in
				reject(error)
			},
			{ value in
				f(value).fork(reject, resolve)
			})
		}, cleanup: cleanup)
	}
}

infix operator <*>: AdditionPrecedence
public func <*><A, B>(fTask: Task<(A) -> B>, first: Task<A>) -> Task<B> {
    return ap(fTask, first)
}


