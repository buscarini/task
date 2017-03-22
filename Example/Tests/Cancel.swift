//
//  Cancel.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 14/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Task

class Cancel: XCTestCase {
    
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}

	func testCancel() {
		let expectation = self.expectation(description: "task is cancelled")
		
		let session = URLSession(configuration: URLSessionConfiguration.default)
		let url = URL(string: "http://www.google.com")!
		
		var httpTask = session.dataTask(with: url)
		
		let task = Task<Data?>({ (reject, resolve) in
		
			httpTask = session.dataTask(with: url) { data, response, error in
				if let error = error {
					reject(error)
				}
				else {
					resolve(data)
				}
			}
		
			httpTask.resume()
		}) { 
			httpTask.cancel()
		}
		
		task.fork({ error in
				XCTFail()
			},
			{ data in
				XCTFail()
			})
		
		task.cancel()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			expectation.fulfill()
		}
		
		self.waitForExpectations(timeout: 20.0, handler: nil)
	}
}
