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
open class OKTurnBasedScene: OKScene, TurnBased {
    
    // See GKComponentSystem+TurnBased.swift for notes on why the turn-based methods are not implemented as GKComponentSystem extensions.
    
    open override func createSceneEntity() {
        super.createSceneEntity()
        self.entity?.addComponent(TurnCounterComponent())
    }
    
    // MARK: Turn Update Cycle
    
    open func beginTurn(delta turns: Int = 1) {
        self.beginTurn(in: self.componentSystems, delta: turns)
    }
    
    public func beginTurn(in systemsCollection: [OKComponentSystem],
                          delta turns: Int)
    {
        for componentSystem in systemsCollection {
            for case let component as TurnBased in componentSystem.components {
                component.beginTurn(delta: turns)
            }
        }
    }
    
    open func updateTurn(delta turns: Int = 1) {
        self.updateTurn(in: self.componentSystems, delta: turns)
    }
    
    public func updateTurn(in systemsCollection: [OKComponentSystem],
                           delta turns: Int)
    {
        for componentSystem in systemsCollection {
            for case let component as TurnBased in componentSystem.components {
                component.updateTurn(delta: turns)
            }
        }
    }
    
    open func endTurn(delta turns: Int = 1) {
        self.endTurn(in: self.componentSystems, delta: turns)
    }
    
    public func endTurn(in systemsCollection: [OKComponentSystem],
                        delta turns: Int)
    {
        for componentSystem in systemsCollection {
            for case let component as TurnBased in componentSystem.components {
                component.endTurn(delta: turns)
            }
        }
    }
    
}
