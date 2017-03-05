import XCTest
@testable import Schrodinger

class SchrodingerTests: XCTestCase {
    func testExample() {
        let string = async(hello)
        XCTAssertEqual(try string.await(), "world")
    }

    func hello() -> String {
        sleep(2)
        return "world"
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
