//
//  Task+Applicative.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

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

infix operator <*>: AdditionPrecedence
public func <*><A, B>(fTask: Task<(A) -> B>, first: Task<A>) -> Task<B> {
    return ap(fTask, first)
}

