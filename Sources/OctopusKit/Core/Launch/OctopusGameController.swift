//
//  OctopusGameController.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/07.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// The primary coordinator for the various states a game may be in.
///
/// This is a "controller" in the MVC sense; use this class to coordinate game states and scenes, and to manage global objects that must be shared across scenes, such as the game world, player data, and network connections etc.
///
/// You may use `OctopusGameController` as-is or subclass it to add any global or top-level functionality that is specific to your game.
public class OctopusGameController: GKStateMachine {
    
    public var sceneController: OctopusSceneController? {
        return OctopusKit.shared?.sceneController
    }
    
    /// Invoked by the `OctopusSceneController` to start the game after the system presents the view.
    ///
    /// This should be set during `OctopusAppDelegate.applicationWillLaunchOctopusKit()` after the app launches.
    public let initialStateClass: OctopusGameState.Type
    
    public fileprivate(set) var didEnterInitialState: Bool = false
    
    /// A global entity for encapsulating components which manage data that must persist across scenes, such as the overal game world, active play session, or network connections etc.
    ///
    /// - Important: Must be manually added to scenes that require it.
    public let entity: OctopusEntity

    public init(states: [OctopusGameState],
                initialStateClass: OctopusGameState.Type)
    {
        self.initialStateClass = initialStateClass
        self.entity = OctopusEntity(name: OctopusKit.Constants.Strings.gameControllerEntityName)
        super.init(states: states)
    }
    
    private override init(states: [GKState]) {
        // Hiding the default initializer so that only `OctopusGameState` is accepted.
        fatalError("Not implemented. Use OctopusGameController(states:initialStateClass:)")
    }
    
    /// Attemtps to enter the state specified by `initialStateClass`.
    @discardableResult public func enterInitialState() -> Bool {
        didEnterInitialState = enter(initialStateClass)
        return didEnterInitialState
    }
    
    deinit {
        OctopusKit.logForDeinits.add("\(self)")
    }
}
