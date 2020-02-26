//
//  Either+Alternative.swift
//  TYRSharedUtils
//
//  Created by José Manuel Sánchez Peñarroja on 1/1/19.
//

import Foundation

extension Either {
	public static func <|> (_ left: Either<T, U>, _ right: @autoclosure () -> Either<T, U>) -> Either<T, U> {
		return left.isRight ? left : right()
	}

	public static func <|> (_ left: Either<T, U>, _ defaultValue: U) -> U {
		return left.right ?? defaultValue
	}
}
