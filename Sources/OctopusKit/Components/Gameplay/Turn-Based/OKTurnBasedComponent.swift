//
//  OKTurnBasedComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/04.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Should this be a protocol?

// ⚠️ Prototype; Incomplete.

import GameplayKit

/// An abstract base class for components in a turn-based game.
///
/// Turn-based components may still have a per-frame `update(deltaTime:)` cycle and function like all other components, but they also have special turn-based methods that must be manually called to perform tasks during discrete game-defined turns.
open class OKTurnBasedComponent: OKComponent {

    /// Abstract; override in subclass.
    open func didBeginTurn() {}
    
    /// Abstract; override in subclass.
    open func executeTurn() {}
    
    /// Abstract; override in subclass.
    open func didEndTurn() {}
    
}
