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
        
        // #3: Initializing with a literal sequence should correctly handle leftover columns.
        
        let fillerValue = -1
        
        XCTContext.runActivity(named: "Data Initialization with Fewer Columns and 1 Extra Row") { _ in
            
            let array1D = Array<Int>(1...3)
            let array2D = ContiguousArray2D(data:    array1D,
                                            columns: 2,
                                            repeatingInitialValueForLeftoverCells: fillerValue)!
            
            // #3A: A 2D array of 3 elements in 2 columns should correctly add 1 extra row.
            XCTAssertEqual(array2D.rowCount, 2)
            
            // #3B: The last (bottom-right) element should be the filler value.
            XCTAssertEqual(array2D[1, 1], fillerValue)
        }
        
        XCTContext.runActivity(named: "Data Initialization with Multiple Extra Rows") { _ in
            
            let array1D = Array<Int>(1...10)
            let array2D = ContiguousArray2D(data:    array1D,
                                            columns: 2,
                                            repeatingInitialValueForLeftoverCells: fillerValue)!
            
            // #3C: A 2D array of 10 elements in 2 columns should correctly add 4 extra rows.
            XCTAssertEqual(array2D.rowCount, 5)
            
            // #3D: The last element should have the correct data.
            XCTAssertEqual(array2D[array2D.lastColumnIndex, array2D.lastRowIndex],
                           array1D.last!)
        }
        
        XCTContext.runActivity(named: "Data Initialization with Fewer Data") { _ in
        
            let array1D = Array<Int>(1...3)
            let array2D = ContiguousArray2D(data:    array1D,
                                            columns: 5,
                                            repeatingInitialValueForLeftoverCells: fillerValue)!
            
            // #3C: A 2D array of 3 elements in 5 columns should have 1 row with filler values.
            XCTAssertEqual(array2D.rowCount, 1)
            for columnIndex in array1D.count ..< array2D.columnCount {
                XCTAssertEqual(array2D[columnIndex, 0], fillerValue)
            }
        }
        
        // #3D: Test with multiple dimensions.
        
        for elementCount in 1...10 {
            for columnCount in 1...10 {
                
                let array1D = Array<Int>(1...elementCount)
                let array2D = ContiguousArray2D(data:    array1D,
                                                columns: columnCount,
                                                repeatingInitialValueForLeftoverCells: -1)!
                
                // TODO: Don't use the `quotientAndRemainder` equation as that's what's used in `ContiguousArray2D` so it would always test equal; use a different method.
                
                let division = elementCount.quotientAndRemainder(dividingBy: columnCount)
                
                XCTAssertEqual(array2D.rowCount, division.quotient + division.remainder.signum())
            }
        }
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
