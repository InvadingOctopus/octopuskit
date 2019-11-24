//
//  ContiguousArray2DTests.swift
//  OctopusKitTests
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/5.
//

import XCTest
@testable import OctopusKit

final class ContiguousArray2DTests: XCTestCase {

    // MARK: - Setup
    
    enum TestElement: Character, CaseIterable {
        case invalid        = "❌"
        
        case topLeft        = "↖️"
        case topCenter      = "⬆️"
        case topRight       = "↗️"
        
        case middleLeft     = "⬅️"
        case middleCenter   = "⏺"
        case middleRight    = "➡️"
        
        case bottomLeft     = "↙️"
        case bottomCenter   = "⬇️"
        case bottomRight    = "↘️"
    }
    
    static let (columns, rows) = (3, 3)
    static var testArray2D: ContiguousArray2D<TestElement> = .init(columns: columns,
                                                                   rows: rows,
                                                                   repeatingInitialValue: .invalid)
    
    override class func setUp() {
        testArray2D[0, 0] = .topLeft
        testArray2D[1, 0] = .topCenter
        testArray2D[2, 0] = .topRight
        
        testArray2D[0, 1] = .middleLeft
        testArray2D[1, 1] = .middleCenter
        testArray2D[2, 1] = .middleRight
        
        testArray2D[0, 2] = .bottomLeft
        testArray2D[1, 2] = .bottomCenter
        testArray2D[2, 2] = .bottomRight
    }
    
    // MARK: - Tests
    
    func testInitializers() {
        
        // #1: Initializing a `ContiguousArray2D` from a 1D sequence should generate the same 2D array as a manual cell-wise assignment of elements.
        
        let flatArray1D: Array<TestElement> = [.topLeft,    .topCenter,    .topRight,
                                               .middleLeft, .middleCenter, .middleRight,
                                               .bottomLeft, .bottomCenter, .bottomRight]
        
        let dataInitializedArray2D = ContiguousArray2D (
            data:    flatArray1D,
            columns: Self.columns,
            repeatingInitialValueForLeftoverCells: .invalid)
        
        XCTAssertNotNil (dataInitializedArray2D)
        XCTAssertEqual  (dataInitializedArray2D, Self.testArray2D)
        
        // #2: Copying an existing `ContiguousArray2D` storage should generate the same object.
        
        let copiedArray2D = ContiguousArray2D(existingStorage: Self.testArray2D.storage,
                                            columns: Self.columns,
                                            rows: Self.rows)
        
        XCTAssertEqual  (copiedArray2D, Self.testArray2D)
    }
    
    func toTest() {
        // TODO: Test rotation and flipping
        // TODO: Test viewports
        // TODO: Test memory with `Int` and other elements of known, fixed sizes.
        // TODO: Test memory sharing
    }
}
