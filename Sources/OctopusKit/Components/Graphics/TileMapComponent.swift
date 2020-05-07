//
//  TileMapComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/19.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A container for one or more `SKTileMapNode` layers and their associated tile set, tile groups, and map layouts.
///
/// To add to a scene, use `NodeComponent(node:)` with this component's `containerNode`.
open class TileMapComponent: OKComponent {
    
    // TODO: Option for using `NoiseComponent`
    
    // ℹ️ Hierarchy: Tile Map -> Tile Set -> Tile Groups -> Tile Definition
    
    // MARK: Subtypes
    
    /// A closure called by `TileMapComponent` to generate a tile for the given row and column.
    ///
    /// - Parameter component: A reference to `self`; the instance of `TileMapComponent` that this closure is called by.
    ///
    ///     You can use this to access the instance properties of this component, such as its associated entity and co-components.
    ///
    ///     **Example:** `component.coComponent(ofType: NoiseMapComponent.self)?.noiseMap`
    ///
    /// - Parameter tileMap: The `SKTileMapNode` that the returned `SKTileGroup` will be placed in.
    /// - Parameter tileSet: The `SKTileSet` used by the `SKTileMapNode` being built.
    /// - Parameter column: The column number of the map tile in which the returned `SKTileGroup` will be placed in.
    /// - Parameter row: The row number of the map tile in which the returned `SKTileGroup` will be placed in.
    /// - Parameter noiseValue: The noise value at the corresponding position in a `NoiseMapComponent`, if available, otherwise `nil`.
    ///
    /// - Returns: An `SKTileGroup` to be applied to the map tile at the specified `column` and `row` in the `tileMap`. If this is `nil` then the tile is cleared.
    public typealias MapBuilderClosureType = (
        _ component:    TileMapComponent,
        _ tileMap:      SKTileMapNode,
        _ tileSet:      SKTileSet,
        _ column:       Int,
        _ row:          Int,
        _ noiseValue:   Float?)
        -> SKTileGroup?
    
    // MARK: - Properties
    
    public let tileSet:         SKTileSet
    public let tileSize:        CGSize
    public let columns, rows:   Int

    /// The container node is reset when this array is modified.
    public var layers:          [SKTileMapNode] = [] {
        didSet {
            if  layers != oldValue {
                resetContainerNode()
            }
        }
    }
    
    /// The node containing all the tile map layers.
    public let containerNode = SKNode()
    
    /// The difference in the `zPosition` of each tile map layer, starting from `0` for the first layer.
    public var zPositionSpacing: CGFloat = 10
    
    public init?(tileSet:    SKTileSet,
                 tileSize:   CGSize? = nil,
                 columns:    Int,
                 rows:       Int,
                 layers:     Int = 1)
    {
        guard columns > 0 else { OctopusKit.logForErrors("columns < 1: \(columns)"); return nil }
        guard rows    > 0 else { OctopusKit.logForErrors("rows < 1: \(rows)");       return nil }
        guard layers  > 0 else { OctopusKit.logForErrors("layers < 1: \(layers)");   return nil }
        
        if  let tileSize = tileSize {
            guard  tileSize.width  > 0
                && tileSize.height > 0
                else { OctopusKit.logForErrors("Invalid tileSize: \(tileSize)");     return nil }
            
            self.tileSize = tileSize
        } else {
            self.tileSize = tileSet.defaultTileSize
        }
        
        self.tileSet    = tileSet
        self.columns    = columns
        self.rows       = rows
        
        super.init()
        
        // Add the layers.
        
        for _ in 0 ..< layers {
            let layer = SKTileMapNode(tileSet:    tileSet,
                                      columns:    columns,
                                      rows:       rows,
                                      tileSize:   self.tileSize)
            self.layers.append(layer)
        }
        
        self.resetLayerZPositions()
        self.resetContainerNode()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Container Node Management
    
    /// Sets the Z position of each tile map according to its place in the layers array, with a Z position of `0` for the first layer, increasing by `zPositionSpacing` for each layer.
    public func resetLayerZPositions() {
        for index in 0 ..< layers.endIndex {
            layers[index].zPosition = zPositionSpacing * CGFloat(index)
        }
    }
    
    /// Resets the `containerNode` by removing all its children, resetting the `zPosition` of each tile map layer then adding each layer to the `containerNode`.
    public func resetContainerNode() {
        containerNode.removeAllChildren()
        resetLayerZPositions()
        containerNode.addChildren(layers)
    }
    
    // MARK: - Map Modification
    
    @inlinable
    public func validateLayerIndex(_ index: Int) -> Bool {
        guard !layers.isEmpty else {
            OctopusKit.logForErrors("No tile map layers in \(self)")
            return false
        }
        guard index.isWithin(0 ..< layers.endIndex) else {
            OctopusKit.logForErrors("Layer index outside 0...\(layers.endIndex - 1): \(index)")
            return false
        }
        return true
    }
    
    /// Fills the specified layer with the specified tile group.
    @inlinable
    public func fill(layer index: Int, with tileGroup: SKTileGroup) {
        guard validateLayerIndex(index) else { return }
        self.layers[index].fill(with: tileGroup)
    }
    
    /// Fills the specified layer with the first tile group in the tile set that matches the specified name, if any.
    @inlinable
    public func fill(layer index: Int, with tileGroupName: String) {
        if  let tileGroup = self.tileSet.tileGroups[tileGroupName].first {
            fill(layer: index, with: tileGroup)
        }
    }
    
    
    /// Generates the map tile-by-tile, using the supplied closure.
    /// - Parameters:
    ///   - index: The index of the tile map layer to build.
    ///   - usingNoiseMap: If `true`, the entity's `NoiseMapComponent` will be used to provide noise values for the builder closure.
    ///   - reversingRowOrder: By default, `SKTileMap` and `GKNoiseMap` rows are indexed from bottom to top. If this flag is `true`, then the rows are built from top to bottom, matching the common convention of bitmaps and other 2D arrays.
    ///   - builder: This closure will be called for each map tile, painting the tile with the `SKTileGroup` returned by the closure. See documentation for the `MapBuilderClosureType` type alias for a description of each closure parameter.
    @inlinable
    public func build(layer index:       Int,
                      usingNoiseMap:     Bool = false,
                      reversingRowOrder: Bool = false,
                      with builder:      MapBuilderClosureType)
    {
        // CHECK: Should this be named `generate` instead of `build`?
        // CHECK: PERFORMANCE: Should there be a separate version where the `noiseValue` isn't optional?
        
        guard validateLayerIndex(index) else { return }
        
        let layer    = layers[index]
        let noiseMap = coComponent(NoiseMapComponent.self)?.noiseMap
        
        // NOTE: A NoiseMapComponent only initializes its `noiseMap` property when it's added to an entity with a NoiseComponent.
        // If we're using a noise map, verify that we have a NoiseMapComponent with a valid noise map.
        
        if  usingNoiseMap {
            if  let noiseMap = noiseMap {
                guard
                    layer.numberOfColumns <= noiseMap.sampleCount.x,
                    layer.numberOfRows    <= noiseMap.sampleCount.y
                else {
                    OctopusKit.logForWarnings("Mismatching dimensions: Tile Map: (\(layer.numberOfColumns), \(layer.numberOfRows) — Noise Map: \(noiseMap.sampleCount)")
                    return
                }
            } else {
                OctopusKit.logForWarnings("\(entity) has no NoiseMapComponent")
                return
            }
        }
        
        // Iterate over each row and column.
        
        var position  = vector_int2.zero
        var noiseValue: Float?
        var tileGroup:  SKTileGroup?
        
        // ❕ NOTE: `SKTileMapNode` and `GKNoiseMap` index elements starting from the bottom-left at `(0,0)` with rows increasing upwards, but 2D arrays and bitmaps may have the convention of indexing from the top-left with rows increasing downwards. Hence this option of reversing the row order. :)
        
        let firstRow, lastRow, rowIncrement: Int
        
        if  !reversingRowOrder {
            firstRow     = 0
            lastRow      = layer.numberOfRows - 1
            rowIncrement = 1
        } else {
            firstRow     = layer.numberOfRows - 1
            lastRow      = 0
            rowIncrement = -1
        }
        
        for row in stride(from: firstRow, through: lastRow, by: rowIncrement) {
            for column in 0 ..< layer.numberOfColumns {
                
                position    = vector_int2(x: Int32(row), y: Int32(column))
                noiseValue  = noiseMap?.value(at: position)
                
                tileGroup   = builder(self,     // TileMapComponent
                                      layer,    // SKTileMapNode
                                      tileSet,
                                      column,
                                      row,
                                      noiseValue)
                
                layer.setTileGroup(tileGroup, forColumn: column, row: row)
            }
        }
    }
}

/// A list of names of tile groups in a tile set. Write an `extension` to populate this `struct` with a custom list of tile group names as `static` constants. See the documentation for `TypeSafeIdentifiers`.
public struct TileGroupName: TypeSafeIdentifiers {
    public let rawValue: String
    public init(rawValue: RawValueType) { self.rawValue = rawValue } // Because Swift won't let the synthesized init be implicitly public :(
}

