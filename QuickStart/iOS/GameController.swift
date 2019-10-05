//
//  GameController.swift
//  OctopusKitQuickstart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  STEP 2.1: The game controller lists all the valid states for your game and specifies the initial state.
//
//  States also have a scene associated with them; scenes display the content for each state.
//
//  You may also use the game controller to store properties that must be shared across all states and scenes, such as the game world, player data, and network connections etc.
//
//  Note that "game controller" refers to a controller in the MVC sense here (as in "ViewController" etc.) and not an input device like a gamepad or joystick.

import GameplayKit
import OctopusKit

final class QuickstartGameController: OctopusGameController {
    
    init() {
        super.init(states: [LogoState(),
                            TitleState(),
                            PlayState(),
                            PausedState(),
                            GameOverState()],
                   initialStateClass: LogoState.self)
    }
    
}

