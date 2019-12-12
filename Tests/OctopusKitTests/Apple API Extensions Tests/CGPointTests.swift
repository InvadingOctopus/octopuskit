//
//  CGPointTests.swift
//  OctopusKitTests
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/DD.
//

import XCTest
@testable import OctopusKit

class CGPointTests: XCTestCase {

    // TODO: Test all extensions from `CGPoint+OctopusKit`
    
    let fixedPoint = CGPoint.zero
    
    /// Test various convenience initializers and methods.
    func testConveniences() {
        let random = CGFloat.random(in: 1.0...10.0)
        
        // `CGVector` conversion.
        let vector = CGVector(dx: random, dy: random)
        XCTAssertEqual(CGPoint(vector), CGPoint(x: random, y: random))
        
        // `SIMD2<Float>` conversion.
        let randomFloat = Float.random(in: 1.0...10.0) // ❕ Otherwise the assertion may fail due to rounding/precision errors.
        let simdFloat  = SIMD2<Float>(x: randomFloat, y: randomFloat)
        XCTAssertEqual(CGPoint(simdFloat), CGPoint(x: CGFloat(randomFloat), y: CGFloat(randomFloat)))
        
        // Miscellaneous.
        XCTAssertEqual(CGPoint.half, CGPoint(x: 0.5, y: 0.5))
    }
    
    /// Test custom operators.
    func testOperators() {
        let xA     = CGFloat.random(in: -100...100)
        let yA     = CGFloat.random(in: -100...100)
        let xB     = CGFloat.random(in: -100...100)
        let yB     = CGFloat.random(in: -100...100)
        let pointA = CGPoint(x: xA, y: yA)
        let pointB = CGPoint(x: xB, y: yB)
        
        XCTAssertEqual(pointA + pointB, CGPoint(x: xA + xB, y: yA + yB))
        XCTAssertEqual(pointA - pointB, CGPoint(x: xA - xB, y: yA - yB))
        XCTAssertEqual(pointA * pointB, CGPoint(x: xA * xB, y: yA * yB))
        XCTAssertEqual(pointA / pointB, CGPoint(x: xA / xB, y: yA / yB))
    }
    
    /// Test `CGPoint.distance(to:)`
    func testDistance() {
        
        var movingPoint: CGPoint
        
        // #1: Test known distances.
        
        movingPoint = CGPoint(x: 1, y: 0)
        XCTAssertEqual(fixedPoint.distance(to: movingPoint), 1)
        
        movingPoint = CGPoint(x: 0.5, y: 0)
        XCTAssertEqual(fixedPoint.distance(to: movingPoint), 0.5)
        
        movingPoint = CGPoint(x: 0, y: 0.5)
        XCTAssertEqual(fixedPoint.distance(to: movingPoint), 0.5)
        
        movingPoint = CGPoint(x: 1, y: 1)
        XCTAssertEqual(fixedPoint.distance(to: movingPoint), sqrt(2)) // width² + height² = hypotenuse²
        
        movingPoint = CGPoint(x: 0.5, y: 0.5)
        XCTAssertEqual(fixedPoint.distance(to: movingPoint), sqrt(0.5))
        
        // #2: Test random distances.
        
        for _ in 1...100 {
            
            let randomDistance = CGFloat.random(in: 0...100)
            
            // #2A: Test horizontal distance.
            movingPoint = CGPoint(x: randomDistance, y: fixedPoint.y)
            XCTAssertEqual(fixedPoint.distance(to: movingPoint), randomDistance)
            
            // #2B: Test vertical distance.
            movingPoint = CGPoint(x: fixedPoint.x, y: randomDistance)
            XCTAssertEqual(fixedPoint.distance(to: movingPoint), randomDistance)
        
            // #2C: Negative coordinates should report the same positive distance.
            
            movingPoint = CGPoint(x: -randomDistance, y: fixedPoint.y)
            XCTAssertEqual(fixedPoint.distance(to: movingPoint), abs(randomDistance))
            
            movingPoint = CGPoint(x: fixedPoint.x, y: -randomDistance)
            XCTAssertEqual(fixedPoint.distance(to: movingPoint), abs(randomDistance))
            
            // #2D: Two points should report the same distance to each other.
            
            let pointA = CGPoint(x: .random(in: 0...100),
                                 y: .random(in: 0...100))
            
            let pointB = CGPoint(x: .random(in: 0...100),
                                 y: .random(in: 0...100))
            
            XCTAssertEqual(pointA.distance(to: pointB),
                           pointB.distance(to: pointA))
        }
    }

    /// Test `CGPoint.radians(to:)`
    func testRadians() {
     
        // https://en.wikipedia.org/wiki/Unit_circle
        // https://en.wikipedia.org/wiki/Trigonometric_constants_expressed_in_real_radicals#Table_of_some_common_angles
        
        let π          =  CGFloat.pi
        let degrees45  =  π / 4         // ↗️
        let degrees90  =  π / 2         // ⬆️
        let degrees135 = (π * 3) / 4    // ↖️ 3π ÷ 4
        let degrees180 =  π             // ⬅️
        
        // Lower/southern quadrants have negative values, inverses of their northern counterparts.
        
        let degrees225 = (-π * 3) / 4   // ↙️ 5π ÷ 4
        let degrees270 =  -π / 2        // ⬇️ 3π ÷ 2
        let degrees315 =  -π / 4        // ↘️ 7π ÷ 4
        
        // #1: Test common angles and cardinal directions.
        // East/right should be `0` in radians, with positive values indicating counter-clockwise rotation.
        // Should return closest angle; southern quadrants should return a positive value for clockwise rotation.
        
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x:  0, y:  0)), 0)            // Center/Identity
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x:  1, y:  0)), 0)            // ➡️
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x:  1, y:  1)), degrees45)    // ↗️
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x:  0, y:  1)), degrees90)    // ⬆️
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x: -1, y:  1)), degrees135)   // ↖️
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x: -1, y:  0)), degrees180)   // ⬅️
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x: -1, y: -1)), degrees225)   // ↙️
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x:  0, y: -1)), degrees270)   // ⬇️
        XCTAssertEqual(fixedPoint.radians(to: CGPoint(x:  1, y: -1)), degrees315)   // ↘️
        
        // TODO: More tests
    }
    
    static var allTests = [
        ("Test convenience extensions", testConveniences),
        ("Test operators", testOperators),
        ("Test distance(to:)", testDistance),
        ("Test radians(to:)", testRadians)
    ]
}
