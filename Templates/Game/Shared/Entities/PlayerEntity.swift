//
//  PlayerEntity.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

final class PlayerEntity: OKEntity {
    
    init(scene: OKScene) {
        
        super.init(name: "PlayerEntity")
        
        /// For more granular control of states, modify the `PlayerEntitySpawningState` and `PlayerEntityActiveState` code.
        
        // MARK: Spawning State
        
        let spawningState = PlayerEntitySpawningState(entity: self)
        
        spawningState.componentsToAddOnEntry = [
            // Customize
        ]

        spawningState.syncComponentArrays() // Delete this if you do not want the above components to be removed when this state exits.
        
        // MARK: Active State
        
        let activeState = PlayerEntityActiveState(entity: self)
        
        activeState.componentsToAddOnEntry = [ // Customize
            RelayComponent(for: scene.sharedPointerEventComponent),
            PointerControlledRotationComponent()
        ]
        
        activeState.syncComponentArrays() // Delete this if you do not want the above components to be removed when this state exits.
        
        // MARK: State Machine
        
        let stateMachine = OKStateMachine(states: [
            spawningState,
            activeState
        ])
        
        // MARK: Components common to every state
        
        // Add components in the order of dependency; e.g., the states of the `StateMachineComponent` may depend on other components, so add it last.
        
        self.addComponents([
            StateMachineComponent(stateMachine:          stateMachine,
                                  stateOnAddingToEntity: PlayerEntitySpawningState.self,
                                  stateOnFirstUpdate:    PlayerEntityActiveState.self),

            NodeComponent(node: SKSpriteNode(color: .green, size: CGSize(widthAndHeight: 50))), // Customize

            UIViewModelComponent()
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - PlayerEntitySpawningState

// This class may be moved out to a separate file. If no customization is required beyond the component arrays initialized by the entity, this body may be deleted, leaving only the type declaration.

final class PlayerEntitySpawningState: OKEntityState {
    
    override var validNextStates: [OKState.Type] {
        [PlayerEntityActiveState.self]
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        switch previousState {

        case is PlayerEntityActiveState:
            // entity.removeComponents([])
            // entity.addComponents([])
            break
            
        default: break
        }
    }
}

// MARK: - PlayerEntityActiveState

// This class may be moved out to a separate file. If no customization is required beyond the component arrays initialized by the entity, this body may be deleted, leaving only the type declaration.

final class PlayerEntityActiveState: OKEntityState {
    
    override var validNextStates: [OKState.Type] {
        [PlayerEntitySpawningState.self]
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        switch previousState {

        case is PlayerEntitySpawningState:
            // entity.removeComponents([])
            // entity.addComponents([])
            break
            
        default: break
        }
    }
}
