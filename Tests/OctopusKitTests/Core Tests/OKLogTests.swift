//
//  OKLogTests.swift
//  OctopusKitTests
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017-07-07.
//

import XCTest
@testable import OctopusKit

final class OKLogTests: XCTestCase {
    
    func testLog() {
        let logName = "Test Log"
        var testLog = OKLog(title: logName, useNSLog: false)
        XCTAssert(testLog.title == logName, "Log name does not match string it was initialized with.")
        
        let firstEntry = "First Log Entry"
        testLog.add(firstEntry)
        
        XCTAssert(testLog.lastEntryText     == firstEntry, "Logged entry does not match.")
        XCTAssert(testLog.entries[0].text   == firstEntry, "Logged entry does not match via subscript.")
        XCTAssert(testLog.entries.count     == 1, "Entries array does not have expected count.")
        
        let secondEntry = "Second Log Entry"
        testLog.add(secondEntry)
        
        XCTAssert(testLog.lastEntryText     == secondEntry, "Logged entry does not match.")
        XCTAssert(testLog.entries[1].text   == secondEntry, "Logged entry does not match via subscript.")
        XCTAssert(testLog.entries.count     == 2, "Entries array does not have expected count.")
    }
    
    static var allTests = [
        ("Test OKLog", testLog)
        ]
}
