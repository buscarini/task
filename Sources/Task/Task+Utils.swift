//
//  Task+Utils.swift
//  NonEmpty
//
//  Created by José Manuel Sánchez Peñarroja on 18/03/2020.
//

import Foundation

public extension Task {
	convenience init(either: Either<E, T>) {
		self.init({ (reject, resolve) in
			either.fold(reject, resolve)
		})
	}
	
	@inlinable
	var either: Task<Never, Either<E, T>> {
		return self.biFlatMap({ error in
			.of(.left(error))
		}) { value in
			.of(.right(value))
		}
	}
	
	@inlinable
	func optional(default value: T) -> Task<Never, T> {
		self.optional()
			.map { $0 ?? value }
	}
	
	@inlinable
	func `default`(_ value: T) -> Task<Never, T> {
		self.flatMapError { _ in
			.of(value)
		}
	}
	
	@inlinable
	func runForgetMain() {
		self.forkOn(DispatchQueue.main).runForget()
	}
	
	@inlinable
	func runForget() {
		self.fork({ _ in
		}, { _ in
			
		})
	}
	
	@inlinable
	func biFlatMap<F, U>(_ task: Task<F, U>) -> Task<F, U> {
		self.biFlatMap({ _ in task }, { _ in task })
	}
		
	@inlinable
	func when(_ f: @escaping (T) -> Bool, run: @escaping (T) -> Task<E, T>) -> Task<E, T> {
		self.flatMap { t in
			guard f(t) else {
				return .of(t)
			}
			
			return run(t)
		}
	}
	
	@inlinable
	func `guard`<U>(
		_ f: @escaping (T) -> Bool,
		else left: @escaping (T) -> Task<E, U>,
		run right: @escaping (T) -> Task<E, U>
	) -> Task<E, U> {
		return self.flatMap { t in
			f(t) ? right(t) : left(t)
		}
	}
	
	@inlinable
	static func lazy(_ value: @escaping () -> T) -> Task {
		return Task({ (_, resolve) in
			return resolve(value())
		})
	}
	
	@inlinable
	static func sync(_ value: @escaping () -> Either<E, T>) -> Task {
		Task({ (reject, resolve) in
			switch value() {
			case let .left(left):
				reject(left)
			case let .right(right):
				resolve(right)
			}
		})
	}
	
	@inlinable
	static func syncMain(_ value: @escaping () -> Either<E, T>) -> Task {
		sync(value).scheduleOn(.main)
	}
	
	@inlinable
	func sleep(_ time: TimeInterval) -> Task<E, T> {
		self.flatMap { value in
			Task<E, T>.of(value).delay(time)
		}
	}
	
	@inlinable
	func onSuccess(_ f: @escaping (T) -> Void) -> Task<E, T> {
		self.flatMap { value in
			Task.init({ (_, resolve) in
				f(value)
				resolve(value)
			})
		}
	}
	
	@inlinable
	func onError(_ f: @escaping (E) -> Void) -> Task<E, T> {
		self.flatMapError { e in
			Task.init({ (reject, _) in
				f(e)
				reject(e)
			})
		}
	}
}

public extension Task where E == Never {
	func liftError<F>(_ f: F.Type) -> Task<F, T> {
		mapError(absurd)
	}
}

public extension Task where T == Void {
	func ignoreErrors() -> Task<Never, Void> {
		self.optional().void()
	}
}

public extension Task where E == Never, T == Void {
	static func effect(_ value: @escaping () -> Void) -> Task {
		return Task.sync { () -> Either<Never, Void> in
			value()
			return .right(())
		}
	}
}

@inlinable
public func zip4<E, A, B, C, D>(
	_ xs: Task<E, A>, _ ys: Task<E, B>, _ zs: Task<E, C>, _ ws: Task<E, D>
	) -> Task<E, (A, B, C, D)> {
	zip2(xs, zip3(ys, zs, ws)) // Task<E, (A, (B, C, D))>
		.map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}

@inlinable
func zip4<E, A, B, C, D, F>(
	with f: @escaping (A, B, C, D) -> F
	) -> (Task<E, A>, Task<E, B>, Task<E, C>, Task<E, D>) -> Task<E, F> {
	{ xs, ys, zs, ws in zip4(xs, ys, zs, ws).map(f) }
}

@inlinable
public func zip5<E, A, B, C, D, F>(
	_ as: Task<E, A>, _ bs: Task<E, B>, _ cs: Task<E, C>, _ ds: Task<E, D>, _ fs: Task<E, F>
	) -> Task<E, (A, B, C, D, F)> {
	zip2(`as`, zip4(bs, cs, ds, fs))
		.map { a, bcdf in (a, bcdf.0, bcdf.1, bcdf.2, bcdf.3) }
}

@inlinable
func zip5<E, A, B, C, D, F, G>(
	with f: @escaping (A, B, C, D, F) -> G
	) -> (Task<E, A>, Task<E, B>, Task<E, C>, Task<E, D>, Task<E, F>) -> Task<E, G> {
	{ `as`, bs, cs, ds, fs in zip5(`as`, bs, cs, ds, fs).map(f) }
}

@inlinable
public func runAll<E, A>(_ tasks: [Task<E, A>]) -> Task<E, [A]> {
	tasks
		.map { $0.either }
		.traverse(id)
		.mapError(absurd)
		.map { eithers in
			eithers.filter {
				$0.isRight
			}
		}
		.flatMap { eithers in
			eithers.traverse(Task.init(either:))
		}
}
