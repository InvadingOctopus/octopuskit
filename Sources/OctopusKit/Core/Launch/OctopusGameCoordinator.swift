//
//  OctopusGameCoordinator.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/07.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Combine
import GameplayKit

public typealias OKGameCoordinator = OctopusGameCoordinator

/// Coordinates all the possible states and scenes of a game, and manages top-level state and game-specific data that must persist across different game states.
///
/// One of the core objects for an OctopusKit game, along with `OctopusKit` and `OctopusViewController`.
///
/// This is a "controller" in the MVC sense; use this class to maintain global objects such as the game world, player data, and network connections etc. You may use `OctopusGameCoordinator` as-is and add components to its `entity`, or subclass it to add complex top-level functionality specific to your game.
///
/// **Usage**
///
/// 1. Your application's launch cycle must initialize an instance of `OctopusGameCoordinator` or its subclass, specifying a list of all possible states your game can be in, represented by `OctopusGameState`. Each state must have an `OctopusGameScene` associated with, as well as an optional `SwiftUI` overlay view. See the documentation for `OctopusGameCoordinator`.
///
///     ```
///     let myGameCoordinator = OctopusGameCoordinator(
///         states: [MyOctopusGameStateSubclassA(),
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
///     let myGameCoordinator = OctopusGameCoordinator(
///         states: [OctopusGameState(associatedSceneClass:  MyScene.self,
///                                   associatedSwiftUIView: MyUI() ) ])
///     ```
///
/// 2. Call `OctopusKit(gameCoordinator:)` to initialize the `OctopusKit.shared` singleton instance, which all other objects will refer to when they need to access the game coordinator and other top-level objects.
///
/// 3. Use an `OctopusViewController` in your UI hierarchy to present the game coordinator's scenes.
///
/// - NOTE: The recommended way to setup and present an OctopusKit game is to use the `OctopusKitContainerView` for **SwiftUI**.
open class OctopusGameCoordinator: GKStateMachine, OctopusScenePresenter, ObservableObject {
    
    /// Invoked by the `OctopusSpriteKitViewController` to start the game after the system/application presents the view.
    ///
    /// This should be set during `OctopusAppDelegate.applicationWillLaunchOctopusKit()` after the app launches.
    public let initialStateClass: OctopusGameState.Type
    
    public fileprivate(set) var didEnterInitialState: Bool = false

    @Published public var currentGameState: OctopusGameState? = nil {
        didSet {
            OctopusKit.logForFramework.add("\(oldValue) → \(currentGameState)")
        }
    }
    
    public var currentGameState0: OctopusGameState? {

        // NOTE: SWIFT LIMITATION: This property should be @Published but we cannot do that because
        // "Property wrapper cannot be applied to a computed property" and
        // "willSet cannot be provided together with a getter"
        // and we cannot provide a `willSet` for `GKStateMachine.currentState` because
        // "Cannot observe read-only property currentState; it can't change" :(
        // Okay so we'll just use objectWillChange.send() in the enter(_:) override below.
        // HOWEVER, even without objectWillChange.send() the derived properties in SwiftUI views depending on `currentGameState` seem to update just fine. Not sure about all this yet.

        get {
            if  let currentGameState = self.currentState as? OctopusGameState {
                return currentGameState
            } else {
                OctopusKit.logForWarnings.add("Cannot cast \(currentState) as OctopusGameState")
                return nil
            }
        }
        
    }
        
    public weak var viewController: OctopusViewController? {
        didSet {
            // Can't use @LogChanges because "Property with a wrapper cannot also be weak"
            OctopusKit.logForFramework.add("\(oldValue) → \(viewController)")
        }
    }
    
    public var spriteKitView: SKView? {
        viewController?.spriteKitView
    }

    @Published public var currentScene: OctopusScene? {
           didSet {
               OctopusKit.logForFramework.add("\(oldValue) → \(currentScene)")
           }
       }
    
    /// A global entity for encapsulating components which manage data that must persist across scenes, such as the overall game world, active play session, or network connections etc.
    ///
    /// - IMPORTANT: **Do NOT** update this entity or its components directly; it must be manually added to scenes which require it, so that global components are updated in the order specified by each scene's `componentSystems` array, to preserve component dependencies.
    public let entity: OctopusEntity

    public private(set) var notifications: [AnyCancellable] = []
    
    // MARK: - Life Cycle
    
    /// Initializes the top-level game coordinator which holds a list of all the possible states for your game, such as main menu, playing or paused.
    ///
    /// You may omit the `initialStateClass` argument to use the first item of the `states` array as the initial state.
    public init(states: [OctopusGameState],
                initialStateClass: OctopusGameState.Type)
    {
        OctopusKit.logForFramework.add("states: \(states) — initial: \(initialStateClass)")
        
        assert(!states.isEmpty, "OctopusGameCoordinator must be initialized with at least one game state!")
        
        self.initialStateClass = initialStateClass
        self.entity = OctopusEntity(name: OctopusKit.Constants.Strings.gameCoordinatorEntityName)
        super.init(states: states)
        registerForNotifications()
    }
    
    /// Convenience initializer which sets the initial game state to the first item passed in the `states` array.
    public convenience init(states: [OctopusGameState]) {
        
        assert(!states.isEmpty, "OctopusGameCoordinator must be initialized with at least one game state!")
        
        self.init(states: states,
                  initialStateClass: type(of: states.first!))
    }
    
    private override init(states: [GKState]) {
        // The default initializer is hidden so that only `OctopusGameState` is accepted.
        fatalError("OctopusGameCoordinator(states:) not implemented. Initialize with OctopusGameCoordinator(states:initialStateClass:)")
    }
    
    private init() {
        fatalError("OctopusGameCoordinator must be initialized with at least one game state!")
    }
    
    fileprivate func registerForNotifications() {

        self.notifications = [
            
            NotificationCenter.default.publisher(for: OSApplication.didFinishLaunchingNotification)
                .sink { _ in OctopusKit.logForDebug.add("Application.didFinishLaunchingNotification") },
            
            NotificationCenter.default.publisher(for: OSApplication.didBecomeActiveNotification)
                .sink { _ in
                    OctopusKit.logForDebug.add("Application.didBecomeActiveNotification")
                    
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
                    OctopusKit.logForDebug.add("Application.willResignActiveNotification")
                    self.currentScene?.applicationWillResignActive()
            }
            
        ]
        
        #if canImport(UIKit)
        
        self.notifications += [
            
            NotificationCenter.default.publisher(for: OSApplication.willEnterForegroundNotification)
                .sink { _ in
                    OctopusKit.logForDebug.add("Application.willEnterForegroundNotification")
                    self.currentScene?.applicationWillEnterForeground()
            },
            
            NotificationCenter.default.publisher(for: OSApplication.didEnterBackgroundNotification)
                .sink { _ in
                    OctopusKit.logForDebug.add("Application.didEnterBackgroundNotification")
                    self.currentScene?.applicationDidEnterBackground()
            }
        ]
        
        #endif
    }
    
    open override func enter(_ stateClass: AnyClass) -> Bool {
        
        // We override this method to send `ObservableObject` updates for `currentGameState` to support SwiftUI.
        
        // NOTE: SWIFT LIMITATION: `currentGameState` should be a @Published property with a simple getter that casts `GKStateMachine.currentState as? OctopusGameState`, but we cannot do that because:
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
        }
        
        let didEnterRequestedState = super.enter(stateClass)
        
        if  didEnterRequestedState {
            
            if  let stateClass = stateClass as? OctopusGameState.Type {
                self.currentGameState = self.state(forClass: stateClass)
            } else {
                OctopusKit.logForWarnings.add("Cannot cast \(stateClass) as OctopusGameState")
            }
            
        }
        
        return didEnterRequestedState
    }
    
    /// Attempts to enter the state specified by `initialStateClass`.
    @discardableResult internal func enterInitialState() -> Bool {
        OctopusKit.logForFramework.add()
        
        guard OctopusKit.initialized else {
            fatalError("OctopusKit not initialized")
        }
        
        // Even though GKStateMachine should handle the correct transitions between states, this coordinator should only initiate the initial state only once, just to be extra safe, and also as a flag for other classes to refer to if needed.
        
        guard !didEnterInitialState else {
            OctopusKit.logForFramework.add("didEnterInitialState already set. currentState: \(currentState)")
            return false
        }
        
        if  viewController == nil {
            OctopusKit.logForDebug.add("enterInitialState() called before viewController was set — May not be able to display the first scene. Ignore this warning if the OctopusGameCoordinator was initialized early in the application life cycle.")
        }
        
        if  self.canEnterState(initialStateClass) {
            // Customization point for subclasses.
            self.willEnterInitialState()
        }
        
        self.didEnterInitialState = enter(initialStateClass)
        
        return didEnterInitialState
    }
    
    deinit { OctopusKit.logForDeinits.add("\(self)") }

    // MARK: - Abstract Methods
    
    /// Abstract; to be implemented by a subclass. Override this to add any global components etc.
    open func willEnterInitialState() {}
    
}
