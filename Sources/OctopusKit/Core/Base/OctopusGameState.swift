//
//  OctopusGameState.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/07.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// A protocol for types that will recieve notifications about state transitions, and can provide visual effects for scene transitions.
public protocol OctopusGameStateDelegate: class {
    func gameControllerDidEnterState(_ state: GKState, from previousState: GKState?)
    func gameControllerWillExitState(_ exitingState: GKState, to nextState: GKState)
    func transition(for nextStateClass: GKState.Type) -> SKTransition?
}

/// Abstract base class for game states.
public class OctopusGameState: GKState {
    
    // ℹ️ DESIGN: Not including a `gameController: OctopusGameController` property in `OctopusGameState`, so that subclasses may provide their own `gameController` property with their custom subclass of `OctopusGameController` if needed.
    
    // ℹ️ Even though there is a `OctopusGameStateDelegate` protocol, `OctopusGameState` only exposes a `delegate` for formality but it does not use it. The reason is that in certain situations, an `OctopusGameState` may have more than one "delegate" that it needs to send notifications to, e.g. both an outgoing scene and an incoming scene in the case of visual scene transition effects with a long duration. The `delegate` property may be opened as a future customization point.
    
    // NOTE: Apple documentation for `isValidNextState(_:)`:
    // Your implementation of this method should describe the static relationships between state classes that determine the set of edges in a state machine’s state graph.
    // ⚠️ Do not use this method to conditionally control state transitions—instead, perform such conditional logic before calling a state machine’s `enter(_:)` method.
    // By restricting the set of valid state transitions, you can use a state machine to enforce invariant conditions in your code. For example, if one state class can be entered only after a state machine has passed through a series of other states, code in that state class can safely assume that any actions performed by those other states have already occurred.
    
    /// The scene that will be presented when the `OctopusGameController` (or your custom subclass) enters this state.
    ///
    /// - Important: Changing this property while the state machine is already in this state, will **not** present the new scene; this property takes effect only in `didEnter(from:)`.
    public var associatedSceneClass: OctopusScene.Type?
    
    /// The object to inform about state transitions, and to recieve scene transition effects from. Generally set to the current scene.
    ///
    /// This is read-only and is dynamically set by `OctopusGameState` to the incoming or outgoing scene as appropriate.
    public fileprivate(set) weak var delegate: OctopusGameStateDelegate?
    
    /// Creates a game state and associates it with the specified scene class.
    public init(associatedSceneClass: OctopusScene.Type?) {
        super.init()
        self.associatedSceneClass = associatedSceneClass
    }
    
    /// - Important: When overriding in a subclass, take care of when you call `super.didEnter(from:)` as that affects when the current `OctopusScene` is notified via `gameControllerDidEnterState(_:from:)`. If you need to perform some tasks before the code in the scene is called, do so before calling `super`.
    public override func didEnter(from previousState: GKState?) {
        
        super.didEnter(from: previousState)
        OctopusKit.logForStates.add("\(String(optional: previousState)) → \(self)")
    
        // ℹ️ DESIGN: Should the scene presentation be an optional step to be decided by the sublass? — No: A state should always display its associated scene, but the logic for deciding whether to enter an state should be made in `isValidNextState(_:)`.
        // To programitically modify the `associatedSceneClass` at runtime, override and replace `didEnter(from:)` or `willExit(to:)`
        
        guard let sceneController = OctopusKit.shared?.sceneController else {
            OctopusKit.logForErrors.add("OctopusKit.shared.sceneController is nil.")
            return }
    
        // If this state does not have any scene associated with it, as might be the case for "abstract" states, log so and exit.
        
        guard let associatedSceneClass = self.associatedSceneClass else {
            OctopusKit.logForDebug.add("\(self) has no associated scene.")
            return
        }
        
        // Set the state's delegate to the current scene before the transition, so we can query it for the outgoing visual transition effect ahead.
        
        self.delegate = OctopusKit.shared?.currentScene
        
        var incomingScene: OctopusScene? // Explained ahead.
        
        // Present the scene class associated with this state, if we are the very first state of the game, or if it is not already the current scene (as is the case of scenes which handle multiple game states.)
        
        if OctopusKit.shared?.currentScene == nil // This check comes first, so we can safely force-unwrap the optional in the next
            || type(of: OctopusKit.shared!.currentScene!) != associatedSceneClass
        {
            // ℹ️ DESIGN: It makes more sense for the outgoing state/scene to decide the transition effect, which may depend on their variables, rather than the incoming scene.
            
            let transition = self.delegate?.transition(for: type(of: self))
            
            // Store the newly created scene in a variable so we can notify the incoming scene instead of the outgoing scene, in case there is a long visual `SKTransition` between the scenes.
            
            incomingScene = sceneController.createAndPresentScene(
                ofClass: associatedSceneClass,
                withTransition: transition)
        }
        
        // Make sure we have a scene by now before notifying it of the new state.
        
        guard let currentScene = OctopusKit.shared?.currentScene else {
            OctopusKit.logForErrors.add("\(self) could not create \(associatedSceneClass)")
            return
        }
        
        // Check whether the current scene or incoming scene matches the scene class associated with this game state.
        
        // NOTE: Make sure to unwrap optionals before comparing types. :)
                
        if  type(of: currentScene) != associatedSceneClass,
            (incomingScene != nil && type(of: incomingScene!) != associatedSceneClass)
        {
            OctopusKit.logForErrors.add("Neither \(currentScene) nor \(String(describing: incomingScene)) is \(String(describing: associatedSceneClass))")
        }
        
        // ⚠️ NOTE: If there was a visual transition effect between scenes, then `OctopusKit.shared?.currentScene` may NOT point to the new scene if the transition is still ongoing by this time. To ensure that we notify the NEW scene, we stored it in a variable when we called `sceneController.createAndPresentScene`.

        self.delegate = incomingScene ?? currentScene // CHECK: Is it a good idea to fall back to `currentScene` here?
        
        self.delegate?.gameControllerDidEnterState(self, from: previousState)
    }
    
    /// - Important: When overriding in a subclass, take care of when you call `super.willExit(to:)` as that affects when the current `OctopusScene` is notified via `currentScene.gameControllerWillExitState(_,to:)`. If you need to perform some tasks before the code in the scene is called, do so before calling `super`.
    public override func willExit(to nextState: GKState) {
        OctopusKit.logForStates.add("\(self) → \(nextState)")
        super.willExit(to: nextState)
        
        // Notify our delegate, to let it perform any outgoing animations etc., or in case the game uses a single scene for multiple states (e.g. displaying an overlay for the paused state, menus, etc. on the gameplay view.)
        
        if OctopusKit.shared?.currentScene !== self.delegate {
            OctopusKit.logForWarnings.add("OctopusKit.shared.currentScene: \(String(optional: OctopusKit.shared?.currentScene)) !== self.delegate: \(String(optional: self.delegate))")
        }
        
        self.delegate?.gameControllerWillExitState(self, to: nextState)
    }
    
    deinit {
        OctopusKit.logForDeinits.add("\(self)")
    }
    
    // MARK: - OctopusSceneDelegate
    
    // ℹ️ NOTE: This section should not be in an extension because "Declarations from extensions cannot be overridden yet."
    
    /// Abstract; To be implemented by subclass. Default behavior is to redirect to `octopusSceneDidChooseNextGameState(_)`.
    public func octopusSceneDidFinish(_ scene: OctopusScene) {
        // CHECK: Should this be the default behavior? It may be helpful in showing a series of credits or intros/cutscenes etc.
        self.octopusSceneDidChooseNextGameState(scene)
    }
    
    /// Abstract; To be implemented by subclass.
    @discardableResult public func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        return false
    }
    
    /// Abstract; To be implemented by subclass.
    @discardableResult public func octopusSceneDidChoosePreviousGameState(_ scene: OctopusScene) -> Bool {
        return false
    }
    
    /// Signals the `OctopusGameController` or its subclass to enter the requested state.
    @discardableResult public func octopusScene(_ scene: OctopusScene, didRequestGameStateClass stateClass: OctopusGameState.Type) -> Bool {
        return stateMachine?.enter(stateClass) ?? false
    }
    
    /// Not handled by `OctopusGameState`. Should be handled by `OctopusSceneController`.
    public func octopusScene(_ outgoingScene: OctopusScene,
                             didRequestTransitionTo nextSceneFileName: String,
                             withTransition transition: SKTransition?)
    {
        OctopusKit.logForErrors.add("Not implemented — Implememt in subclass or redirect to OctopusSceneController")
    }
    
    /// Not handled by `OctopusGameState`. Should be handled by `OctopusSceneController`.
    public func octopusScene(_ outgoingScene: OctopusScene,
                             didRequestTransitionTo nextSceneClass: OctopusScene.Type,
                             withTransition transition: SKTransition?)
    {
        OctopusKit.logForErrors.add("Not implemented — Implememt in subclass or redirect to OctopusSceneController")
    }
    
}
