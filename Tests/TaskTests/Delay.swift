//
//  Delay.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Task

class Delay: XCTestCase {
    func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}

	func testDelay() {
		let expectation = self.expectation(description: "task is delayed")
		
		let task = Task<Error, Int>.of(1)
	
		let now = Date()
	
		delayed(1, task)
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 1)
				XCTAssert(-now.timeIntervalSinceNow > 0.9)
				
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 2.0, handler: nil)
	}
	
    func testDelayFail() {
		let expectation = self.expectation(description: "task is delayed with failure")
		
		let task = Task<Error, Int>.rejected(self.exampleError())
		let now = Date()

		delayed(1, task)
			.fork({ error in
				XCTAssert(-now.timeIntervalSinceNow > 0.9)
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
		
		self.waitForExpectations(timeout: 2.0, handler: nil)
	}
}
