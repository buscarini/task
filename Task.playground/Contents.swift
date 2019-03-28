//import NonEmpty
import Task

Task<Error, Int>.of(1).fork({ _ in }, { Swift.print($0) })

public extension Task {
	public func replicateM(_ count: Int) -> Task<E, [T]> {
		return Array(1...count).traverse { _ in
			self
		}
	}
}


Task<Error, Int>.of(1).replicateM(7).fork({ _ in }, { Swift.print($0) })


public func forM<E, A, B>(_ values: [A], _ f: (A) -> Task<E, B>) -> Task<E, [B]> {
	return values.traverse(f)
}

public extension Task where T == Void {
	public func when(_ condition: Bool) -> Task<E, Void> {
		guard condition else {
			return Task.of(())
		}
		
		return self
	}
}



public enum Either<T, U> {
	case left(T)
	case right(U)
	
	public var left: T? {
		switch self {
		case let .left(left):
			return left
		case .right:
			return nil
		}
	}
	
	public var right: U? {
		switch self {
		case .left:
			return nil
		case let .right(right):
			return right
		}
	}
	
	public var isLeft: Bool {
		switch self {
		case .left:
			return true
		case .right:
			return false
		}
	}
	
	public var isRight: Bool {
		switch self {
		case .left:
			return false
		case .right:
			return true
		}
	}
	
	public func left(default value: T) -> T {
		return left ?? value
	}
	
	public func right(default value: U) -> U {
		return right ?? value
	}
	
	public func fold<A>(_ left: (T) -> A, _ right: (U) -> A) -> A {
		switch self {
		case .left(let l):
			return left(l)
		case .right(let r):
			return right(r)
		}
	}
}

//class Applicative f => Selective f where
//select :: f (Either a b) -> f (a -> b) -> f b


//extension Task {
//	public static func select<E, A, B>(_ left: Task<E, Either<A, B>>, _ f: Task<E, (A) -> B>) -> Task<E, B> {
//		return left.flatMap { either in
//			switch either {
//			case let .left(a):
//				return f.map { f in f(a) }
//			case let .right(b):
//				return Task<E, B>.of(b)
//			}
//		}
//	}
//
////	whenS :: Selective f => f Bool -> f () -> f ()
//
//
//}
//
//public extension Task where T == Bool {
//	public func whenS(_ f: Task<E, Void>) -> Task<E, Void> {
//		let selector: Task<E, Either<Void, Void>> = self.map { bool in
//			return bool ? .left(()) : .right(())
//		}
//
//		return self.select(selector, f.map { _ in { $0 } })
//	}
//}
//
//
//let printPong = Task<Error, Void>({ r, s in
//	print("blah")
//	s(())
//})
//
////Task.whenS(Task<Error, Bool>.of(true), printPong)
//
//Task<Error, Bool>.of(true).whenS(printPong)
//
//
