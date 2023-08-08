//
//  TileBasedPositionComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import SpriteKit
import GameplayKit
import OSLog

/// Updates the entity's `NodeComponent` node's position in every frame to align with the center of a tile in a `TileMapComponent`.
public final class TileBasedPositionComponent: OKComponent, RequiresUpdatesPerFrame {
    
    // TODO: Warp-around option.
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         /// TileMapComponent.self /// DESIGN: Do not warn about missing a `TileMapComponent`; having one on a player/character entity may not make sense in most cases, and it causes too many warnings even when `tileMapComponentOverride` is provided.
        ]
    }
    
    // MARK: - Properties
    
    /// Specifies a `TileMapComponent` or its subclass which may be in another entity, e.g. a map entity. If `nil` then this component's entity's `TileMapComponent` (but not a subclass) is used, if any.
    ///
    /// A `RelayComponent` in this component's entity may also be used to connect to a `TileMapComponent` in another entity by leaving this property `nil`.
    public var tileMapComponentOverride: TileMapComponent? = nil
    
    /// The index of the `TileMapComponent` layer to use, i.e. the `SKTileMapNode` to query for the tile coordinates.
    public var tileMapLayer: Int = 0
        
    /// Applies an offset to the entity's node position from the center of a map tile.
    public var offsetFromTileCenter: CGPoint = .zero
    
    /// The coordinates of a tile in the `TileMapComponent`'s `SKTileMapNode`. The entity's node's position is set to this tile's center in every frame, adding the `offsetFromTileCenter`.
    public var coordinates: Point = .zero {
        didSet {
            if  coordinates != oldValue {
                alignNodePositionOnUpdate = true
            }
        }
    }
    
    /// If `true`, `alignNodePositionToTile()` is called when this component is updated, after which this flag is reset. Automatically set when `coordinates` are modified.
    ///
    /// If the entity's node's position is modified by other components, then this flag must be set to `true` or `alignNodePositionToTile()` must be called manually to re-align the node with its map tile.
    public var alignNodePositionOnUpdate: Bool = false
    
    /// If `true`, the `zPosition` of the entity's node is also modified so that entities on lower rows are in front of entities on higher rows, such that a `y` (row) coordinate of `0` would have a `zPosition` equal to the `numberOfRows` in the `SKTileMapNode`, and the highest row would have a `zPosition` of `0`.
    public var setZPosition:        Bool = true
    
    /// The amount to adjust the `zPosition` of the entity's node by, *after* setting its `zPosition` according to this component's `y` (row) coordinate.
    public var zPositionModifier:   CGFloat = 0
    
    /// If `true`, an `SKAction` animates the entity's node from its current position to the tile's position. If `false`, the node is moved to the new position immediately.
    public var animate:             Bool
    
    public var animationDuration:   TimeInterval
    public var animationTimingMode: SKActionTimingMode
    
    public var animationActionKey   = "OctopusKit.Animation.TileBasedPositionComponent"
    
     // MARK: - Computed Properties
    
    /// The `SKTileMapNode` at the `tileMapLayer` of the entity's `TileMapComponent`. Returns `nil` if the entity has no `TileMapComponent` or if the index is out of bounds.
    @inlinable
    public var tileMapNode: SKTileMapNode? {
        
        guard let tileMapComponent = self.tileMapComponentOverride ?? coComponent(TileMapComponent.self)
            else { return nil }
        
        guard tileMapComponent.layers.isValidIndex(self.tileMapLayer) else {
            OKLog.logForWarnings.debug("\(📜("\(tileMapLayer) out of bounds for the \(tileMapComponent.layers.count) layers in \(tileMapComponent)"))")
            return nil
        }
        
        return tileMapComponent.layers[tileMapLayer]
    }
    
    // MARK: - Life Cycle
    
    /// - Parameters:
    ///   - tileMapComponentOverride: Specify `nil` to use this component's entity's `TileMapComponent`, or specify a `TileMapComponent` (or its subclass) in another entity, e.g. a map entity.
    ///
    ///     A `RelayComponent` in this component's entity may also be used to connect to a `TileMapComponent` in another entity by leaving this property `nil`.
    ///
    ///   - coordinates: The coordinates of the initial tile in the `TileMapComponent`'s `SKTileMapNode`. The entity's node's position is set to this tile's center in every frame.
    ///   - tileMapLayer: The index of the `TileMapComponent` layer to use, i.e. the `SKTileMapNode` to query for the tile coordinates.
    ///   - offsetFromTileCenter: The additional offset to apply to the entity's node.
    ///   - setZPosition: If `true`, the `zPosition` of the entity's node is also modified so that entities on lower rows are in front of entities on higher rows. Default: `true`
    ///   - zPositionModifier: The amount to adjust the `zPosition` of the entity's node by, *after* setting its `zPosition` according to this component's `y` (row) coordinate.
    ///   - animate: If `true`, an `SKAction` animates the entity's node from its current position to the tile's position. If `false`, the node is moved to the new position immediately.
    public init(tileMapComponentOverride:   TileMapComponent?   = nil,
                tileMapLayer:               Int                 = 0,
                
                coordinates:                Point               = .zero,
                offsetFromTileCenter:       CGPoint             = .zero,
                
                setZPosition:               Bool                = true,
                zPositionModifier:          CGFloat             = 0,
                
                animate:                    Bool                = true,
                animationDuration:          TimeInterval        = 0.2,
                animationTimingMode:        SKActionTimingMode  = .easeIn)
    {
        self.tileMapComponentOverride       = tileMapComponentOverride
        self.tileMapLayer                   = tileMapLayer
        self.coordinates                    = coordinates
        self.offsetFromTileCenter           = offsetFromTileCenter
        self.animate                        = animate
        self.animationDuration              = animationDuration
        self.animationTimingMode            = animationTimingMode
        self.alignNodePositionOnUpdate      = true // To align with the initial coordinates.
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func didAddToEntity(withNode node: SKNode) {
        alignNodePositionToTile()
    }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        if  alignNodePositionOnUpdate { // PERFORMANCE: No unnecessary updates.
            alignNodePositionToTile()
            alignNodePositionOnUpdate = false
        }
    }
    
    // MARK: - Positioning
    
    /// The position of the tile at `coordinates` in the `tileMapLayer` of the entity's `TileMapComponent`, after adding `offsetFromTileCenter`. Returns `nil` if the entity has no `TileMapComponent`, or if the `tileMapLayer` index or `coordinates` are out of bounds.
    @inlinable
    public var position: CGPoint? {
        
        guard let tileMapNode = self.tileMapNode else { return nil }
        
        let column  = self.coordinates.x
        let row     = self.coordinates.y
        
        guard // SKTileMapNode is 0-indexed
            column  >= 0,
            column  < tileMapNode.numberOfColumns,
            row     >= 0,
            row     < tileMapNode.numberOfRows
        else {
            // CHECK: PERFORMANCE: Is this check necessary? or would it be handled by the SKTileMapNode?
            // TODO: Warp-around option.
            OKLog.logForWarnings.debug("\(📜("\(self.coordinates) out of bounds for the \(tileMapNode.numberOfColumns) x \(tileMapNode.numberOfRows) tiles in \(tileMapNode)"))")
            return nil
        }
        
        return tileMapNode.centerOfTile(atColumn: column, row: row)
            + self.offsetFromTileCenter
    }
    
    /// Sets the position of this entity's `NodeComponent` node to the center of the tile in the `tileMapComponent`'s `SKTileMapNode`.
    @inlinable
    public func alignNodePositionToTile() {
        guard
            let node            = self.entityNode,
            let tiledPosition   = self.position,
            let tileMapNode     = self.tileMapNode
            else { return }
        
        // Set the position inside the appropriate coordinate space.
        
        let newNodePosition: CGPoint
        
        if  let nodeParent = node.parent { // CHECK & VERIFY & TEST: Is this the expected behavior?
            newNodePosition = tileMapNode.convert(tiledPosition, to: nodeParent)
        } else if let tileMapParent = tileMapNode.parent {
            newNodePosition = tileMapNode.convert(tiledPosition, to: tileMapParent)
        } else {
            newNodePosition = tiledPosition
        }
        
        // Set the node's z position, so that entities on lower tiles are in front of entities on higher tiles.
        // The bottom-most row (0) should have the highest z height (equal to the number of rows).
        
        if  setZPosition {
            let rows        = tileMapNode.numberOfRows
            let row         = self.coordinates.y
            node.zPosition  = CGFloat(rows - row) + zPositionModifier
        }
        
        // Finally! Move the node to new position, animating the movement if needed.
        
        if animate {
            let moveAction = SKAction.move(to: newNodePosition, duration: animationDuration)
                .timingMode(animationTimingMode)
            node.run(moveAction) // NOTE: Applying `withKey: animationActionKey` makes the animation feel unnatural.
        } else {
            node.position = newNodePosition
        }
        
    }
    
    /// Clamps the `coordinates` to within `0` and the number of columns and rows in the `TileMapComponent`'s `SKTileMapNode` `layer`.
    @inlinable
    public func clampCoordinates() {
        guard let tileMapComponent = self.tileMapComponentOverride ?? coComponent(TileMapComponent.self) else {
            OKLog.logForWarnings.debug("\(📜("\(self) missing TileMapComponent — Cannot clamp, indexes may go out of bounds."))")
            return
        }
        
        guard tileMapComponent.layers.isValidIndex(self.tileMapLayer) else {
            OKLog.logForWarnings.debug("\(📜("\(tileMapLayer) out of bounds for the \(tileMapComponent.layers.count) layers in \(tileMapComponent)"))")
            return
        }
        
        let tileMapNode = tileMapComponent.layers[tileMapLayer]
        
        // CHECK: PERFORMANCE: Impact from range allocations?
        
        let column      = coordinates.x.clamped(to: 0 ..< tileMapNode.numberOfColumns)
        let row         = coordinates.y.clamped(to: 0 ..< tileMapNode.numberOfRows)
        
        coordinates     = Point(x: column, y: row)
    }
}
