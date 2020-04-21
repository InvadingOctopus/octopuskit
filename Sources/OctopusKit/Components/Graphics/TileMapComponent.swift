//
//  TileMapComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/19.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A container for one or more `SKTileMapNode` layers and their associated tile set, tile groups, and map layouts.
public class TileMapComponent: OKComponent {
    
    // TODO: Option for using `NoiseComponent`
    
    // Hierarchy: Tile Map -> Tile Set -> Tile Groups -> Tile Definition
    
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
        guard columns > 0 else { OctopusKit.logForErrors.add("columns < 1: \(columns)"); return nil }
        guard rows    > 0 else { OctopusKit.logForErrors.add("rows < 1: \(rows)");       return nil }
        guard layers  > 0 else { OctopusKit.logForErrors.add("layers < 1: \(layers)");   return nil }
        
        if  let tileSize = tileSize {
            guard  tileSize.width  > 0
                && tileSize.height > 0
                else { OctopusKit.logForErrors.add("Invalid tileSize: \(tileSize)");     return nil }
            
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
        
        for layer in layers {
            containerNode.addChild(layer)
        }
    }
    
    // MARK: - Map Modification
    
    @inlinable
    public func validateLayerIndex(_ index: Int) -> Bool {
        guard !layers.isEmpty else {
            OctopusKit.logForErrors.add("No tile map layers in \(self)")
            return false
        }
        guard index.isWithin(0 ..< layers.endIndex) else {
            OctopusKit.logForErrors.add("Layer index outside 0...\(layers.endIndex - 1): \(index)")
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
    
    @inlinable
    public func build(layer index:   Int,
                      usingNoiseMap: Bool = false,
                      with builder:  MapBuilderClosureType)
    {
        // CHECK: Should this be named `generate` instead of `build`?
        
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
                    OctopusKit.logForWarnings("Mismatching dimensions: Tile Map: \(layer.size) — Noise Map: \(noiseMap.sampleCount)")
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
        
        for row in 0...layer.numberOfRows {
            for column in 0...layer.numberOfColumns {
                
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

