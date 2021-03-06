
import XCTest
import Task

class Tests: XCTestCase {
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
    func testSuccess() {
	
		let expectation = self.expectation(description: "task succeeded")
	
		Task<Error, Int>.of(22)
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
	
		Task.rejected(self.exampleError())
			.fork({ error in
				expectation.fulfill()
			},
			{ (_: Int) in
				XCTFail()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testCompletionOnSuccess() {
		let expectation = self.expectation(description: "task completed")
		
		Task<Error, Int>.of(22)
			.fork({ error in },
				  { (_: Int) in },
				  onComplete: {
					expectation.fulfill()
				}
			)
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testCompletionOnFail() {
		let expectation = self.expectation(description: "task completed")
		
		Task.rejected(self.exampleError())
			.fork({ error in },
			{ (_: Int) in }, onComplete: {
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
}

