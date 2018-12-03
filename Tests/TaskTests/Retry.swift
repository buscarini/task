//
//  Retry.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Task

class Retry: XCTestCase {
	var value:Int = 0
	
	override func setUp() {
		super.setUp()
		self.value = 0
	}

    func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
	func fails2Times() -> Task<Error, Int> {
		return Task<Error, Int>({ (reject, resolve) in
			self.value += 1
			
			if self.value < 3 {
				reject(self.exampleError())
			}
			else {
				resolve(self.value)
			}
		})
	}

	func testRetry() {
		let expectation = self.expectation(description: "task is retried and succeeds")
		
		let task = fails2Times()
	
		retry(3, task)
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 3)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
    func testFail() {
		let expectation = self.expectation(description: "task is retried but fails")
		
		let task = fails2Times()
		
		retry(1, task)
			.fork({ error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testRetryDelayed() {
		let expectation = self.expectation(description: "task is retried with a delay")
		
		let task = fails2Times()
	
		let now = Date()
	
		retry(times: 3, delay: 1, task)
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(-now.timeIntervalSinceNow > 1.9)
				
				XCTAssert(value == 3)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 2.5, handler: nil)
	}
}
