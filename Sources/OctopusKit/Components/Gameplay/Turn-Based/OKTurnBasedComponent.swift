//
//  OKTurnBasedComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/04.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// An abstract base class for components in a turn-based game.
///
/// Turn-based components still have a per-frame `update(deltaTime:)` cycle and may perform per-frame updates like all other components, but they also have special methods that must be manually called to perform tasks for each discrete game-defined turn.
open class OKTurnBasedComponent: OKComponent {

    // DESIGN: CHECKED: Should this be a protocol with default implementations? No, as it would not be consistent with the `override` for regular `update(deltaTime:)` etc. :)

    /// *Abstract; override in subclass.* Use this to perform any tasks that must occur at the beginning of each turn, *before* `updateTurn(delta:)`, such as health regeneration effects.
    ///
    /// - Parameter turns: The number of turns passed since the previous update. Default: `1`
    open func beginTurn(delta turns: Int = 1) {}
    
    /// *Abstract; override in subclass.*
    /// - Parameter turns: The number of turns passed since the previous update. Default: `1`
    open func updateTurn(delta turns: Int = 1) {}
    
    /// *Abstract; override in subclass.* Use this to perform any tasks that must occur at the end of each turn, *after* `updateTurn(delta:)`, such as damage-over-time effects.
    ///
    /// - Parameter turns: The number of turns passed since the previous update. Default: `1`
    open func endTurn(delta turns: Int = 1) {}
    
}
