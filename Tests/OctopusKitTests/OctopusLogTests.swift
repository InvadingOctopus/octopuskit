//
//  OctopusLogTests.swift
//  OctopusKit Tests
//
//  Created by ShinryakuTako on 2017-07-07.
//

import XCTest
@testable import OctopusKit

class OctopusLogTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testLog() {
        let logName = "Test Log"
        var testLog = OctopusLog(title: logName, copiesToNSLog: false)
        XCTAssert(testLog.title == logName, "Log name does not match string it was initialized with.")
        
        let firstEntry = "First Log Entry"
        testLog.add(firstEntry)
        
        XCTAssert(testLog.lastEntryText == firstEntry, "Logged entry does not match.")
        XCTAssert(testLog.entries[0].text! == firstEntry, "Logged entry does not match via subscript.")
        XCTAssert(testLog.entries.count == 1, "Entries array does not have expected count.")
        
        let secondEntry = "Second Log Entry"
        testLog.add(secondEntry)
        
        XCTAssert(testLog.lastEntryText == secondEntry, "Logged entry does not match.")
        XCTAssert(testLog.entries[1].text! == secondEntry, "Logged entry does not match via subscript.")
        XCTAssert(testLog.entries.count == 2, "Entries array does not have expected count.")
    }
    
    static var allTests = [
        ("testLog", testLog),
        ]
}
