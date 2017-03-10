import UIKit
import XCTest
import Task

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
	
		Task.rejected(NSError(domain: "tests", code: 1, userInfo: nil))
			.fork({ error in
				expectation.fulfill()
			},
			{ (_: Int) in
				XCTFail()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure() {
//            // Put the code you want to measure the time of here.
//        }
//    }
	
}
