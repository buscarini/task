//
//  ZipTests.swift
//  NonEmpty
//
//  Created by José Manuel Sánchez Peñarroja on 25/02/2020.
//

import Foundation
import XCTest
import Task

class ConcurrencyTests: XCTestCase {
	func testZip() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...100)
		
		let left = sequence(values.map {
			Async<Int>.of($0)
		})
		
		let right = sequence(values.map {
			Async<Int>.of($0)
		})
		
		zip(
			left,
			right
		)
		.scheduleOn(DispatchQueue.global())
		.run({ result in
			XCTAssert(result.0 == values)
			XCTAssert(result.1 == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testZipStackOverflow() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...10000)
		
		let left = sequence(values.map {
			Async<Int>.of($0).scheduleOn(.global()).forkOn(.global())
		})
		
		let right = sequence(values.map {
			Async<Int>.of($0).scheduleOn(.global()).forkOn(.global())
		})
		
		zip(
			left,
			right
			)
			.scheduleOn(DispatchQueue.global())
			.run({ result in
				XCTAssert(result.0 == values)
				XCTAssert(result.1 == values)
				finish.fulfill()
			})
		
		wait(for: [finish], timeout: 10)
	}
	
	func testForEach() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...50_000)

		
		let task = sequence(values.map {
			Async.of($0).scheduleOn(.global()).forkOn(.global())
		})
		
		task.fork({ _ in }, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 120)
	}
	
	func testForEachGlobalQueueDebug() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...100)
		
		let task = sequence(values.map {
			Async<Int>.of($0)
		})
		.scheduleOn(DispatchQueue.global())
		
		task.forkMain(absurd, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testForEachGlobalQueue() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...100)
		
		let task = sequence(values.map {
			Async<Int>.of($0)
		})
		.scheduleOn(DispatchQueue.global())
		
		task.forkMain(absurd, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testForEachGlobalQueueMultiple() {
		let finish = expectation(description: "finish")

		let values = Array(1...100)

		let task = sequence(values.map {
			Async<Int>.of($0).scheduleOn(DispatchQueue.global())
		})

		task.forkMain(absurd, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testCancel() {
		let finish = expectation(description: "finish")
		
		
		let task = Async.of(1).scheduleOn(DispatchQueue.global())
		
		task.cancel()
		
		task.fork(absurd, { _ in
			XCTFail()
		})
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testCancelAfterFork() {
		let finish = expectation(description: "finish")
		
		
		let task = Async.of(1).scheduleOn(DispatchQueue.global())
		
		task.fork(absurd, { _ in
			XCTFail()
		})
		
		task.cancel()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testCancelZip() {
		let finish = expectation(description: "finish")
		
		let left = Async.of(1).scheduleOn(DispatchQueue.global())
		let right = Async.of(2).scheduleOn(DispatchQueue.global())
		
		let task = zip(left, right)
			
		task
			.fork(absurd, { values in
				print(values)
				XCTFail()
			})
		
		task.cancel()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testCancelZipLeft() {
		let finish = expectation(description: "finish")
		
		let left = Async.of(1).scheduleOn(DispatchQueue.global())
		let right = Async.of(2).scheduleOn(DispatchQueue.global())
		
		left.cancel()
		
		zip(left, right)
		.fork(absurd, { values in
			print(values)
			XCTFail()
		})
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testForEachPerformanceNoTask() {
		measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
			let values = Array(1...10_000)
			
			var last: Int = 0
			values.forEach {
				last = $0
			}
			
			XCTAssert(last == 10_000)
		}
	}
	
	func testForEachPerformance() {
		measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
			let finish = expectation(description: "finish")

			let values = Array(1...10_000)
			
			let task = sequence(values.map {
				Async<Int>.of($0).scheduleOn(.global()).forkOn(.global())
			}).scheduleOn(DispatchQueue.global())
			
			task.forkMain(absurd, { result in
				finish.fulfill()
			})
			
			waitForExpectations(timeout: 20, handler: { _ in
				self.stopMeasuring()
			})
		}
		
	}
	
	func testReduceRegularPerformance() {
		measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
			let values = Array(1...100_000)
			_ = values.reduce(0, { res, value in
				res + value
			})
		}
	}
}
