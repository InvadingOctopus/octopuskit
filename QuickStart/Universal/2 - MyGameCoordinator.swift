//
//  MyGameCoordinator.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 2: The OKGameCoordinator is the master coordinator for an OctopusKit game.
//
//  It lists all the valid states for your game and specifies the initial state.
//
//  In the MVC hierarchy, it's a "controller" (as in "ViewController" etc.)
//
//  You may also use the game coordinator to store objects or properties that must be shared across all states and scenes, such as the game world, player data and network connections etc.
//
//  Each OKGameState has a scene and UI overlay associated with it; scenes present the content for each state.
//
//  Creating a subclass of OKGameCoordinator is not necessary for basic OctopusKit projects so you may simply use OKGameCoordinator(states:initialStateClass:)
//
//  Complex games may require custom coordinators to manage different kinds of global state and external connections.

import OctopusKit

final class MyGameCoordinator: OKGameCoordinator {
    
    init() {
        super.init(states: [LogoState(),
                            TitleState(),
                            PlayState(),
                            PausedState(),
                            GameOverState()],
                   initialStateClass: LogoState.self)
    }
    
}

