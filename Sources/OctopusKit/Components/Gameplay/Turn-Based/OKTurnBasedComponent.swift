//
//  OKTurnBasedComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/04.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// An abstract base class for components in a turn-based game. May be used in conjunction with `OKTurnBasedScene` or updated manually.
///
/// Turn-based components still have a per-frame `update(deltaTime:)` cycle and may perform per-frame updates like all other components, but they also have special methods that must be manually called to perform tasks for each discrete game-defined turn.
///
/// - IMPORTANT: Turn-based components must also be added to the component systems list of an `OKTurnBasedScene` to be updated in a deterministic order.
open class OKTurnBasedComponent: OKComponent, TurnBased {

    // 💡 TIP: Use game states to implement turn order for games that require the begin/update/end cycle.
    // EXAMPLE: `TurnBeginState`, `TurnUpdateState`, `TurnEndState`, all handled by a single scene.
    // A component that manages player control and/or turn logic would signal the game coordinator to transition to different states, and the scene would call `self.beginTurn()`, `self.updateTurn()` and `self.endTurn()` in OKScene.gameCoordinatorDidEnterState(_:from:)
    
    // DESIGN: CHECKED: Should this be a protocol with default implementations? No, as it would not be consistent with the `override` for regular `update(deltaTime:)` etc. :)

    /// A flag that may be implemented by subclasses, e.g. to prevent multiple calls of `beginTurn()` during a single cycle.
    ///
    /// - Note: Using `OKGameState` may be more suitable for managing the begin/update/end turn cycle. See `OKTurnBasedComponent` comments for tips.
    public var disallowBeginTurn    = false
    
    /// A flag that may be implemented by subclasses, e.g. to prevent multiple calls of `updateTurn()` during a single cycle.
    ///
    /// - Note: Using `OKGameState` may be more suitable for managing the begin/update/end turn cycle. See `OKTurnBasedComponent` comments for tips.
    public var disallowUpdateTurn   = false
    
    /// A flag that may be implemented by subclasses, e.g. to prevent multiple calls of `endTurn()` during a single cycle.
    ///
    /// - Note: Using `OKGameState` may be more suitable for managing the begin/update/end turn cycle. See `OKTurnBasedComponent` comments for tips.
    public var disallowEndTurn      = false
    
    /// *Abstract; override in subclass.* Use this to perform any tasks that must occur at the beginning of each turn, *before* `updateTurn(delta:)`, such as health regeneration effects.
    ///
    /// - Parameter turns: The number of turns passed since the previous update. Default: `1`
    ///
    /// - Note: Use different `OKGameState`s or the `disallowBeginTurn` flag to prevent multiple calls during a single cycle.
    open func beginTurn(delta turns: Int = 1) {}
    
    /// *Abstract; override in subclass.*
    /// 
    /// - Parameter turns: The number of turns passed since the previous update. Default: `1`
    ///
    /// - Note: Use different `OKGameState`s or the `disallowUpdateTurn` flag to prevent multiple calls during a single cycle.
    open func updateTurn(delta turns: Int = 1) {}
    
    /// *Abstract; override in subclass.* Use this to perform any tasks that must occur at the end of each turn, *after* `updateTurn(delta:)`, such as damage-over-time effects.
    ///
    /// - Parameter turns: The number of turns passed since the previous update. Default: `1`
    ///
    /// - Note: Use different `OKGameState`s or the `disallowEndTurn` flag to prevent multiple calls during a single cycle.
    open func endTurn(delta turns: Int = 1) {}
    
}
