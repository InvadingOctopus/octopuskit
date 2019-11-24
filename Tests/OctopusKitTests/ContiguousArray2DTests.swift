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
    
    static let (columnCount, rowCount) = (3, 3)
    static var testArray2D: ContiguousArray2D<TestElement> = .init(columns: columnCount,
                                                                   rows: rowCount,
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
            columns: Self.columnCount,
            repeatingInitialValueForLeftoverCells: .invalid)
        
        XCTAssertNotNil (dataInitializedArray2D)
        XCTAssertEqual  (dataInitializedArray2D, Self.testArray2D)
        
        // #2: Copying an existing `ContiguousArray2D` storage should generate the same object.
        
        let copiedArray2D = ContiguousArray2D(existingStorage: Self.testArray2D.storage,
                                              columns: Self.columnCount,
                                              rows:    Self.rowCount)
        
        XCTAssertEqual  (copiedArray2D, Self.testArray2D)
    }
    
    func testSingleElementAccess() {
    
        let testArray2D = Self.testArray2D
        
        // #1A: The subscript should correctly return the expected elements.
        
        XCTAssertEqual(testArray2D[0, 0], .topLeft)
        XCTAssertEqual(testArray2D[1, 0], .topCenter)
        XCTAssertEqual(testArray2D[2, 0], .topRight)
        
        XCTAssertEqual(testArray2D[0, 1], .middleLeft)
        XCTAssertEqual(testArray2D[1, 1], .middleCenter)
        XCTAssertEqual(testArray2D[2, 1], .middleRight)
        
        XCTAssertEqual(testArray2D[0, 2], .bottomLeft)
        XCTAssertEqual(testArray2D[1, 2], .bottomCenter)
        XCTAssertEqual(testArray2D[2, 2], .bottomRight)
        
        // #1B: Test inequality.
        
        for row in 0 ..< Self.rowCount {
            for column in 0 ..< Self.columnCount {
                XCTAssertNotEqual(testArray2D[column, row], .invalid)
            }
        }
    }
    
    func testMultipleElementAccess() {
        
        let testArray2D = Self.testArray2D
        
        // #1A: row(_:) must correctly return an array of an entire row.
        XCTAssertEqual(testArray2D.row(0),      [.topLeft,    .topCenter,    .topRight])
        XCTAssertEqual(testArray2D.row(1),      [.middleLeft, .middleCenter, .middleRight])
        XCTAssertEqual(testArray2D.row(2),      [.bottomLeft, .bottomCenter, .bottomRight])
        
        // #1B: column(_:) must correctly return an array of an entire column.
        XCTAssertEqual(testArray2D.column(0),   [.topLeft,   .middleLeft,   .bottomLeft])
        XCTAssertEqual(testArray2D.column(1),   [.topCenter, .middleCenter, .bottomCenter])
        XCTAssertEqual(testArray2D.column(2),   [.topRight,  .middleRight,  .bottomRight])
        
        // Multiple rows
        
        let allRows = testArray2D.allRows()
        
        // #2A: `allRows()` should return the correct number of rows.
        XCTAssertEqual(allRows.count, Self.rowCount)
        
        // #2B: `allRows()` should return the correct rows.
        XCTAssertEqual(allRows[0],      [.topLeft,    .topCenter,    .topRight])
        XCTAssertEqual(allRows[1],      [.middleLeft, .middleCenter, .middleRight])
        XCTAssertEqual(allRows[2],      [.bottomLeft, .bottomCenter, .bottomRight])
        
        // Multiple columns
        
        let allColumns = testArray2D.allColumns()
        
        // #3A: `allColumns()` should return the correct number of columns.
        XCTAssertEqual(allColumns.count, Self.columnCount)
        
        // #3B: `allColumns()` should return the correct columns.
        XCTAssertEqual(allColumns[0],   [.topLeft,   .middleLeft,   .bottomLeft])
        XCTAssertEqual(allColumns[1],   [.topCenter, .middleCenter, .bottomCenter])
        XCTAssertEqual(allColumns[2],   [.topRight,  .middleRight,  .bottomRight])
    }
    
    func testSingleElementModification() {
        
    }
    
    func testMultipleElementModification() {
        
    }
    
    func toTest() {
        // TODO: Test rotation and flipping
        // TODO: Test viewports
        // TODO: Test memory with `Int` and other elements of known, fixed sizes.
        // TODO: Test memory sharing
    }
}
