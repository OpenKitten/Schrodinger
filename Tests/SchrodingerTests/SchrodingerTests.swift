import XCTest
import Foundation
@testable import Schrodinger

fileprivate enum FooError : Error {
    case bar
}

class SchrodingerTests: XCTestCase {
    
    func testDirectlyCompletedFutureAwait() throws {
        let value = 24
        
        let future = Future {
            return value
        }
        
        XCTAssertEqual(try future.await(for: .seconds(1)), value)
    }
    
    func testDelayedCompletionFutureAwait() throws {
        let value = 24
        
        let future = Future<Int> {
            Thread.sleep(forTimeInterval: 0.5)
            return value
        }
        
        XCTAssertEqual(try future.await(for: .seconds(1)), value)
    }
    
    func testVoidFutureThen() throws {
        let future = Future {}
        
        let thenExpectation = expectation(description: "The then closure is called")
        future.then {
            thenExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFutureIsCompleted() throws {
        let future = Future { Thread.sleep(forTimeInterval: 0.5) }
        XCTAssertFalse(future.isCompleted)
        try future.await(for: .seconds(1))
        XCTAssertTrue(future.isCompleted)
    }
    
    func testDirectlyErroringFutureCatch() throws {
        let future = Future { throw FooError.bar }
        
        let errorExpectation = expectation(description: "The catch closure is called")
        future.catch { error in
            XCTAssertEqual(error as? FooError, FooError.bar)
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testDelayedErroringFutureCatch() throws {
        let future = Future<Void> {
            Thread.sleep(forTimeInterval: 0.5)
            throw FooError.bar
        }
        
        let errorExpectation = expectation(description: "The catch closure is called")
        future.catch { error in
            XCTAssertEqual(error as? FooError, FooError.bar)
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFutureAwaitTimeouts() {
        let future = Future<Void>()
        future.then { XCTFail("The future is never completed, so this may never be called") }
        
        do {
            try future.await(for: .seconds(1))
            XCTFail()
        } catch FutureError.timeout(_) {
            // nothing, this should happen
        } catch {
            XCTFail("Wrong error was thrown")
        }
    }
    
//    func testFutureSequenceThen() {
//        let future1 = Future<Int> { return 1 }
//        let future2 = Future<Int> { return 2 }
//        let future3 = Future<Int> { return 3 }
//
//        [future1, future2, future3].then { results in
//            XCTAssertEqual(results.sorted(by: >), [1,2,3])
//        }
//    }
    
    func testCombinedVoidFuture() throws {
        var didFulfill1 = false
        
        let future1 = Future<Void> {
            Thread.sleep(forTimeInterval: 0.3)
            didFulfill1 = true
        }
        
        var didFulfill2 = false
        let future2 = Future<Void> {
            Thread.sleep(forTimeInterval: 0.6)
            
            didFulfill2 = true
        }
        
        let combinedFuture = Future<Void>([future1, future2])
        try combinedFuture.await(for: .seconds(1))
        
        XCTAssert(didFulfill1 && didFulfill2)
    }
    
}

