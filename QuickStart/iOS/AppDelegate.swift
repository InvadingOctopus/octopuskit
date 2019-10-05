//
//  AppDelegate.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018-02-10
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  STEP 1.1: The AppDelegate class is the launching point of your game (as marked by the @UIApplicationMain attribute), where the operating system passes control to your code.
//
//  Most of the responsibilities of an "application delegate" are handled by the OctopusAppDelegate class provided by OctopusKit, such as pausing and unpausing when the player switches to a different application or receives a call etc.
//
//  However, your project must override the applicationWillLaunchOctopusKit() method to start the OctopusKit engine by specifying your game controller, which sets the initial state and scene of your game.
//
//  Note that "game controller" refers to a controller in the MVC sense here (as in "ViewController" etc.) and not an input device like a gamepad or joystick.

import UIKit
import OctopusKit

@UIApplicationMain
final class AppDelegate: OctopusAppDelegate {
    
    override func applicationWillLaunchOctopusKit() {
        
        //  STEP 1.2: This step is mandatory for all OctopusKit projects. Here you initialize the shared singleton instance of the OctopusKit class, which contains the global objects that manage your game.
        //
        //  You must also create an instance of the OctopusGameController class (or a subclass of it that is specific to your game, like the QuickStartGameController in this project), and pass it to the OctopusKit initializer.
        
        OctopusKit(appName: "OctopusKit QuickStart",
                   gameController: QuickStartGameController())
        
        // Note that you don't need to create a custom game controller if your game does not need to globally share any complex logic or data across multiple states and scenes.
        //
        // For this project, a custom game controller is provided only for illustrative purposes.
        // You could replace the above code with the following:
        //
        // OctopusKit(appName: "OctopusKit QuickStart",
        //            gameController: OctopusGameController(states: [LogoState(),
        //                                                           TitleState(),
        //                                                           PlayState(),
        //                                                           PausedState(),
        //                                                           GameOverState()],
        //                                                  initialStateClass: LogoState.self))
    }
    
}


