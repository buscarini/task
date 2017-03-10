//
//  Arrays.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Task

class Arrays: XCTestCase {
	
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
    
    func testTraverse() {
	
		let expectation = self.expectation(description: "task succeeded")
	
		[1, 2, 3].traverse(Task<Int>.of)
			.fork({ error in
				XCTFail()
			},
			{ values in
				XCTAssert(values.count == 3)
				XCTAssert(values[0] == 1)
				XCTAssert(values[1] == 2)
				XCTAssert(values[2] == 3)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
    }
	
	func testSequence() {
	
		let expectation = self.expectation(description: "task succeeded")
	
		 sequence([ Task.of(1), Task.of(2), Task.of(3)])
			.fork({ error in
				XCTFail()
			},
			{ values in
				XCTAssert(values.count == 3)
				XCTAssert(values[0] == 1)
				XCTAssert(values[1] == 2)
				XCTAssert(values[2] == 3)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
    }

}
