//
//  PlayScene.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

final class PlayScene: OKScene {

    override func setName() -> String? { "PlayScene" }

    // MARK: - Life Cycle
    
    override func createComponentSystems() -> [GKComponent.Type] {
        // Customize. Each component must be listed after the components it depends on (as per its `requiredComponents` property.)
        // See OKScene.createComponentSystems() for the default set of commonly-used systems.
        super.createComponentSystems() + [
            // Customize: Add extra scene-specific components to update after the default set of components.
            UIViewModelComponent.self
        ]
    }
    
    override func createContents() {

        // MARK: Debugging Aids

        self.view?.setAllDebugStatsVisibility(to: true)
        // self.view?.showsPhysics = false

        OKConfiguration.flagsForSpriteKit = ["debugDrawStats_SKContextType": true]

        // MARK: Scene

        self.anchorPoint = .half // This places nodes with a position of (0,0) at the center of the scene.

        // Access these shared components from child entities with `RelayComponent(for:)`
        self.entity?.addComponents([
            PhysicsWorldComponent(),
            sharedPhysicsEventComponent,
            sharedMouseOrTouchEventComponent,
            sharedPointerEventComponent
        ])

        // MARK: Entities

        // Customize: This is where you construct entities to add to your scene.

        let playerEntity = PlayerEntity(scene: self)

        addEntities([

            playerEntity,

            OKEntity(name: "", components: [
                // Customize
            ])
        ])

        // MARK: Camera & UI

        self.entity!.addComponents([
            RelayComponent(for: playerEntity[UIViewModelComponent.self]),
            CameraComponent(nodeToTrack: playerEntity.node)
        ])
        
        // You may also perform scene construction and deconstruction in `gameCoordinatorDidEnterState(_:from:)` and `gameCoordinatorWillExitState(_:to:)`
    }

    override func didChangeSize(_ oldSize: CGSize) {
        // Handle window or screen size changes.
        super.didChangeSize(oldSize)
    }

    // MARK: - States
    
    /// Useful in games that use a single scene for multiple games states (e.g. displaying an overlay for the paused state, menus, etc. on the gameplay view.)
    override func gameCoordinatorDidEnterState(_ state: GKState, from previousState: GKState?) {
        super.gameCoordinatorDidEnterState(state, from: previousState)
        
        // If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
        
        switch type(of: state) { // Tuples may be used here: `(type(of: previousState), type(of: state))`
            
        case is PlayState.Type: // Entering `PlayableState`
            break
            
        case is PausedState.Type: // Entering `PausedState`
            physicsWorld.speed = 0
            
        default:
            break
        }
    }
    
    /// Useful in games that use a single scene for multiple games states (e.g. removing overlays that were displaying during a paused state, menus, etc.)
    override func gameCoordinatorWillExitState(_ exitingState: GKState, to nextState: GKState) {
        super.gameCoordinatorWillExitState(exitingState, to: nextState)
        
        // If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
        
        switch type(of: exitingState) { // Tuples may be used here: `(type(of: exitingState), type(of: nextState))`
            
        case is PlayState.Type: // Exiting `PlayableState`
            break
            
        case is PausedState.Type: // Exiting `PausedState`
            physicsWorld.speed = 1
            
        default:
            break
        }
    }
    
    // MARK: - Pausing/Unpausing

    override func didPauseBySystem() {
        if  let currentState = OctopusKit.shared?.gameCoordinator.currentState,
            !(type(of: currentState) is PausedState.Type)
        {
            self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
        }
    }
    
    override func didUnpauseBySystem() {
        // If we were in the paused game state, remain in that state so the player has to manually unpause when they are ready.
        
        if  let currentState = OctopusKit.shared.gameCoordinator.currentState,
            type(of: currentState) is PausedState.Type
        {
            // Since we are still in the paused state, keep the action paused, preventing `super.applicationDidBecomeActive()` from resuming it.
            physicsWorld.speed = 0
        }

        self.octopusSceneDelegate?.octopusSceneDidChoosePreviousGameState(self)
    }
    
    override func didPauseByPlayer() {
        // This transition should be subject to the validation logic in the relevant `OKGameState` classes.
        self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
    }
    
    override func didUnpauseByPlayer() {
        // This transition should be subject to the validation logic in the relevant `OKGameState` classes.
        self.octopusSceneDelegate?.octopusSceneDidChoosePreviousGameState(self)
    }
    
}
