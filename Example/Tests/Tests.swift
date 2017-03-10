import UIKit
import XCTest
import Task

class Tests: XCTestCase {
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
    func testSuccess() {
	
		let expectation = self.expectation(description: "task succeeded")
	
		Task.of(22)
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 22)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
    }
	
    func testFailure() {
		let expectation = self.expectation(description: "task failed")
	
		Task.rejected(exampleError())
			.fork({ error in
				expectation.fulfill()
			},
			{ (_: Int) in
				XCTFail()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testMap() {
		let expectation = self.expectation(description: "task mapped")
		
		Task.of("blah")
			.map({ string in
				return string.characters.count
			})
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 4)
				expectation.fulfill()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testAp() {
		let expectation = self.expectation(description: "task ap")
		
		Task<(Int, Int) -> Int>.ap(Task.of({ x in x*2 }), Task.of(1))
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
		
		Task<(Int, Int) -> Int>.ap(Task<(Int) -> Int>.rejected(exampleError()), Task.of(1))
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
		
		Task<(Int, Int) -> Int>.ap(Task.of(+), Task.of(1), Task.of(3))
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
		
		Task<(Int, Int) -> Int>.ap(Task<(Int, Int) -> Int>.rejected(exampleError()), Task.of(1), Task.of(3))
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
		
		Task<(Int, Int) -> Int>.ap(Task.of(+), Task.rejected(exampleError()), Task.of(3))
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
		
		Task<(Int, Int) -> Int>.ap(Task.of(+), Task.of(1), Task.rejected(exampleError()))
			.fork({ error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testFlatMap() {
		let expectation = self.expectation(description: "task chained")
		
		Task.of("blah")
			.flatMap({ string in
				return Task.of(string.characters.count)
			})
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 4)
				expectation.fulfill()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
}
