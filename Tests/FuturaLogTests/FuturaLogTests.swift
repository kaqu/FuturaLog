import XCTest

@testable import FuturaLog

class FuturaLogTests: XCTestCase {

    func testLogs() {
        Logger.addReciever(LogPrinter())
        Logger.send(.debug, message: "TEST")
        sleep(3)
    }
}
