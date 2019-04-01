//
//  Task+Applicative.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

public func liftA2<E, A, B, C>(_ fTask: Task<E, (A) -> (B) -> C>, _ first: Task<E, A>, _ second: Task<E, B>) -> Task<E, C> {
	return ap(ap(fTask, first),second)
}

public func ap<E, A, B, C>(_ fTask: Task<E, (A, B) -> C>, _ first: Task<E, A>, _ second: Task<E, B>) -> Task<E, C> {
	return fTask.flatMap { f in
		return liftA2(Task<E, (A) -> (B) -> C>.of(curry(f)), first, second)
	}
}

public func ap<E, A, B>(_ fTask: Task<E, (A) -> B>, _ other: Task<E, A>) -> Task<E, B> {
	return Task<E, B>({ (reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
		var f: ((A)->B)?
		var val: A?
		
		var rejected = false
		
		let guardReject: (E) -> () = { x in
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
	}, cancel: {
		fTask.cancel()
		other.cancel()
	})
}

precedencegroup ApplyPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

infix operator <*>: ApplyPrecedence

public func <*><E, A, B>(fTask: Task<E, (A) -> B>, first: Task<E, A>) -> Task<E, B> {
    return ap(fTask, first)
}

