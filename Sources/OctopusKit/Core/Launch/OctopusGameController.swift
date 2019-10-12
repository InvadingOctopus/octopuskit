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
open class OctopusGameController: GKStateMachine, OctopusScenePresenter, OctopusSceneDelegate {
    
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
    
    /// A global entity for encapsulating components which manage data that must persist across scenes, such as the overal game world, active play session, or network connections etc.
    ///
    /// - Important: Must be manually added to scenes that require it.
    public let entity: OctopusEntity

    public private(set) var notifications: [AnyCancellable] = []
    
    public var gameController: OctopusGameController? { self } // TODO: Remove this requirement from the protocol.
    
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
    
    /// Attemtps to enter the state specified by `initialStateClass`.
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
}
