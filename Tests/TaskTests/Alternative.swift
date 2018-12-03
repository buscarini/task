
import XCTest
import Task

class Alternative: XCTestCase {
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
    func testAlternative1() {
		let expectation = self.expectation(description: "task alternative first failed")
	
		(or(Task<Error, Int>.rejected(exampleError()), Task.of(22)))
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 22)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
    }
	
	func testAlternative2() {
		let expectation = self.expectation(description: "task alternative second failed")
	
		(or(Task.of(22), Task<Error, Int>.rejected(exampleError())))
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 22)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
    }
	
	func testAlternativeFail() {
		let expectation = self.expectation(description: "task all failed")
	
		(or(Task<Error, Int>.rejected(exampleError()), Task<Error, Int>.rejected(exampleError())))
			.fork({ error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
    }

	func testAlternativeOp() {
		let expectation = self.expectation(description: "task alternative with operator")
	
		(Task<Error, Int>.rejected(exampleError()) <|> Task.of(22))
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 22)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
    }
	
	func testAlternativeOp3() {
		let expectation = self.expectation(description: "task alternative with operator 3 arguments")
	
		(Task<Error, Int>.rejected(exampleError()) <|> Task<Error, Int>.rejected(exampleError()) <|> Task.of(22))
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 22)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
