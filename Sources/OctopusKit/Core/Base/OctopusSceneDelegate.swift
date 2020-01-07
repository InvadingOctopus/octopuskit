//
//  OctopusSceneDelegate.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-12
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

public typealias OKSceneDelegate = OctopusSceneDelegate

/// A protocol for types that control game state transitions and scene presentation based on input from the current scene, such as `OctopusGameState`.
public protocol OctopusSceneDelegate {
    
    // DESIGN: Hooks for the frame update cycle are not included, because checking and calling the delegate every frame may reduce performance. To customize the update cycle, subclass OctopusScene.
    
    // MARK: Initialization
    
    /// Creates the component systems for the scene.
    func createComponentSystems(for scene: OctopusScene) -> [GKComponent.Type] // ❕ Not currently used by OctopusScene
    
    /// Creates the gameplay entities and configures scene properties.
    func createContents(for scene: OctopusScene) // ❕ Not currently used by OctopusScene
    
    // MARK: Transitions
    
    /// Notifies the current `OctopusGameState` of the `OctopusGameCoordinator` state machine. The state's logic should decide how to interpret the "completion" of a scene and which state to transition to, if any.
    func octopusSceneDidFinish(_ scene: OctopusScene)
    
    /// Notifies the current `OctopusGameState` of the `OctopusGameCoordinator` state machine. The state's logic should decide which state should be the "next" state and whether to transition.
    ///
    /// - Returns: `true` if the `OctopusGameCoordinator` did change its state, or `false` if the state could not be changed or if there was no "next" state.
    @discardableResult func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool
    
    /// Notifies the current `OctopusGameState` of the `OctopusGameCoordinator` state machine. The state's logic should decide which state should be the "previous" state and whether to transition.
    ///
    /// - Returns: `true` if the `OctopusGameCoordinator` did change its state, or `false` if the state could not be changed or if there was no "previous" state.
    @discardableResult func octopusSceneDidChoosePreviousGameState(_ scene: OctopusScene) -> Bool
    
    /// Notifies the current `OctopusGameState` of the `OctopusGameCoordinator` state machine. The state's logic should decide whether the requested transition is valid.
    ///
    /// - Returns: `true` if the `OctopusGameCoordinator` did change its state, or `false` if the state could not be changed.
    @discardableResult func octopusScene(_ scene: OctopusScene,
                                         didRequestGameState stateClass: OctopusGameState.Type) -> Bool
    
    /// Requests the OctopusScenePresenter to present the scene with the specified filename, without changing the current game state.
    func octopusScene(_ outgoingScene: OctopusScene,
                      didRequestTransitionTo nextSceneFileName: String,
                      withTransition transition: SKTransition?)
    
    /// Requests the OctopusScenePresenter to present the scene of the specified class, without changing the current game state.
    func octopusScene(_ outgoingScene: OctopusScene,
                      didRequestTransitionTo nextSceneClass: OctopusScene.Type,
                      withTransition transition: SKTransition?)
}

// MARK: - Default Implementation

public extension OctopusSceneDelegate {
    
    // MARK: Initialization
    
    func createComponentSystems(for scene: OctopusScene) -> [GKComponent.Type] {
        // ❕ Not currently used by OctopusScene
        OctopusKit.logForWarnings.add("createComponentSystems(for:) not implemented for \(scene) — State: \(OctopusKit.shared.gameCoordinator.currentGameState)")
        return []
    }
    
    func createContents(for scene: OctopusScene) {
        // ❕ Not currently used by OctopusScene
        OctopusKit.logForWarnings.add("createContents(for:) not implemented for \(scene) — State: \(OctopusKit.shared.gameCoordinator.currentGameState)")
    }
    
    // MARK: Transitions
    
    // Abstract; To be implemented by subclass. The default behavior is to redirect to `octopusSceneDidChooseNextGameState(_)`.
    func octopusSceneDidFinish(_ scene: OctopusScene) {
        // CHECK: Should this be the default behavior? It may be helpful in showing a series of credits or intros/cutscenes etc.
        self.octopusSceneDidChooseNextGameState(scene)
    }
    
    /// Abstract; To be implemented by subclass.
    @discardableResult func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        return false
    }
    
    /// Abstract; To be implemented by subclass.
    @discardableResult func octopusSceneDidChoosePreviousGameState(_ scene: OctopusScene) -> Bool {
        return false
    }
    
    func octopusScene(_ scene: OctopusScene,
                      didRequestGameState stateClass: OctopusGameState.Type) -> Bool
    {
        OctopusKit.logForWarnings.add("octopusScene(_:didRequestGameState:) not implemented for \(scene) — State: \(OctopusKit.shared.gameCoordinator.currentGameState) — Calling OctopusKit.shared.gameCoordinator.enter(...)")
        
        return OctopusKit.shared.gameCoordinator.enter(stateClass)
    }
    
    func octopusScene(_ outgoingScene: OctopusScene,
                      didRequestTransitionTo nextSceneFileName: String,
                      withTransition transition: SKTransition?)
    {
        OctopusKit.logForWarnings.add("octopusScene(_:didRequestTransitionTo:withTransition:) not implemented for \(outgoingScene) — State: \(OctopusKit.shared.gameCoordinator.currentGameState) — Calling OctopusKit.shared.gameCoordinator.loadAndPresentScene(...)")
        
        OctopusKit.shared.gameCoordinator.loadAndPresentScene(fileNamed: nextSceneFileName,
                                                              withTransition: transition)
        // outgoingScene.isPaused = false // CHECK: Necessary?
    }
    
    func octopusScene(_ outgoingScene: OctopusScene,
                      didRequestTransitionTo nextSceneClass: OctopusScene.Type,
                      withTransition transition: SKTransition?)
    {
        OctopusKit.logForWarnings.add("octopusScene(_:didRequestTransitionTo:withTransition:) (class version) not implemented for \(outgoingScene) — State: \(OctopusKit.shared.gameCoordinator.currentGameState) — Calling OctopusKit.shared.gameCoordinator.createAndPresentScene(...)")
        
        OctopusKit.shared.gameCoordinator.createAndPresentScene(ofClass: nextSceneClass,
                                                                withTransition: transition)
        // outgoingScene.isPaused = false // CHECK: Necessary?
    }
}
