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
    
    // Hierarchy: Tile Map -> Tile Set -> Tile Groups -> Tile Definition
    
    // DESIGN: Not `final` because games may want to subclass it to add more complex functionality.
    
    public let tileSet:        SKTileSet
    public let tileSize:       CGSize
    public let columns, rows:  Int
    
    public var layers: [SKTileMapNode] = []
    
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
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Map Modification
    
    @inlinable
    public func fill(layer index: Int, with tileGroup: SKTileGroup) {
        guard
            !layers.isEmpty,
            index.isWithin(0..<layers.endIndex)
        else {
            OctopusKit.logForErrors.add ("index outside 0...\(layers.endIndex - 1): \(index)")
            return
        }
        
        self.layers[index].fill(with: tileGroup)
    }
    
    /// Fills the specified layer with the first tile group in the tile set that matches the specified name, if any.
    @inlinable
    public func fill(layer index: Int, with tileGroupName: String) {
        if  let tileGroup = self.tileSet.tileGroups[tileGroupName].first {
            fill(layer: index, with: tileGroup)
        }
    }
}

/// Write an `extension` to populate this `struct` with a custom list of tile group names as `static` constants. See the documentation for `TypeSafeIdentifiers`.
public struct TileGroupName: TypeSafeIdentifiers {
    public let rawValue: String
    public init(rawValue: RawValueType) { self.rawValue = rawValue } // Because Swift won't let the synthesized init be implicitly public :(
}
