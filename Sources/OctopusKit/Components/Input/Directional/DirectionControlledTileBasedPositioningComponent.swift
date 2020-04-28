//
//  DirectionControlledTileBasedPositioningComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

open class DirectionControlledTileBasedPositioningComponent: OKComponent, OKUpdatableComponent {
    
    open override var requiredComponents: [GKComponent.Type]? {
        [DirectionEventComponent.self]
    }
    
    @inlinable
    open var directionsSource: Set<OKInputDirection>? {
        guard let directionEventComponent = coComponent(DirectionEventComponent.self) else { return nil }
        directionEventComponent.directionsBeganForCurrentFrame
    }
    
    /// The number of tiles to move in.
    var stepMultiplier: Int = 1
    
    @inlinable
    open override func update(deltaTime seconds: TimeInterval) {
        guard
            let tileBasedPositionComponent = coComponent(TileBasedPositionComponent.self),
            let input = directionsSource
        else { return }
        
        var newCoordinates = tileBasedPositionComponent.coordinates
        
        // ❕ NOTE: Use `if` instead of `switch` so all directions are processed, to allow diagonals and to let opposing directions cancel each other out.
        
        if input.contains(.up)      { newCoordinates.y += 1 * stepMultiplier }
        if input.contains(.down)    { newCoordinates.y -= 1 * stepMultiplier }
        if input.contains(.right)   { newCoordinates.x += 1 * stepMultiplier }
        if input.contains(.left)    { newCoordinates.x -= 1 * stepMultiplier }
        
        tileBasedPositionComponent = newCoordinates
        tileBasedPositionComponent.clampCoordinates()
    }
}
