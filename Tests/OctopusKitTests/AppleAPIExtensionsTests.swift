//
//  AppleAPIExtensionsTests.swift
//  OctopusKitTests
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/12.
//

import XCTest
@testable import OctopusKit

class AppleAPIExtensionsTests: XCTestCase {

    func testString() {
        
        var string: String
        
        let optionalInt: Int? = 1234
        let nilInt: Int? = nil
        
        // #1: Optional Interpolation should raise no warnings
        // like "String interpolation produces a debug description for an optional value; did you mean to make this explicit?"
        // and the named argument version and the unlabeled argument version should be the same.
        
        string = "\(optionalInt)"
        print           (string)
        XCTAssertEqual  (string, "1234")
        XCTAssertEqual  (string, "\(optional: optionalInt)")
        
        string = "\(nilInt)"
        print           (string)
        XCTAssertEqual  (string, "nil")
        XCTAssertEqual  (string, "\(optional: nilInt)")
        
        // #2: We should be able to get the default behavior back.
        
        string = String (describing: optionalInt)
        print           (string)
        XCTAssertEqual  (string, "Optional(1234)")
        
        string = String (describing: nilInt)
        print           (string)
        XCTAssertEqual  (string, "nil")
        
    }

    static var allTests = [
        ("Test String", testString)
    ]
}
