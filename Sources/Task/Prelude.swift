//
//  Absurd.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 12/6/18.
//

import Foundation

public func id<a>(_ a: a) -> a {
	return a
}

public func absurd<A>(_ n: Never) -> A {
	switch n {}
}
