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
    
    var gameController: OctopusGameController?  { get } // TODO: Remove?
    var currentGameState: OctopusGameState?     { get }
    
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

public extension OctopusSceneDelegate where Self: OctopusScenePresenter {
    
    func octopusSceneDidFinish(_ scene: OctopusScene) {
        
        if  let currentGameState = self.currentGameState {
            currentGameState.octopusSceneDidFinish(scene)
        }
    }
    
    @discardableResult func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        if  let currentGameState = self.currentGameState {
            return currentGameState.octopusSceneDidChooseNextGameState(scene)
        } else {
            return false
        }
    }
    
    @discardableResult func octopusSceneDidChoosePreviousGameState(_ scene: OctopusScene) -> Bool {
        
        if  let currentGameState = self.currentGameState {
            return currentGameState.octopusSceneDidChoosePreviousGameState(scene)
        } else {
            return false
        }
    }
    
    /// May be overriden in subclass to provide transition validation.
    @discardableResult func octopusScene(_ scene: OctopusScene,
                                         didRequestGameState stateClass: OctopusGameState.Type) -> Bool
    {
        if let currentGameState = currentGameState {
            return currentGameState.octopusScene(scene, didRequestGameStateClass: stateClass)
        } else {
            return self.gameController?.enter(stateClass) ?? false
        }
    }
    
}

public extension OctopusSceneDelegate where Self: OctopusScenePresenter {
    
    /// Override in subclass to implement more granular control over transitions between specific types of scenes.
    ///
    /// - Parameter transition: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    func octopusScene(
        _ outgoingScene: OctopusScene,
        didRequestTransitionTo nextSceneFileName: String,
        withTransition transition: SKTransition? = nil)
    {
        OctopusKit.logForFramework.add("nextSceneFileName: \(nextSceneFileName)")
        loadAndPresentScene(fileNamed: nextSceneFileName, withTransition: transition)
        // outgoingScene.isPaused = false // CHECK: Necessary?
    }
    
    /// Override in subclass to implement more granular control over transitions between specific types of scenes.
    ///
    /// - Parameter transition: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    func octopusScene(
        _ outgoingScene: OctopusScene,
        didRequestTransitionTo nextSceneClass: OctopusScene.Type,
        withTransition transition: SKTransition? = nil)
    {
        OctopusKit.logForFramework.add("nextSceneClass: \(nextSceneClass)")
        createAndPresentScene(ofClass: nextSceneClass, withTransition: transition)
        // outgoingScene.isPaused = false // CHECK: Necessary?
    }
    
}
