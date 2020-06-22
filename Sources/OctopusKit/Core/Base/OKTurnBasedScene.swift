//
//  OKTurnBasedScene.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/02
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// A scene in a turn-based game. Contains methods for updating turn-based components and adds a `TurnCounterComponent` to the scene's root entity.
///
/// To log each begin/update/end cycle for all turn-based components, set the `LOGTURNBASED` conditional compilation flag.
///
/// - NOTE: Implementing turn cycles may be best handled by different `OKGameState`s, e.g. `BeginTurnState`, `UpdateTurnState` and `EndTurnState`, each of which call the relevant methods (`beginTurn(delta:)`, `updateTurn(delta:)`, `endTurn(delta:)`) on the scene, to ensure a correct turn cycle for all components.
open class OKTurnBasedScene: OKScene, TurnBased {
    
    /// ℹ️ The turns logging system uses the `TurnCounterComponent.currentTurn` of the `OKScene.entity`, so the first log entry at the start of a new turn cycle will have a lower turn number, e.g.: "T0, PlayScene, <OctopusKit.TurnCounterComponent>"
    
    // See GKComponentSystem+TurnBased.swift for notes on why the turn-based methods are not implemented as GKComponentSystem extensions.
    
    // CHECK: PERFORMANCE
    
    /// The number of the current turn according to the scene's root entity's `TurnCounterComponent`, if any.
    open var currentTurn:  Int {
        self.entity?[TurnCounterComponent.self]?.currentTurn ?? 0 /// CHECK: Should it be `nil`?
    }
    
    /// The number of turns elapsed according to the scene's root entity's `TurnCounterComponent`, if any.
    open var turnsElapsed: Int {
        self.entity?[TurnCounterComponent.self]?.turnsElapsed ?? 0 /// CHECK: Should it be `nil`?
    }
    
    @inlinable
    open override func createSceneEntity() {
        super.createSceneEntity()
        self.entity?.addComponent(TurnCounterComponent())
    }
    
    // MARK: Turn Update Cycle
    
    @inlinable
    open func beginTurn(delta turns: Int = 1) {
        self.beginTurn(in: self.componentSystems, delta: turns)
    }
    
    @inlinable
    public func beginTurn(in systemsCollection: [OKComponentSystem],
                          delta turns: Int)
    {
        for system in systemsCollection {
            for case let component as TurnBased in system.components
                where !component.disallowBeginTurn
            {
                #if LOGTURNBASED
                let entityName = ((component as? OKComponent)?.entityName ?? "\(type(of: (component as? OKComponent)?.entity))")
                    .paddedWithSpace(toLength: 16)
                let turn = "T\(self.currentTurn)"
                    .paddedWithSpace(toLength: 5)
                
                OctopusKit.logForTurns("\(entityName) \(component))", topic: "\(self.name)", function: "\(turn) 🟢")
                #endif
                
                component.beginTurn(delta: turns)
            }
        }
    }
    
    @inlinable
    open func updateTurn(delta turns: Int = 1) {
        self.updateTurn(in: self.componentSystems, delta: turns)
    }
    
    @inlinable
    public func updateTurn(in systemsCollection: [OKComponentSystem],
                           delta turns: Int)
    {
        for system in systemsCollection {
            for case let component as TurnBased in system.components
                where !component.disallowUpdateTurn
            {
                #if LOGTURNBASED
                let entityName = ((component as? OKComponent)?.entityName ?? "\(type(of: (component as? OKComponent)?.entity))")
                    .paddedWithSpace(toLength: 16)
                let turn = "T\(self.currentTurn)"
                    .paddedWithSpace(toLength: 5)
                
                OctopusKit.logForTurns("\(entityName) \(component))", topic: "\(self.name)", function: "\(turn) 🟡")
                #endif
                
                component.updateTurn(delta: turns)
            }
        }
    }
    
    @inlinable
    open func endTurn(delta turns: Int = 1) {
        self.endTurn(in: self.componentSystems, delta: turns)
    }
    
    @inlinable
    public func endTurn(in systemsCollection: [OKComponentSystem],
                        delta turns: Int)
    {
        for system in systemsCollection {
            for case let component as TurnBased in system.components
                where !component.disallowEndTurn
            {
                #if LOGTURNBASED
                let entityName = ((component as? OKComponent)?.entityName ?? "\(type(of: (component as? OKComponent)?.entity))")
                    .paddedWithSpace(toLength: 16)
                let turn = "T\(self.currentTurn)"
                    .paddedWithSpace(toLength: 5)
                
                OctopusKit.logForTurns("\(entityName) \(component))", topic: "\(self.name)", function: "\(turn) 🔴")
                #endif
                
                component.endTurn(delta: turns)
            }
        }
    }
    
}
