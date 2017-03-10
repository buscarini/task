//
//  Applicative.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Task

class Applicative: XCTestCase {
	
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
    func testAp() {
		let expectation = self.expectation(description: "task ap")
		
		ap(Task.of({ x in x*2 }), Task.of(1))
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 2)
				expectation.fulfill()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testApFailure() {
		let expectation = self.expectation(description: "task ap failed")
		
		ap(Task<(Int) -> Int>.rejected(exampleError()), Task.of(1))
			.fork({ error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}


	func testAp2Params() {
		let expectation = self.expectation(description: "task ap with 2 params")
		
		ap(Task.of(+), Task.of(1), Task.of(3))
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 4)
				expectation.fulfill()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testAp2ParamsFailure() {
		let expectation = self.expectation(description: "task ap with 2 params f failed")
		
		ap(Task<(Int, Int) -> Int>.rejected(exampleError()), Task.of(1), Task.of(3))
			.fork({ error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testAp2ParamsFailure1() {
		let expectation = self.expectation(description: "task ap with 2 params first failed")
		
		ap(Task.of(+), Task.rejected(exampleError()), Task.of(3))
			.fork({ error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testAp2ParamsFailure2() {
		let expectation = self.expectation(description: "task ap with 2 params second failed")
		
		ap(Task.of(+), Task.of(1), Task.rejected(exampleError()))
			.fork({ error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testApOperator() {
		let expectation = self.expectation(description: "task ap operator with 2 params")
		
		let add = Task.of({ (x: Int) in
			return { (y: Int) in
				return x+y
			}
		})
		
		(add <*> Task.of(1) <*> Task.of(3))
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 4)
				expectation.fulfill()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testApOperator3Args() {
		let expectation = self.expectation(description: "task ap operator with 3 params")
		
		let add = Task.of({ (x: Int) in
			return { (y: Int) in
				return { (z: Int) in
					return x+y+z
				}
			}
		})
		
		(add <*> Task.of(1) <*> Task.of(3) <*> Task.of(7))
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 11)
				expectation.fulfill()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
}

