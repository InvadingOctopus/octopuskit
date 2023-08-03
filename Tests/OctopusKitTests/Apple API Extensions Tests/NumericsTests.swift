//
//  NumericsTests.swift
//  OctopusKitTests
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/24.
//

import XCTest
@testable import OctopusKit

class NumericsTests: XCTestCase {

    func testAdditiveArithmetic() {
        
        // Test adjustTowards(_:by:)
        
        // #1: Test integers
        
        XCTContext.runActivity(named: "Test integers") { _ in
            var value: Int = 10
            
            // #1A: Difference = 1
            XCTAssertEqual(value.adjustedTowards(0,    by: 1), 9)
            XCTAssertEqual(value.adjustedTowards(100,  by: 1), 11)
            
            // #1B: Difference > 1
            XCTAssertEqual(value.adjustedTowards(0,    by: 5), 5)
            XCTAssertEqual(value.adjustedTowards(100,  by: 5), 15)
            
            // #1C: Exceeding the target should snap to the target.
            XCTAssertEqual(value.adjustedTowards(0,    by: 1000), 0)
            XCTAssertEqual(value.adjustedTowards(100,  by: 1000), 100)
            
            // #1D: Negatives
            value = -10
            XCTAssertEqual(value.adjustedTowards( 100, by: 1), -9)
            XCTAssertEqual(value.adjustedTowards(-100, by: 1), -11)
            
            // #1E: Mutation
            value = 10
            value.adjustTowards(0, by: 1)
            XCTAssertEqual(value, 9)
        }
        
        // #2: Test floats
        
        XCTContext.runActivity(named: "Test floats") { _ in
            var value: Float = 10.0
            
            // #2A: Difference = 0.1
            XCTAssertEqual(value.adjustedTowards(0.1,   by: 0.1),  9.9)
            XCTAssertEqual(value.adjustedTowards(100,   by: 0.1),  10.1)
            
            // #2B: Difference = 1.0
            XCTAssertEqual(value.adjustedTowards(0.1,   by: 1.0),  9.0)
            XCTAssertEqual(value.adjustedTowards(100,   by: 1.0),  11.0)
            
            // #2C: Exceeding the target should snap to the target.
            XCTAssertEqual(value.adjustedTowards(0.1,   by: 10.1), 0.1)
            XCTAssertEqual(value.adjustedTowards(9.1,   by: 10.1), 9.1)
            
            // #2D: Negatives
            value = -10
            XCTAssertEqual(value.adjustedTowards(0.1,   by: 0.1), -9.9)
            XCTAssertEqual(value.adjustedTowards(-90.9, by: 0.1), -10.1)
            
            // #2E: Mutation
            value = 10.0
            value.adjustTowards(0.1, by: 1)
            XCTAssertEqual(value, 9.0)
        }
        
    }

    func testFloatingPoint() {
        
        // TODO: #1: Test percent(_:)
        
        /* NOTE: This test will fail because you're not supposed to directly compare floating point numbers.
         
        XCTContext.runActivity(named: "Test percent") { _ in
            
            // #1A: N% of 100 should be N
            
            for percent in 0...100 {
                XCTAssertTrue(100.percent(Double(percent)).isEqual(to: Double(percent)))
            }
        }
        */
        
        // TODO: #2: Test percent(of:)
    }
    
    static var allTests = [
        ("Test AdditiveArithmetic extensions", testAdditiveArithmetic),
        ("Test FloatingPoint extensions", testFloatingPoint)
    ]
}
