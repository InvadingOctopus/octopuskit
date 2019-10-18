//
//  GameCoordinator.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 3: The OctopusGameCoordinator is the master coordinator for an OctopusKit game.
//
//  It is a "controller" in the MVC sense (as in "ViewController" etc.)
//
//  It lists all the valid states for your game and specifies the initial state.
//
//  States also have a scene associated with them; scenes display the content for each state.
//
//  You may also use the game coordinator to store objects or properties that must be shared across all states and scenes, such as the game world, player data, and network connections etc.

import OctopusKit

final class QuickStartGameCoordinator: OctopusGameCoordinator {
    
    init() {
        super.init(states: [LogoState(),
                            TitleState(),
                            PlayState(),
                            PausedState(),
                            GameOverState()],
                   initialStateClass: LogoState.self)
    }
    
}

