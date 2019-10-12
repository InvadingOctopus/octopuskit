//
//  OctopusSceneDelegate.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-12
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// A protocol for types that control game state transitions and scene presentation based on input from the current scene, such as `OctopusSceneController`.
public protocol OctopusSceneDelegate: class {
    
    /// Notifies the current `OctopusGameState` of the `OctopusGameController` state machine. The state's logic should decide how to interpret the "completion" of a scene and which state to transition to, if any.
    func octopusSceneDidFinish(_ scene: OctopusScene)
    
    /// Notifies the current `OctopusGameState` of the `OctopusGameController` state machine. The state's logic should decide which state should be the "next" state and whether to transition.
    ///
    /// - Returns: `true` if the `OctopusGameController` did change its state, or `false` if the state could not be changed or if there was no "next" state.
    @discardableResult func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool
    
    /// Notifies the current `OctopusGameState` of the `OctopusGameController` state machine. The state's logic should decide which state should be the "previous" state and whether to transition.
    ///
    /// - Returns: `true` if the `OctopusGameController` did change its state, or `false` if the state could not be changed or if there was no "previous" state.
    @discardableResult func octopusSceneDidChoosePreviousGameState(_ scene: OctopusScene) -> Bool
    
    /// Notifies the current `OctopusGameState` of the `OctopusGameController` state machine. The state's logic should decide whether the requested transition is valid.
    ///
    /// - Returns: `true` if the `OctopusGameController` did change its state, or `false` if the state could not be changed.
    @discardableResult func octopusScene(_ scene: OctopusScene,
                                         didRequestGameState stateClass: OctopusGameState.Type) -> Bool
    
    /// Requests the scene controller to present the scene with the specified filename, without changing the current game state.
    func octopusScene(_ outgoingScene: OctopusScene,
                      didRequestTransitionTo nextSceneFileName: String,
                      withTransition transition: SKTransition?)
    
    /// Requests the scene controller to present the scene of the specified class, without changing the current game state.
    func octopusScene(_ outgoingScene: OctopusScene,
                      didRequestTransitionTo nextSceneClass: OctopusScene.Type,
                      withTransition transition: SKTransition?)
}

// MARK: - Default Implementation

public extension OctopusSceneDelegate {
    
    // Abstract; To be implemented by subclass. Default behavior is to redirect to `octopusSceneDidChooseNextGameState(_)`.
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
}
