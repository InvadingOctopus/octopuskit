//
//  TurnBasedTileBasedPositionComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import GameplayKit

/// Updates the coordinates of the entity's `TileBasedPositionComponent` on a new game turn, ultimately setting the position of the entity's `NodeComponent` node.
///
/// **Dependencies:** `TileBasedPositionComponent`
open class TurnBasedTileBasedPositionComponent: OKTurnBasedComponent {
        
    open override var requiredComponents: [GKComponent.Type]? {
        [TileBasedPositionComponent.self]
    }

    /// The coordinates to set on the entity's `TileBasedPositionComponent` in `updateTurn(delta:)`.
    open var pendingCoordinates: Point?
    
    /// Set before `pendingCoordinates` are applied, and cleared at the start of a new turn.
    public fileprivate(set) var previousCoordinates: Point?
    
    open override func beginTurn(delta turns: Int = 1) {
        self.previousCoordinates = nil
    }
    
    open override func updateTurn(delta turns: Int) {
        guard
            let pendingCoordinates = self.pendingCoordinates,
            let tileBasedPositionComponent = coComponent(TileBasedPositionComponent.self)
            else { return }
        
        // CHECK: Validate coordinates here or is that the TileBasedPositionComponent's job?
        
        self.previousCoordinates = tileBasedPositionComponent.coordinates
        
        tileBasedPositionComponent.coordinates = pendingCoordinates
        
        // Clear the pending coordinates so they don't get reapplied.
        
        self.pendingCoordinates = nil
    }

}
