//
//  OKGameState.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import SwiftUI

public typealias OctopusGameStateDelegate = OKGameStateDelegate
public typealias OctopusGameState = OKGameState

/// A protocol for types that will receive notifications about state transitions, and can provide visual effects for scene transitions.
public protocol OKGameStateDelegate: class {
    func gameCoordinatorDidEnterState(_ state: GKState, from previousState: GKState?)
    func gameCoordinatorWillExitState(_ exitingState: GKState, to nextState: GKState)
}

/// Abstract base class for game states.
open class OKGameState: GKState, OKSceneDelegate, ObservableObject {
    
    // ℹ️ DESIGN: Not including a `gameCoordinator: OKGameCoordinator` property in `OKGameState`, so that subclasses may provide their own `gameCoordinator` property with their custom subclass of `OKGameCoordinator` if needed.
    
    // ℹ️ Even though there is a `OKGameStateDelegate` protocol, `OKGameState` only exposes a `delegate` for formality but it does not use it. The reason is that in certain situations, an `OKGameState` may have more than one "delegate" that it needs to send notifications to, e.g. both an outgoing scene and an incoming scene in the case of visual scene transition effects with a long duration. The `delegate` property may be opened as a future customization point.
    
    // MARK: - Properties
    
    /// Specifies the possible states that this state may transition to. If this array is empty, then all states are allowed (the default.)
    ///
    /// Checked by `isValidNextState(_:)`.
    ///
    /// - Important: This property should describe the **static** relationships between state classes that determine the set of edges in a state machine’s state graph; Do **not** perform conditional logic in this property to conditionally control state transitions. Check conditions before attempting to transition to a different state.
    open var validNextStates: [OKGameState.Type] {
        []
    }
    
    /// The scene that will be presented when the `OKGameCoordinator` (or your custom subclass) enters this state.
    ///
    /// - IMPORTANT: Changing this property while the state machine is already in this state, will **not** present the new scene; this property takes effect only in `didEnter(from:)`.
    public var associatedSceneClass: OKScene.Type?
    
    // TODO: SWIFT LIMITATION: `associatedSwiftUIView` is an `AnyView` until we can figure out how to pass views conveniently and efficiently.
    // Casting to `AnyView` may decrease performance, according to:
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-return-different-view-types
    
    /// The SwiftUI layer to display over the game's SpriteKit view.
    @Published public var associatedSwiftUIView: AnyView
    
    @inlinable
    open var gameCoordinator: OKGameCoordinator? {
        if  let gameCoordinator = self.stateMachine as? OKGameCoordinator {
            return gameCoordinator
        } else {
            OctopusKit.logForErrors.add("Cannot cast stateMachine as OKGameCoordinator")
            return nil
        }
    }
    
    /// The object to inform about state transitions, and to receive scene transition effects from. Generally set to the current scene.
    ///
    /// This is read-only and is dynamically set by `OKGameState` to the incoming or outgoing scene as appropriate.
    public fileprivate(set) weak var delegate: OKGameStateDelegate? {
        didSet {
            // Can't use @LogChanges because "Property with a wrapper cannot also be weak"
            OctopusKit.logForFramework.add("\(oldValue) → \(delegate)")
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a game state and associates it with the specified scene class.
    public init(associatedSceneClass: OKScene.Type? = nil)
    {
        // TODO: Remove this init once we figure out how to provide default arguments for `associatedSwiftUIView` without using AnyView. :|
        self.associatedSceneClass  = associatedSceneClass
        self.associatedSwiftUIView = AnyView(EmptyView())
        super.init()
    }
    
    /// Creates a game state and associates it with the specified scene class and UI overlay.
    public init <ViewType: View> (associatedSceneClass:  OKScene.Type? = nil,
                                  associatedSwiftUIView: ViewType)
    {
        self.associatedSceneClass  = associatedSceneClass
        self.associatedSwiftUIView = AnyView(associatedSwiftUIView)
        super.init()
    }
    
    /// Creates a game state and associates it with the specified scene class and UI overlay.
    ///
    /// You may construct a SwiftUI view as a trailing closure to this initializer.
    public init <ViewType: View> (associatedSceneClass: OKScene.Type? = nil,
                                  @ViewBuilder associatedSwiftUIView: () -> ViewType)
    {
        self.associatedSceneClass  = associatedSceneClass
        self.associatedSwiftUIView = AnyView(associatedSwiftUIView())
        super.init()
    }
    
    // MARK: - State Transitions
    
    /// - Important: When overriding in a subclass, take care of when you call `super.didEnter(from:)` as that affects when the current `OKScene` is notified via `gameCoordinatorDidEnterState(_:from:)`. If you need to perform some tasks before the code in the scene is called, do so before calling `super`.
    open override func didEnter(from previousState: GKState?) {
        
        OctopusKit.logForStates.add("\(previousState) → \(self)")
        super.didEnter(from: previousState)
        
        // ℹ️ DESIGN: Should the scene presentation be an optional step to be decided by the subclass? — No: A state should always display its associated scene, but the logic for deciding whether to enter an state can be performed elsewhere (except in `isValidNextState(_:)` as per the Apple documentation note.)
        // 💡 To programmatically modify the `associatedSceneClass` at runtime, you may override and replace `didEnter(from:)` or `willExit(to:)`
        
        guard let gameCoordinator = self.gameCoordinator else {
            OctopusKit.logForErrors.add("\(self) has no gameCoordinator")
            return
        }
    
        // If this state does not have any scene associated with it, as might be the case for "abstract" states, log so and exit.
        
        guard let associatedSceneClass = self.associatedSceneClass else {
            OctopusKit.logForDebug.add("\(self) has no associatedSceneClass — A new scene will not be displayed for this state.")
            
            // Set the current scene as the delegate of this new state, so that the scene can properly receive gameCoordinatorWillExitState(_:to:) etc.
            self.delegate = gameCoordinator.currentScene
            
            return
        }
        
        // Present the scene class associated with this state, if we are the very first state of the game, or if it is not already the current scene (as is the case of scenes which handle multiple game states.)
        
        var incomingScene: OKScene? // Explained below.
        
        if  gameCoordinator.currentScene == nil // This check comes first, so we can safely force-unwrap the optional in the next:
            || type(of: gameCoordinator.currentScene!) != associatedSceneClass
        {
            // ℹ️ Store the newly created scene in a variable so we can notify the incoming scene instead of the outgoing scene, in case there is a long visual `SKTransition` between the scenes.
            
            incomingScene = gameCoordinator.createAndPresentScene(ofClass: associatedSceneClass)
        }
        
        // Make sure we have a scene by now before notifying it of the new state.
        
        guard let currentScene = gameCoordinator.currentScene else {
            OctopusKit.logForErrors.add("gameCoordinator does not have a currentScene")
            return
        }
        
        // Check whether the current scene or incoming scene matches the scene class associated with this game state.
        
        // NOTE: Make sure to unwrap optionals before comparing types. :)
                
        if  type(of: currentScene) != associatedSceneClass,
            (incomingScene != nil && type(of: incomingScene!) != associatedSceneClass)
        {
            OctopusKit.logForErrors.add("Neither \(currentScene) nor \(String(describing: incomingScene)) is \(String(describing: associatedSceneClass))")
            // CHECK: Should this be a fatal error?
        }
        
        // ⚠️ NOTE: If there was a visual transition effect between scenes, then `OctopusKit.shared?.currentScene` may NOT point to the new scene if the transition is still ongoing by this time. To ensure that we notify the NEW scene, we stored it in a variable when we called `gameCoordinator.createAndPresentScene`.

        // ℹ️ In case we skipped `createAndPresentScene` (in case of the current scene handling multiple states) then set the scene's delegate to this new game state. Not doing this caused a very hard-to-track bug. :)
        
        // CHECK: Should `self.delegate` be set first or `currentScene.octopusSceneDelegate`?
        
        currentScene.octopusSceneDelegate = self
        
        self.delegate = incomingScene ?? currentScene // Stay with `currentScene` if there is no new scene to be presented.
        
        self.delegate?.gameCoordinatorDidEnterState(self, from: previousState)
    }

    /// Returns `true` if the `validNextStates` property contains `stateClass` or is an empty array (which means all states are allowed.)
    ///
    /// - Important: Do not override this method to conditionally control state transitions. Instead, perform such conditional logic before transitioning to a different state.
    open override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // NOTE: Apple documentation for `isValidNextState(_:)`:
        // Your implementation of this method should describe the static relationships between state classes that determine the set of edges in a state machine’s state graph.
        // ⚠️ Do not use this method to conditionally control state transitions—instead, perform such conditional logic before calling a state machine’s `enter(_:)` method.
        // By restricting the set of valid state transitions, you can use a state machine to enforce invariant conditions in your code. For example, if one state class can be entered only after a state machine has passed through a series of other states, code in that state class can safely assume that any actions performed by those other states have already occurred.
        validNextStates.isEmpty || validNextStates.contains { stateClass == $0 }
    }
    
    /// - Important: When overriding in a subclass, take care of when you call `super.willExit(to:)` as that affects when the current `OKScene` is notified via `currentScene.gameCoordinatorWillExitState(_,to:)`. If you need to perform some tasks before the code in the scene is called, do so before calling `super`.
    open override func willExit(to nextState: GKState) {
        OctopusKit.logForStates.add("\(self) → \(nextState)")
        super.willExit(to: nextState)
        
        // Notify our delegate, to let it perform any outgoing animations etc., or in case the game uses a single scene for multiple states (e.g. displaying an overlay for the paused state, menus, etc. on the gameplay view.)
        
        if  gameCoordinator?.currentScene !== self.delegate {
            OctopusKit.logForWarnings.add("gameCoordinator?.currentScene: \(gameCoordinator?.currentScene) !== self.delegate: \(self.delegate)")
        }
        
        self.delegate?.gameCoordinatorWillExitState(self, to: nextState)
    }
    
    deinit {
        OctopusKit.logForDeinits.add("\(self)")
    }
    
    // MARK: - OKSceneDelegate
    
    // NOTE: The default implementations from `OKSceneDelegate.swift` are duplicated here, as otherwise the implementations in subclasses of `OKGameState` don't seem to get called.
    
    /// Abstract; To be implemented by subclass. Default behavior is to redirect to `octopusSceneDidChooseNextGameState(_:)`.
    open func octopusSceneDidFinish(_ scene: OKScene) {
        // CHECK: Should this be the default behavior? It may be helpful in showing a series of credits or intros/cutscenes etc.
        self.octopusSceneDidChooseNextGameState(scene)
    }
    
    /// Abstract; To be implemented by subclass.
    @discardableResult open func octopusSceneDidChooseNextGameState(_ scene: OKScene) -> Bool {
        return false
    }
    
    /// Abstract; To be implemented by subclass.
    @discardableResult open func octopusSceneDidChoosePreviousGameState(_ scene: OKScene) -> Bool {
        return false
    }
    
    // NOTE: This section should not be in an extension because "Declarations from extensions cannot be overridden yet."
        
    /// Signals the `OKGameCoordinator` or its subclass to enter the requested state.
    ///
    /// May be overridden in subclass to provide transition validation.
    @discardableResult open func octopusScene(_ scene: OKScene,
                                              didRequestGameState stateClass: OKGameState.Type) -> Bool
    {
        return stateMachine?.enter(stateClass) ?? false
    }
    
    /// Override in subclass to implement more granular control over transitions between specific types of scenes.
    ///
    /// - Parameter transition: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    open func octopusScene(_ outgoingScene: OKScene,
                             didRequestTransitionTo nextSceneFileName: String,
                             withTransition transition: SKTransition?)
    {
        OctopusKit.logForFramework.add("nextSceneFileName: \(nextSceneFileName)")
        self.gameCoordinator?.loadAndPresentScene(fileNamed: nextSceneFileName, withTransition: transition)
        // outgoingScene.isPaused = false // CHECK: Necessary?
    }
    
    /// Override in subclass to implement more granular control over transitions between specific types of scenes.
    ///
    /// - Parameter transition: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    open func octopusScene(_ outgoingScene: OKScene,
                             didRequestTransitionTo nextSceneClass: OKScene.Type,
                             withTransition transition: SKTransition?)
    {
        OctopusKit.logForFramework.add("nextSceneClass: \(nextSceneClass)")
        self.gameCoordinator?.createAndPresentScene(ofClass: nextSceneClass, withTransition: transition)
        // outgoingScene.isPaused = false // CHECK: Necessary?
    }
}
