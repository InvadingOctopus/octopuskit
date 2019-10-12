//
//  OctopusGameController.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/07.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Combine
import GameplayKit

/// The primary coordinator for the various states a game may be in.
///
/// This is a "controller" in the MVC sense; use this class to coordinate game states and scenes, and to manage global objects that must be shared across scenes, such as the game world, player data, and network connections etc.
///
/// You may use `OctopusGameController` as-is or subclass it to add any global/top-level functionality that is specific to your game.
open class OctopusGameController: GKStateMachine, OctopusScenePresenter {
    
    /// Invoked by the `OctopusSpriteKitViewController` to start the game after the system/application presents the view.
    ///
    /// This should be set during `OctopusAppDelegate.applicationWillLaunchOctopusKit()` after the app launches.
    public let initialStateClass: OctopusGameState.Type
    
    public fileprivate(set) var didEnterInitialState: Bool = false
    
    public weak var viewController: OctopusViewController?
    
    public var spriteKitView: SKView? {
        viewController?.spriteKitView
    }

    public var currentScene: OctopusScene? {
        didSet {
            // TODO: Set viewController scene
        }
    }
    
    public var currentGameState: OctopusGameState? {
        if  let currentGameState = self.currentState as? OctopusGameState {
            return currentGameState
        } else {
            OctopusKit.logForWarnings.add("Cannot cast \(String(optional: currentState)) as OctopusGameState")
            return nil
        }
    }

    /// A global entity for encapsulating components which manage data that must persist across scenes, such as the overall game world, active play session, or network connections etc.
    ///
    /// - Important: Must be manually added to scenes that require it.
    public let entity: OctopusEntity

    public private(set) var notifications: [AnyCancellable] = []
    
    // MARK: - Life Cycle
    
    public init(states: [OctopusGameState],
                initialStateClass: OctopusGameState.Type)
    {
        self.initialStateClass = initialStateClass
        self.entity = OctopusEntity(name: OctopusKit.Constants.Strings.gameControllerEntityName)
        super.init(states: states)
        registerForNotifications()
    }
    
    private override init(states: [GKState]) {
        // The default initializer is hidden so that only `OctopusGameState` is accepted.
        fatalError("OctopusGameController(states:) not implemented. Initialize with OctopusGameController(states:initialStateClass:)")
    }
    
    fileprivate func registerForNotifications() {
        self.notifications = [
            
            NotificationCenter.default.publisher(for: OSApplication.didFinishLaunchingNotification)
                .sink { _ in OctopusKit.logForFramework.add("🌼 OSApplication.didFinishLaunchingNotification") },
            
            NotificationCenter.default.publisher(for: OSApplication.willEnterForegroundNotification)
                .sink { _ in
                    OctopusKit.logForFramework.add("🌼 OSApplication.willEnterForegroundNotification")
                    self.currentScene?.applicationWillEnterForeground()
            },
            
            NotificationCenter.default.publisher(for: OSApplication.didBecomeActiveNotification)
                .sink { _ in
                    OctopusKit.logForFramework.add("🌼 OSApplication.didBecomeActiveNotification")
                    
                    // NOTE: Call `scene.applicationDidBecomeActive()` before `enterInitialState()` so we don't issue a superfluous unpause event to the very first scene of the game.
                    
                    // CHECK: Compare launch performance between calling `OctopusSceneController.enterInitialState()` from `OctopusAppDelegate.applicationDidBecomeActive(_:)`! versus `OctopusSceneController.viewWillLayoutSubviews()`
                    
                    if  let scene = self.currentScene {
                        scene.applicationDidBecomeActive()
                    }
                    else if !self.didEnterInitialState {
                        self.enterInitialState()
                    }
            },
            
            NotificationCenter.default.publisher(for: OSApplication.willResignActiveNotification)
                .sink { _ in
                    OctopusKit.logForFramework.add("🌼 OSApplication.willResignActiveNotification")
                    self.currentScene?.applicationWillResignActive()
            },
            
            NotificationCenter.default.publisher(for: OSApplication.didEnterBackgroundNotification)
                .sink { _ in
                    OctopusKit.logForFramework.add("🌼 OSApplication.didEnterBackgroundNotification")
                    self.currentScene?.applicationDidEnterBackground()
            }
        ]
    }
    
    /// Attempts to enter the state specified by `initialStateClass`.
    @discardableResult internal func enterInitialState() -> Bool {
        OctopusKit.logForFramework.add()
        
        guard OctopusKit.initialized else {
            fatalError("OctopusKit not initialized")
        }
        
        // Even though GKStateMachine should handle the correct transitions between states, this controller should only initiate the initial state only once, just to be extra safe, and also as a flag for other classes to refer to if needed.
        
        guard !didEnterInitialState else {
            OctopusKit.logForFramework.add("didEnterInitialState already set. currentState: \(String(optional: currentState))")
            return false
        }
        
        self.didEnterInitialState = enter(initialStateClass)
        return didEnterInitialState
    }
    
    deinit {
        OctopusKit.logForDeinits.add("\(self)")
    }
    
    // MARK: - OctopusScenePresenter
    
    /// Loads an `.sks` file as an OctopusScene.
    /// - Requires: In the Scene Editor, the scene must have its "Custom Class" set to `OctopusScene` or a subclass of `OctopusScene`.
    open func loadScene(fileNamed fileName: String) -> OctopusScene? {
        // TODO: Error handling
        
        OctopusKit.logForResources.add("fileName = \"\(fileName)\"")
        
        // Load the specified scene as a GKScene. This provides gameplay related content including entities and graphs.
        
        guard let gameplayKitScene = GKScene(fileNamed: fileName) else {
            OctopusKit.logForErrors.add("Cannot load \"\(fileName)\" as GKScene")
            return nil
        }
        
        // Get the OctopusScene/SKScene from the loaded GKScene
        guard let spriteKitScene = gameplayKitScene.rootNode as? OctopusScene else {
            // TODO: Graceful failover to `SKScene(fileNamed:)`
            OctopusKit.logForErrors.add("Cannot load \"\(fileName)\" as an OctopusScene")
            return nil
        }
        
        // Copy gameplay related content over to the scene
        
        spriteKitScene.addEntities(gameplayKitScene.entities)
        spriteKitScene.renameUnnamedEntitiesToNodeNames() // TODO: FIX: ⚠️ Does not work when loading an `.sks` because Editor-created entities are not `OctopusEntity`
        spriteKitScene.graphs = gameplayKitScene.graphs
        spriteKitScene.octopusSceneDelegate = self.currentGameState
        
        return spriteKitScene
    }
    
    open func createScene(ofClass sceneClass: OctopusScene.Type) -> OctopusScene?
    {
        OctopusKit.logForFramework.add("\(sceneClass)")
        
        guard let spriteKitView = self.spriteKitView else {
            fatalError("\(self) does not have a spriteKitView?") // TODO: Add internationalization.
        }
        
        let newScene = sceneClass.init(size: spriteKitView.frame.size)
        newScene.octopusSceneDelegate = self.currentGameState
        
        return newScene
    }
    
    /// - Parameter incomingScene: The scene to present.
    /// - Parameter transitionOverride: The transition animation to display between scenes.
    ///
    ///     If `nil` or omitted, the transition is provided by the `transition(for:)` method of the current scene, if any.
    open func presentScene(_ incomingScene: OctopusScene,
                      withTransition transitionOverride: SKTransition? = nil)
    {
        OctopusKit.logForFramework.add("\(String(optional: self.spriteKitView?.scene)) → [\(transitionOverride == nil ? "no transition override" : String(optional: transitionOverride))] → \(incomingScene)")
        
        guard let spriteKitView = self.spriteKitView else {
            fatalError("\(self) does not have an spriteKitView?") // TODO: Add internationalization.
        }
        
        // Notify the incoming scene that it is about to be presented.
        // CHECK: Casting `as? OctopusScene` not necessary anymore?
        
        incomingScene.octopusSceneDelegate = self.currentGameState
        incomingScene.gameController = self
        incomingScene.willMove(to: spriteKitView)
        
        // If an overriding transition has not been specified, let the current scene decide the visual effect for the transition to the next scene.
        
        // ℹ️ DESIGN: It makes more sense for the outgoing state/scene to decide the transition effect, which may depend on their variables, rather than the incoming scene.
        
        let transition = transitionOverride ?? self.currentScene?.transition(for: type(of: incomingScene))
        
        if let transition = transition {
            spriteKitView.presentScene(incomingScene, transition: transition)
        } else {
            spriteKitView.presentScene(incomingScene)
        }
    }
    
}
