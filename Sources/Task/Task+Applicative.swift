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
	ap(ap(fTask.map(curry), first), second)
}

//let apQueue = DispatchQueue.init(label: "ap")

fileprivate struct ApValue<A, B, E> {
	var left: Either<E, (A) -> B>?
	var right: Either<E, A>?
	
	var isResolved: Bool {
		left != nil && right != nil
	}
	
	var apply: Either<E, B>? {
		guard let left = left, let right = right else {
			return nil
		}
		
		return left.flatMap { ab in
			right.map { a in
				ab(a)
			}
		}
	}
}

public func ap<E, A, B>(_ left: Task<E, (A) -> B>, _ right: Task<E, A>) -> Task<E, B> {
	
	let l = left
	let r = right
	var value = ApValue<A, B, E>()

//	var cancelled = false
	let barrier = DispatchQueue(label: "ap.queue", attributes: .concurrent)

	return Task<E, B>({ (reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
		
		
//		let resolved = SyncValue<Never, Bool>()
//		let leftVal = SyncValue<E, (A) -> B>()
//		let rightVal = SyncValue<E, A>()
//
		let checkContinue = {
			var result: Either<E, B>?
			
			barrier.sync {
				result = value.apply
			}
			
			switch result {
				case let .right(b):
					DispatchQueue.main.async {
						resolve(b)
					}
				case let .left(e):
					DispatchQueue.main.async {
						reject(e)
					}
				case nil:
					return
			}
			
			
//			barrier.sync {
//				guard value.isResolved, cancelled == false, l.cancelled == false, r.cancelled == false else { return }
//
//				switch (value.left, value.right) {
//				case let (.right(ab), .right(a)):
////					resolved.result = .loaded(.right(true))
//					DispatchQueue.main.async {
//						resolve(ab(a))
//					}
//				case let (.loaded(.left(e)), .loaded):
//					resolved.result = .loaded(.right(false))
//					DispatchQueue.main.async {
//						reject(e)
//					}
//				case let (.loaded, .loaded(.left(e))):
//					resolved.result = .loaded(.right(false))
//					DispatchQueue.main.async {
//						reject(e)
//					}
//
//				default:
//					return
//				}
//			}
		}
		
		l.fork({ error in
			barrier.sync(flags: .barrier) {
				value.left = .left(error)
			}
			
			checkContinue()
			
		}, { loadedF in
			barrier.sync(flags: .barrier) {
				value.left = .right(loadedF)
			}
			
			checkContinue()
		})
	
		r.fork({ error in
			barrier.sync(flags: .barrier) {
				value.right = .left(error)
			}
			
			checkContinue()
		}, { loadedVal in
			barrier.sync(flags: .barrier) {
				value.right = .right(loadedVal)
			}
			
			checkContinue()
		})
		
	}, cancel: {
		barrier.async(flags: .barrier) {
//			cancelled = true
			value.left = nil
			value.right = nil
		}
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

