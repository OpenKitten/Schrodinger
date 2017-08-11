import XCTest
import Foundation
@testable import Schrodinger

class SchrodingerTests: XCTestCase {
    
    func testFutureAwait() throws {
        let value = 24
        
        let future = Future {
            return value
        }
        
        XCTAssertEqual(try future.await(for: .seconds(1)), value)
    }
    
}

