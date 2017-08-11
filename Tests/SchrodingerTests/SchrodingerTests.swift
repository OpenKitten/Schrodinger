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
    
}

