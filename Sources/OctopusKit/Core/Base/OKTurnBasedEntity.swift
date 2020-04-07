//
//  OKTurnBasedEntity.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A base class for entities in a turn-based game.
open class OKTurnBasedEntity: OKEntity, TurnBased {
    
    /// Calls `beginTurn(delta:)` on each turn-based component. Use this to perform any tasks that must occur at the beginning of each turn, *before* `updateTurn(delta:)`, such as health regeneration effects.
    ///
    /// - Parameter turns: The number of turns passed since the previous update.
    open func beginTurn(delta turns: Int) {
        for case let turnBasedComponent as TurnBased in self.components {
            turnBasedComponent.beginTurn(delta: turns)
        }
    }
    
    /// Calls `updateTurn(delta:)` on each turn-based component.
    ///
    /// - Parameter turns: The number of turns passed since the previous update.
    open func updateTurn(delta turns: Int) {
        for case let turnBasedComponent as TurnBased in self.components {
            turnBasedComponent.updateTurn(delta: turns)
        }
    }
    
    /// Calls `endTurn(delta:)` on each turn-based component. Use this to perform any tasks that must occur at the end of each turn, *after* `updateTurn(delta:)`, such as damage-over-time effects.
    ///
    /// - Parameter turns: The number of turns passed since the previous update.
    open func endTurn(delta turns: Int) {
        for case let turnBasedComponent as TurnBased in self.components {
            turnBasedComponent.endTurn(delta: turns)
        }
    }
    
}
