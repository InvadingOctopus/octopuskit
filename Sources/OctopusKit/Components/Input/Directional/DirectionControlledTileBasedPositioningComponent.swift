//
//  DirectionControlledTileBasedPositioningComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Changes the coordinates of the entity's `TileBasedPositionComponent` based on player input via a `DirectionEventComponent`.
open class DirectionControlledTileBasedPositioningComponent: OKComponent, OKUpdatableComponent {
    
    open override var requiredComponents: [GKComponent.Type]? {
        [DirectionEventComponent.self,
         TileBasedPositionComponent.self]
    }
    
    /// The property of the `DirectionEventComponent` to monitor for input, such as `directionsBeganForCurrentFrame` or `directionsActive`. May be overriden in a subclass to effectively chooses whether to move once (e.g. when a key is first pressed) or to move repeatedly until an input ends (e.g. until a key is lifted).
    @inlinable
    open var directionsSource: Set<OKInputDirection>? {
        guard let directionEventComponent = coComponent(DirectionEventComponent.self) else { return nil }
        return directionEventComponent.directionsBeganForCurrentFrame
    }
    
    /// The number of tiles to move in for each input event.
    open var stepMultiplier: CGFloat = 1
    
    open override func update(deltaTime seconds: TimeInterval) {
        guard
            let tileBasedPositionComponent = coComponent(TileBasedPositionComponent.self),
            let input = directionsSource
            else { return }

        var newCoordinates = tileBasedPositionComponent.coordinates

        // ❕ NOTE: Use `if` instead of `switch` so all directions are processed, to allow diagonals and to let opposing directions cancel each other out.

        if input.contains(.up)      { newCoordinates.y += 1 }
        if input.contains(.down)    { newCoordinates.y -= 1 }
        if input.contains(.right)   { newCoordinates.x += 1 }
        if input.contains(.left)    { newCoordinates.x -= 1 }

        newCoordinates *= stepMultiplier
    
        tileBasedPositionComponent.coordinates = newCoordinates
        tileBasedPositionComponent.clampCoordinates()
    }
}
