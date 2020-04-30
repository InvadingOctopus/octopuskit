//
//  ContiguousArray2D.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A 2D array that supports viewports and rotation.
public struct ContiguousArray2D <Element> {
    
    // DECIDE: Should it be row-major indexing i.e. [row, column]? It seems to be the general convention, but [column, row] is more consistent with how we access (x,y) in graphics.
    
    // TODO: Interop with arrays of arrays, and literals
    // TODO: Viewports
    // TODO: Rotation
    // TODO: Standard collections protocols conformance
    // TODO: Improve naming
    // TODO: Tests
    
    // MARK: Subtypes
    
    public typealias IndexUnit = Int
    
    public enum Rotation: Int {
        case none       = 0
        case degrees90  = 90
        case degrees180 = 180
        case degrees270 = 270
    }
    
    // MARK: Properties
    
    // DESIGN: Most properties are not private or read-only so we can use @inlinable and let other components modify them if needed.
    
    public let columnCount, rowCount:   IndexUnit
    public var storage:                 ContiguousArray<Element>
    
    public var rotation:                Rotation = .none
    public var flippedHorizontally:     Bool = false
    public var flippedVertically:       Bool = false
    
    /// Transpose rows and columns.
    public var transpose:               Bool = false
    
    public var transformedColumnCount:  IndexUnit {
        didSet { endColumnIndex = transformedColumnCount - 1 }
    }
    
    public var transformedRowCount:     IndexUnit {
        didSet { endRowIndex = transformedRowCount - 1 }
    }
    
    public fileprivate(set) var startColumnIndex, startRowIndex: IndexUnit
    public fileprivate(set) var endColumnIndex,   endRowIndex:   IndexUnit
    
    // MARK: Initializers
    
    public init(columns: IndexUnit,
                rows:    IndexUnit,
                repeatingInitialValue: Element)
    {
        
        precondition(columns > 0, "columns < 1: \(columns)")
        precondition(rows    > 0, "rows < 1: \(rows)")
        
        self.columnCount            = columns
        self.rowCount               = rows
        self.transformedColumnCount = columnCount
        self.transformedRowCount    = rowCount
        self.startColumnIndex       = 0
        self.startRowIndex          = 0
        self.endColumnIndex         = columnCount - 1
        self.endRowIndex            = rowCount - 1
        
        self.storage = ContiguousArray(repeating: repeatingInitialValue,
                                       count: Int(rows * columns))
    }
    
    public init(existingStorage: ContiguousArray<Element>,
                columns: IndexUnit,
                rows:    IndexUnit)
    {
        
        precondition(columns > 0, "columns < 1: \(columns)")
        precondition(rows    > 0, "rows < 1: \(rows)")
        
        precondition(columns * rows <= existingStorage.count,
                     "columns × rows \(columns * rows) > existingStorage.count \(existingStorage.count)")
        
        self.rowCount               = rows
        self.columnCount            = columns
        self.transformedColumnCount = columnCount
        self.transformedRowCount    = rowCount
        self.startColumnIndex       = 0
        self.startRowIndex          = 0
        self.endColumnIndex         = columnCount - 1
        self.endRowIndex            = rowCount - 1
        
        self.storage = existingStorage
    }
    
    /// Constructs a 2D array from a 1D array or other linear sequence.
    ///
    /// - RETURNS: `nil` if `data` is empty.
    public init? <SequenceType> (data: SequenceType,
                                 columns: IndexUnit,
                                 repeatingInitialValueForLeftoverCells: Element)
        where SequenceType: Sequence,
        SequenceType.Element == Element
    {
        precondition(columns > 0, "columns < 1: \(columns)")
        
        self.storage = ContiguousArray(data)
        
        guard !storage.isEmpty else { return nil }
        
        self.columnCount = columns
        
        // Calculate rows, allocating an extra row if there are any leftover columns.
        
        let division = storage.count.quotientAndRemainder(dividingBy: columns)
        
        self.rowCount = division.quotient + division.remainder.signum() // 1 if > 0
        
        self.transformedColumnCount = columnCount
        self.transformedRowCount    = rowCount
        self.startColumnIndex       = 0
        self.startRowIndex          = 0
        self.endColumnIndex         = columnCount - 1
        self.endRowIndex            = rowCount - 1
        
        // Pad the leftover columns at the end.
        
        for _ in 0 ..< division.remainder {
            self.storage.append(repeatingInitialValueForLeftoverCells)
        }
    }
    
    // MARK: - Single Element Access
    
    /// Returns an index into the underlying 1D storage for the beginning of the specified row.
    @inlinable
    public func rowFirstIndexInStorage(for row: IndexUnit) -> IndexUnit {
        precondition(row >= 0 && row < rowCount,
                     "Row index (\(row)) is out of range (0 to \(rowCount - 1))")
        
        if rowCount == 1 { return 0 } // If there's just one row there's no need to do anything.
        
        return row * columnCount
    }
    
    /// Returns the element at `[column, row]`
    ///
    /// Affected by rotations and transformations.
    @inlinable
    public subscript(column: IndexUnit, row: IndexUnit) -> Element {
        
        get {
            precondition(column >= 0 && column < transformedColumnCount,
                         "Column index (\(column)) is out of range (0 to \(transformedColumnCount - 1))")
            precondition(row >= 0 && row < transformedRowCount,
                         "Row index (\(row)) is out of range (0 to \(transformedRowCount - 1))")
            
            return storage[row * columnCount + column]
        }
        
        set {
            precondition(column >= 0 && column < transformedColumnCount,
                         "Column index (\(column)) is out of range (0 to \(transformedColumnCount - 1))")
            precondition(row >= 0 && row < transformedRowCount,
                         "Row index (\(row)) is out of range (0 to \(transformedRowCount - 1))")
            
            return storage[row * columnCount + column] = newValue
        }
    }
    
    /// Writes the `elements` sequence into the array starting at the specified column and row, overwriting existing elements and ignoring any elements which may not fit.
    ///
    /// - Returns: An array of elements which were written.
    @inlinable
    @discardableResult
    public mutating func overwrite(startingColumn: IndexUnit,
                                   startingRow:    IndexUnit,
                                   elements:       AnySequence<Element>) -> [Element]
    {
        // TODO
        return []
    }
    
    // MARK: - Multiple Element Access
    
    @inlinable
    public func column(_ columnIndex: IndexUnit) -> ArraySlice<Element> {
        
        precondition(columnIndex >= 0 && columnIndex < transformedColumnCount,
                     "Column index (\(columnIndex)) is out of range (0 to \(transformedColumnCount - 1))")
        
        var column: ArraySlice<Element> = []
        
        for row in 0 ..< transformedRowCount {
            column.append(self[columnIndex, row]) // ❕ Use the subscript so we can get rotated/flipped transformations, if any.
        }
        
        return column
    }
    
    @inlinable
    public func row(_ rowIndex: IndexUnit) -> ArraySlice<Element> {
        
        precondition(rowIndex >= 0 && rowIndex < transformedRowCount,
                     "Row index (\(rowIndex)) is out of range (0 to \(transformedRowCount - 1))")
        
        var row: ArraySlice<Element> = []
        
        for column in 0 ..< transformedColumnCount {
            row.append(self[column, rowIndex]) // ❕ Use the subscript so we can get rotated/flipped transformations, if any.
        }
        
        return row
    }
    
    @inlinable
    public func allColumns() -> [ArraySlice<Element>] {
        
        var columns: [ArraySlice<Element>] = []
        for columnIndex in 0 ..< transformedColumnCount {
            columns.append(self.column(columnIndex))
        }
        return columns
    }
    
    @inlinable
    public func allRows() -> [ArraySlice<Element>] {
        
        var rows: [ArraySlice<Element>] = []
        for rowIndex in 0 ..< transformedRowCount {
            rows.append(self.row(rowIndex))
        }
        return rows
    }
    
    // MARK: - Advanced Operations

    
    /// Returns a smaller section of the 2D array, using the existing underlying storage.
    @inlinable
    @available(*, unavailable, message: "Not Yet Implemented")
    public func viewport(x: Int, y: Int, width: Int, height: Int) -> Self {
        
        // Check arguments.
        
        precondition(x >= 0 && x < columnCount,
                     "x (origin column index: \(x)) is out of range (0 to \(columnCount - 1))")
        precondition(y >= 0 && y < rowCount,
                     "y (origin row index: \(y)) is out of range (0 to \(rowCount - 1))")
        
        precondition(width >= 1 && width <= columnCount,
                     "width (\(width)) is out of range (1 to \(columnCount))")
        precondition(height >= 1 && height <= rowCount,
                     "height (\(height)) is out of range (1 to \(rowCount))")
        
        let right  = x + width
        let bottom = y + height
        
        precondition(right >= 0 && right < columnCount,
                     "right (x + width: \(right)) is out of range (0 to \(columnCount - 1))")
        precondition(bottom >= 0 && bottom < rowCount,
                     "y (y + height: \(bottom)) is out of range (0 to \(rowCount - 1))")
        
        // Build a stack of rows.
        
        var rows: [ArraySlice<Element>] = []
        
        for row in y...height {
            let rowStart = self.rowFirstIndexInStorage(for: row)
            rows.append(self.storage[rowStart ..< (rowStart + width)])
        }
        
        // Create a new 2D array from the rows.
        
        // TODO
        
        return self
    }
    
    @available(*, unavailable, message: "Not Yet Implemented")
    public mutating func rotateClockwise() {
        // TODO
    }
    
    @available(*, unavailable, message: "Not Yet Implemented")
    public mutating func rotateCounterClockwise() {
        // TODO
    }
    
    // MARK: - Miscellaneous
    
    /// Returns the column and row coordinates (in a tuple) for the specific index in the underlying 1D storage array.
    ///
    /// Respects transformations.
    @inlinable
    public func coordinatesForStorageIndex(_ index: IndexUnit) -> (column: IndexUnit, row: IndexUnit) {
        
        precondition(index >= 0 && index < storage.endIndex,
                     "index \(index) is out of range (0 to \(storage.endIndex - 1))")
        
        let division = index.quotientAndRemainder(dividingBy: transformedColumnCount) // quotient = row, remainder = column
        
        return (column: division.remainder,
                row:    division.quotient)
    }

}

// MARK: - Protocol Conformance

// MARK: Equatable

extension ContiguousArray2D: Equatable where Element: Equatable {
    
    public static func == (left: ContiguousArray2D, right: ContiguousArray2D) -> Bool {
        return (left.storage             == right.storage
            &&  left.columnCount         == right.columnCount
            &&  left.rowCount            == right.rowCount
            &&  left.rotation            == right.rotation
            &&  left.flippedHorizontally == right.flippedHorizontally
            &&  left.flippedVertically   == right.flippedVertically)
    }
}

// MARK: CustomStringConvertible

extension ContiguousArray2D: CustomStringConvertible {
    
    /// Returns a textual representation of the grid of elements, i.e. for printing in the debug console.
    ///
    /// Inserts a single space between columns. Element descriptions may be provided via their implementation of `CustomStringConvertible` or `CustomDebugStringConvertible`.
    @inlinable
    public var description: String {
        // TODO: Include other properties
        // TODO: PERFORMANCE
        var gridRepresentation = ""
        for row in 0 ..< rowCount {
            
            for column in 0 ..< columnCount {
                let element = self[column, row]
                gridRepresentation += (column < columnCount) ? "\(element) " : "\(element)"
            }
            
            if  row < rowCount - 1 {
                gridRepresentation += "\n"
            }
        }
        return gridRepresentation
    }
}
