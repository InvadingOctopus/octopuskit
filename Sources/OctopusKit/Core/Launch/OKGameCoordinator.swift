//
//  OKGameCoordinator.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import Combine
import GameplayKit

public typealias OctopusGameCoordinator = OKGameCoordinator

/// Coordinates all the possible states and scenes of a game, and manages top-level state and game-specific data that must persist across different game states.
///
/// One of the core objects for an OctopusKit game, along with `OctopusKit` and `OKViewController`.
///
/// This is a "controller" in the MVC sense; use this class to maintain global objects such as the game world, player data, and network connections etc. You may use `OKGameCoordinator` as-is and add components to its `entity`, or subclass it to add complex top-level functionality specific to your game.
///
/// **Usage**
///
/// 1. Your application's launch cycle must initialize an instance of `OKGameCoordinator` or its subclass, specifying a list of all possible states your game can be in, represented by `OKGameState`. Each state must have an `OKGameScene` associated with, as well as an optional `SwiftUI` overlay view. See the documentation for `OKGameCoordinator`.
///
///     ```
///     let myGameCoordinator = OKGameCoordinator(
///         states: [MyOKGameStateSubclassA(),
///                  PlayState(),
///                  PausedState(),
///                  GameOverState() ],
///         initialStateClass: PlayState.self)
///     ```
///     or use a subclass:
///     ```
///     OctopusKit(gameCoordinator: MyCustomGameCoordinator())
///     ```
///     or simply, if your game has a single scene:
///     ```
///     let myGameCoordinator = OKGameCoordinator(
///         states: [OKGameState(associatedSceneClass:  MyScene.self,
///                                   associatedSwiftUIView: MyUI() ) ])
///     ```
///
/// 2. Call `OctopusKit(gameCoordinator:)` to initialize the `OctopusKit.shared` singleton instance, which all other objects will refer to when they need to access the game coordinator and other top-level objects.
///
/// 3. Use an `OKViewController` in your UI hierarchy to present the game coordinator's scenes.
///
/// - NOTE: The recommended way to setup and present an OctopusKit game is to use the `OKContainerView` for **SwiftUI**.
open class OKGameCoordinator: OKStateMachine, OKScenePresenter, ObservableObject {
    
    /// Invoked by the `OKSpriteKitViewController` to start the game after the system/application presents the view.
    ///
    /// This should be set during the application launch process.
    public let initialStateClass: OKGameState.Type
    
    public fileprivate(set) var didEnterInitialState: Bool = false
    
    @Published public var currentGameState: OKGameState? = nil {
        didSet {
            OKLog.logForFramework.debug("\(oldValue) → \(currentGameState)")
        }
    }

    /// Returns the `previousState` as an `OKGameState`, if applicable.
    @inlinable
    public var previousGameState: OKGameState? {
        self.previousState as? OKGameState
    }

    /// Returns the `previousStateClass` as an `OKGameState.Type`, if applicable.
    @inlinable
    public var previousGameStateClass: OKGameState.Type? {
        self.previousStateClass as? OKGameState.Type
    }

    public weak var viewController: OKViewController? {
        didSet {
            // Can't use @LogChanges because "Property with a wrapper cannot also be weak"
            OKLog.logForFramework.debug("\(oldValue) → \(viewController)")
        }
    }
    
    @inlinable
    public var spriteKitView: SKView? {
        viewController?.spriteKitView
    }

    @Published public var currentScene: OKScene? {
           didSet {
               OKLog.logForFramework.debug("\(oldValue) → \(currentScene)")
           }
       }
    
    /// A global entity for encapsulating components which manage data that must persist across scenes, such as the overall game world, active play session, or network connections etc.
    ///
    /// - IMPORTANT: **Do NOT** update this entity or its components directly; it must be manually added to scenes which require it, so that global components are updated in the order specified by each scene's `componentSystems` array, to preserve component dependencies.
    public let entity: OKEntity

    public private(set) var notifications: [AnyCancellable] = []
    
    // MARK: - Life Cycle
    
    /// Initializes the top-level game coordinator which holds a list of all the possible states for your game, such as main menu, playing or paused.
    public init(states: [OKGameState],
                initialStateClass: OKGameState.Type)
    {
        OKLog.logForFramework.debug("states: \(states) — initial: \(initialStateClass)")
        
        assert(!states.isEmpty, "OKGameCoordinator must be initialized with at least one game state!")
        
        self.initialStateClass = initialStateClass
        self.entity = OKEntity(name: OctopusKit.Constants.Strings.gameCoordinatorEntityName)
        super.init(states: states)
        registerForNotifications()
    }
    
    /// Initializes the top-level game coordinator which holds a list of all the possible states for your game, such as main menu, playing or paused.
    ///
    /// The initial game state is set to the first item in the `states` array.
    public override init(states: [GKState]) {
        
        assert(!states.isEmpty, "OKGameCoordinator must be initialized with at least one game state!")
        
        // Only `OKGameState`s should be allowed.
        guard let states = states as? [OKGameState] else {
            fatalError("The states argument must be an array of OKGameState or its subclasses.")
        }
        
        self.initialStateClass = type(of: states.first!)
        
        OKLog.logForFramework.debug("states: \(states) — initial: initialStateClass")
        
        self.entity = OKEntity(name: OctopusKit.Constants.Strings.gameCoordinatorEntityName)
        super.init(states: states)
        registerForNotifications()
    }

    private init() {
        fatalError("OKGameCoordinator must be initialized with at least one game state!")
    }
    
    fileprivate func registerForNotifications() {

        self.notifications = [
            
            NotificationCenter.default.publisher(for: OSApplication.didFinishLaunchingNotification)
                .sink { _ in
                    OKLog.logForDebug.debug("Application.didFinishLaunchingNotification")
                    // NOTE: Will not be received in a SwiftUI application, as this function will be called after the application has launched.
            },
            
            NotificationCenter.default.publisher(for: OSApplication.didBecomeActiveNotification)
                .sink { _ in
                    OKLog.logForDebug.debug("Application.didBecomeActiveNotification")
                    
                    // NOTE: If there is already an ongoing scene (maybe the application launch cycle was customized), call `scene.applicationDidBecomeActive()` before `enterInitialState()` so we don't issue a superfluous unpause event.
                                        
                    if  let scene = self.currentScene {
                        scene.applicationDidBecomeActive()
                    }
                    else if !self.didEnterInitialState {
                        self.enterInitialState()
                    }
            },
            
            NotificationCenter.default.publisher(for: OSApplication.willResignActiveNotification)
                .sink { _ in
                    OKLog.logForDebug.debug("Application.willResignActiveNotification")
                    self.currentScene?.applicationWillResignActive()
            }
            
        ]
        
        #if canImport(AppKit)
        
        self.notifications += [
            
            NotificationCenter.default.publisher(for: OSApplication.willFinishLaunchingNotification)
                .sink { _ in
                    OKLog.logForDebug.debug("Application.willFinishLaunchingNotification")
                    // NOTE: Will not be received in a SwiftUI application, as this function will be called after the application has launched.
            }
        ]
        
        #endif
        
        #if canImport(UIKit)
        
        self.notifications += [
            
            NotificationCenter.default.publisher(for: OSApplication.willEnterForegroundNotification)
                .sink { _ in
                    OKLog.logForDebug.debug("Application.willEnterForegroundNotification")
                    self.currentScene?.applicationWillEnterForeground()
            },
            
            NotificationCenter.default.publisher(for: OSApplication.didEnterBackgroundNotification)
                .sink { _ in
                    OKLog.logForDebug.debug("Application.didEnterBackgroundNotification")
                    self.currentScene?.applicationDidEnterBackground()
            }
        ]
        
        #endif
    }
    
    @discardableResult
    open override func enter(_ stateClass: AnyClass) -> Bool {
        
        // We override this method to send `ObservableObject` updates for `currentGameState` to support SwiftUI.
        
        // NOTE: SWIFT LIMITATION: `currentGameState` should be a @Published property with a simple getter that casts `GKStateMachine.currentState as? OKGameState`, but we cannot do that because:
        // "Property wrapper cannot be applied to a computed property"
        // and we cannot remove @Published and use objectWillChange.send() in a `willSet` because:
        // "willSet cannot be provided together with a getter"
        // and we cannot provide a `willSet` for `GKStateMachine.currentState` because:
        // "Cannot observe read-only property currentState; it can't change" :(
        
        // Okay, so we'll just use objectWillChange.send() in the enter(_:) override below.
        
        // CHECK: HOWEVER, even without objectWillChange.send() the derived properties in SwiftUI views depending on `currentGameState` seem to update just fine. Not sure about all this yet.
        
        // CHECK: There are two conditions before `currentGameState` is actually changed; when should we emit the `objectWillChange`?
        
        if  self.canEnterState(stateClass) {
            self.objectWillChange.send()
        } else {
            OKLog.logForWarnings.debug("Cannot enter \(stateClass) from currentState: \(currentState)")
            return false
        }
        
        // Set the `currentGameState` before calling `super.enter(_:)`, so that OKGameState.didEnter(from:) can see the correct state when it checks `currentGameState`
        
        if  let stateClass = stateClass as? OKGameState.Type {
            self.currentGameState = self.state(forClass: stateClass)
        } else {
            OKLog.logForErrors.debug("Cannot cast \(stateClass) as OKGameState")
        }
       
        // Call the parent implementation which will set the actual state.
        
        let didEnterRequestedState = super.enter(stateClass)
        
        // Confirm that the final result matches the expected values.
        
        if  didEnterRequestedState {
            
            if  self.currentState != self.currentGameState {
                OKLog.logForErrors.debug("currentState: \(currentGameState) != currentGameState: \(currentGameState)")
            }
            
        } else {
            
            OKLog.logForWarnings.debug("Could not enter \(stateClass) — currentState: \(currentState)")
            
            // Reset the `currentGameState` to the actual state.
            
            if  let currentState = self.currentState as? OKGameState {
                self.currentGameState = currentState
            } else {
                OKLog.logForErrors.debug("Cannot cast \(stateClass) as OKGameState")
            }
        }
        
        return didEnterRequestedState
    }
    
    /// Attempts to enter the state specified by `initialStateClass`.
    @discardableResult internal func enterInitialState() -> Bool {
        OctopusKit.logForFramework()
        
        guard OctopusKit.initialized else {
            fatalError("OctopusKit not initialized")
        }
        
        // Even though GKStateMachine should handle the correct transitions between states, this coordinator should only initiate the initial state only once, just to be extra safe, and also as a flag for other classes to refer to if needed.
        
        guard !didEnterInitialState else {
            OKLog.logForFramework.debug("didEnterInitialState already set. currentState: \(currentState)")
            return false
        }
        
        if  viewController == nil {
            OKLog.logForDebug.debug("enterInitialState() called before viewController was set — May not be able to display the first scene. Ignore this warning if the OKGameCoordinator was initialized early in the application life cycle.")
        }
        
        if  self.canEnterState(initialStateClass) {
            // Customization point for subclasses.
            self.willEnterInitialState()
        }
        
        self.didEnterInitialState = enter(initialStateClass)
        
        return didEnterInitialState
    }
    
    deinit { OctopusKit.logForDeinits("\(self)") }

    // MARK: - Abstract Methods
    
    /// Abstract; to be implemented by a subclass. Override this to add any global components etc.
    open func willEnterInitialState() {}
    
}
