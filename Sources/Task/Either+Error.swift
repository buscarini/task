//
//  Either+Error.swift
//  TYRSharedUtils
//
//  Created by José Manuel Sánchez Peñarroja on 1/1/19.
//

import Foundation

extension Either where T == Error {
	public static func `try`(_ f: () throws -> U) -> Either<T, U> {
		do {
			return try .right(f())
		}
		catch let error {
			return .left(error)
		}
	}
}

//extension Either: Decodable where U: Decodable, T == Error {
//	public init(from decoder: Decoder) throws {
//		do {
//			self = .right(try decoder.singleValueContainer().decode(U.self))
//		}
//		catch let error {
//			let collector = decoder.userInfo[ErrorCollector.key] as? ErrorCollector
//			collector?.errors += [error]
//
//			self = .left(error)
//		}
//	}
//}
//
//extension Either: Encodable where U: Encodable, T == Error {
//	public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//		switch self {
//			case let .left(error):
//				throw(error)
//			case let .right(value):
//		        try container.encode(value)
//		}
//    }
//}
