//
//  GKComponentSystem+TurnBased.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/*
extension GKComponentSystem where ComponentType == GKComponent {
    
    // ❗️ This seems too hard to implement cleanly in Swift 5.2 as of 2020-05-02:
    //
    // `where ComponentType == GKComponent` is necessary to silence:
    // "Extension of a generic Objective-C class cannot access the class's generic parameters at runtime"
    //
    // Recommended Fix: "Add '@objc' to allow uses of 'self' within the function body"
    // But adding `@objc` raises: "Members of constrained extensions cannot be declared @objc"
    //
    // Adding `where ComponentType == GKComponent` raises: "Members of constrained extensions cannot be declared @objc"
    //
    // That `where` clause above and omitting `@objc` compiles, but it hasn't been verified that the calls are correctly forwarded to subclasses of `GKComponent`. At this point we should just implement the turn-based methods in `OKTurnBasedScene`
    
    // ❗️ `TurnBased` conformance cannot be implemented either:
    //
    // "Type 'GKComponentSystem<ComponentType>' cannot conditionally conform to protocol 'TurnBased' because the type uses the Objective-C generics model"
    //
    // "Same-type constraint type 'GKComponent' does not conform to required protocol 'TurnBased'"
    
    // ❕ CHECK: Shouldn't the turn-based methods be automatically handled by `GKComponent` as it's supposed to forward calls to its member components?
    //
    // According to: https://developer.apple.com/documentation/gameplaykit/gkcomponentsystem
    // "The component system will then forward any component-specific messages it receives to all registered instances of its component class."
    //
    // Perhaps via `@dynamicCallable`?
    
    @inlinable
    public func beginTurn(delta turns: Int = 1) {
        for case let component as TurnBased in self.components {
            component.beginTurn(delta: turns)
        }
    }
    
    @inlinable
    public func updateTurn(delta turns: Int = 1) {
        for case let component as TurnBased in self.components {
            component.updateTurn(delta: turns)
        }
    }
    
    @inlinable
    public func endTurn(delta turns: Int = 1) {
        for case let component as TurnBased in self.components {
            component.endTurn(delta: turns)
        }
    }
}
*/
