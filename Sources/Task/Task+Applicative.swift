//
//  Task+Applicative.swift
//  Pods
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//
//

import Foundation

@inlinable
public func liftA2<E, A, B, C>(_ fTask: Task<E, (A) -> (B) -> C>, _ first: Task<E, A>, _ second: Task<E, B>) -> Task<E, C> {
	ap(ap(fTask, first),second)
}

@inlinable
public func ap<E, A, B, C>(_ fTask: Task<E, (A, B) -> C>, _ first: Task<E, A>, _ second: Task<E, B>) -> Task<E, C> {
	fTask.flatMap { f in
		liftA2(Task<E, (A) -> (B) -> C>.of(curry(f)), first, second)
	}
}

let apQueue = DispatchQueue.init(label: "ap")

public func ap<E, A, B>(_ left: Task<E, (A) -> B>, _ right: Task<E, A>) -> Task<E, B> {
	
	let l = left
	let r = right
	
	var cancelled = false
	
	return Task<E, B>({ (reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
	
		let resolved = SyncValue<Never, Bool>()
		let leftVal = SyncValue<E, (A) -> B>()
		let rightVal = SyncValue<E, A>()
		
		let checkContinue = {
			apQueue.async {
				guard resolved.notLoaded, cancelled == false, l.cancelled == false, r.cancelled == false else { return }
				
				switch (leftVal.result, rightVal.result) {
				case let (.loaded(.right(ab)), .loaded(.right(a))):
					resolved.result = .loaded(.right(true))
					resolve(ab(a))
				case let (.loaded(.left(e)), .loaded):
					resolved.result = .loaded(.right(false))
					reject(e)
				case let (.loaded, .loaded(.left(e))):
					resolved.result = .loaded(.right(false))
					reject(e)
					
				default:
					return
				}
			}
		}
		
		l.fork({ error in
			leftVal.result = .loaded(.left(error))
			
			checkContinue()
			
		}, { loadedF in
			leftVal.result = .loaded(.right(loadedF))
			
			checkContinue()
		})
	
		r.fork({ error in
			rightVal.result = .loaded(.left(error))
			
			checkContinue()
		}, { loadedVal in
			rightVal.result = .loaded(.right(loadedVal))
			
			checkContinue()
		})
		
	}, cancel: {
		cancelled = true
		l.cancel()
		r.cancel()
	})
}

precedencegroup ApplyPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

infix operator <*>: ApplyPrecedence

@inlinable
public func <*><E, A, B>(fTask: Task<E, (A) -> B>, first: Task<E, A>) -> Task<E, B> {
    ap(fTask, first)
}

