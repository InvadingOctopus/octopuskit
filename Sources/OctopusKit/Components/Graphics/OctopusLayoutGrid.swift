//
//  OctopusLayoutGrid.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-11-24
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Cleanup and improve
// TODO: Add standard enumeration interface
// TODO: Add dynamic matrix resizing

import SpriteKit

public final class OctopusLayoutGridCell: SKNode {
    
    public let column, row: Int
    public let size: CGSize
    
    public var background: SKSpriteNode? {
        didSet {
            // Remove the old background anyway even if nil is passed.
            if let previousBackground = oldValue {
                previousBackground.removeFromParent()
            }
            if let newBackground = background {
                self.addChild(newBackground)
            }
        }
    }
    
    public override var frame: CGRect {
        return CGRect(
            origin: self.position,
            size: self.size)
    }
    
    /// Returns the cell's position converted to the coordinate system of the grid's parent (the cell's parent's parent.)
    public var positionInGridParent: CGPoint? {
        if let grid = self.parent as? OctopusLayoutGrid {
            if grid.parent != nil {
                return grid.convert(self.position, to: grid.parent!)
            }
        }
        return nil
    }
    
    public required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public init(column: Int, row: Int, size: CGSize) {
        self.column = column
        self.row = row
        self.size = size
        super.init()
    }
}

public final class OctopusLayoutGrid: SKNode {
    
    public static var cellSpacingDefault = CGSize(width: 8.0, height: 8.0)
    
    public let cellSize, cellSpacing, cellSizeWithSpacing: CGSize
    public let columns, rows: Int
    public let cellMatrix: [[OctopusLayoutGridCell]] // TODO: CHECK: Should this be immutable?
    
    public fileprivate(set) var size: CGSize
    
    public override var frame: CGRect {
        return CGRect(
            origin: self.position,
            size: self.size)
    }
    
    /// A flattened version of cellMatrix
    public fileprivate(set) lazy var cells: [OctopusLayoutGridCell] = self.getFlattenedCellArray()
    
    public subscript(column: Int, row: Int) -> OctopusLayoutGridCell {
        get {
            assert(isIndexValid(forColumn: column, row: row), "Index out of bounds")
            return cellMatrix[column][row]
        }
        // set {
        //     assert(isIndexValid(forColumn: column, row: row), "Index out of bounds")
        //     cellMatrix[column][row] = newValue
        // }
    }
    
    public var lastCell: OctopusLayoutGridCell {
        return cellMatrix[columns - 1][rows - 1]
    }
    
    // MARK: - Life Cycle
    
    public required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public init(
        columns: Int,
        rows: Int,
        cellSize: CGSize,
        cellSpacing: CGSize = OctopusLayoutGrid.cellSpacingDefault,
        reverseRowOrder: Bool = false,
        backgroundSpritesWithColor backgroundColor: SKColor? = nil)
    {
        assert(columns >= 1 && rows >= 1, "Invalid dimensions")
        
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
        self.cellSizeWithSpacing = cellSize + cellSpacing
        self.columns = columns
        self.rows = rows
//        self.cellMatrix = [[OctopusLayoutGridCell]]() //Array(repeating: Array(repeating: nil, count: rows),
                          //      count: columns)
        self.size = CGSize.zero
        
        // self.cellMatrix has to remain immutable and not a collection of Optionals.
        // TODO: Remove this hack
        var newCellMatrix = Array(repeating: Array(repeating: OctopusLayoutGridCell(column: 0, row: 0, size: CGSize.zero), count: rows),
                                  count: columns)
        
        for column in 0..<columns {
            for row in 0..<rows {
                //let newCell = SKNode()
                let newCell = OctopusLayoutGridCell(column: column, row: row, size: cellSize) //SKSpriteNode(color: .blue.alpha(0.15), size: cellSize)
                newCell.position.x = (cellSize.width + cellSpacing.width) * CGFloat(column)
                newCell.position.y = (cellSize.height + cellSpacing.height) * CGFloat(row)
                
                if reverseRowOrder {
                    newCellMatrix[column][rows - row - 1] = newCell // Reverse the order here since the drawing coordinates go from bottom to top, and the cellMatrix matrix numbers rows from top to bottom if reverseRowOrder = true.
                } else {
                    newCellMatrix[column][row] = newCell
                }
                
                if backgroundColor != nil {
                    let background = SKSpriteNode(color: backgroundColor ?? .clear, size: cellSize)
                    background.anchorPoint = CGPoint.zero
                    newCell.background = background
                }
                
//                self.addChild(newCell)
                
                self.size.width = newCell.position.x + cellSize.width
                self.size.height = newCell.position.y + cellSize.height
            }
        }
        
        self.cellMatrix = newCellMatrix
        
        super.init()
        
        for cell in self.cells {
            self.addChild(cell)
        }
        
    }
    
    public convenience init(
        columns: Int,
        rows: Int,
        cellDiagonalSize: CGFloat,
        cellDiagonalSpacing: CGFloat = OctopusLayoutGrid.cellSpacingDefault.width)
    {
        self.init(
            columns: columns,
            rows: rows,
            cellSize: CGSize(width: cellDiagonalSize, height: cellDiagonalSize),
            cellSpacing: CGSize(width: cellDiagonalSpacing, height: cellDiagonalSpacing))
    }
    
    deinit {
        OctopusKit.logForDeinits.add("size = \(size)")
    }
    
    // MARK: - Cell Management
    
    public func populateWithCopies(of node: SKNode) {
        for cell in cells {
            if let nodeCopy = node.copy() as? SKNode {
                nodeCopy.removeFromParent()
                nodeCopy.removeAllActions()
                cell.addChild(nodeCopy)
            }
        }
    }
    
    public func cell(at point: CGPoint) -> OctopusLayoutGridCell? {
        // TODO: Improve cell detection logic
        
        if let node = atPoint(point) as? OctopusLayoutGridCell { // Is the node under the point a Cell itself? Great!
            return node
        
        } else if let cell = atPoint(point).parent as? OctopusLayoutGridCell { // Or is it a direct child of a Cell?
            return cell
            
        } else { // Otherwise resort to enumerating all Cells and asking each of them.
            for cell in cells {
                if cell.contains(point) {
                    return cell
                    
                }
            }
        }
        
        return nil
    }
    
    /// Returns a flattened array of cellMatrix
    public func getFlattenedCellArray() -> [OctopusLayoutGridCell] {
        var array = [OctopusLayoutGridCell]()
        for column in 0..<columns {
            for row in 0..<rows {
                array.append(cellMatrix[column][row])
            }
        }
        return array
    }
    
    public func isIndexValid(forColumn column: Int, row: Int) -> Bool {
        return column >= 0 && column < columns && row >= 0 && row < rows
    }

}
