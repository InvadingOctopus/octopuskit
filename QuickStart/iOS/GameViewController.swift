//
//  GameViewController.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/06/04.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  STEP 3.1: The view controller for the SpriteKit view (SKView) in your main storyboard must be the OctopusSceneController class (or a subclass of it that is specific to your game, like the GameViewController in this project.)
//
//  The OctopusSceneController tells the OctopusGameController to enter the initial state of the game once the SpriteKit view is ready to present its content onscreen.
//
//  The class for the initial game state then tells the view controller to present the first scene of the game.

import UIKit
import SpriteKit
import GameplayKit
import OctopusKit

final class GameViewController: OctopusSceneController {
    
    override func viewDidLoad() {
        
        // STEP 3.2: You may customize some screen-related settings here, such as the device orientations allowed in your game and status bar visibility etc.
        
        super.viewDidLoad()
        
        prefersStatusBarHiddenOverride = true
        prefersHomeIndicatorAutoHiddenOverride = true
        
        shouldAutorotateOverride = false
        supportedInterfaceOrientationsOverride[.phone] = .allButUpsideDown
    }
    
    override func didReceiveMemoryWarning() {
        // Customize this method to release any cached game-specific data, images, etc. that aren't in use, so that the operating system can free up some memory.
        super.didReceiveMemoryWarning()
    }
    
}

