//
//  MyGameViewController.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/06/04.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 3: The view controller for the SpriteKit view (SKView) that displays your game.
//
//  Creating a subclass of OctopusViewController is not necessary for a basic OctopusKit project, but complex games may require some view controller customization. This subclass does no customization but is provided for illustration.
//
//  In SwiftUI, an OctopusViewController is encapsulated by OctopusViewControllerRepresentable.
//
//  However, to use OctopusKit in a SwiftUI project, use:
//
//  OctopusKitContainerView<MyGameCoordinator, MyGameViewController>()
//      .environmentObject(MyGameCoordinator())
//
//  The OctopusKitContainerView presents SpriteKit and SwiftUI content together.
//
//  If you are using AppKit or UIKit, then the view controller for the SKView in your main storyboard must be the OctopusViewController class, or a subclass of it that is specific to your game, like the MyGameViewController in this project.

import OctopusKit

final class MyGameViewController: OctopusViewController {
    
    override func viewDidLoad() {
        
        // 🔶 STEP 3.1: You may customize some screen-related settings here, such as the device orientations allowed in your game and status bar visibility etc.
        
        super.viewDidLoad() // ❗️ Required. You must call super.viewDidLoad() before any other code in your overriding implementation.
        
        supportedInterfaceOrientationsOverride[.phone] = .allButUpsideDown
        
        // prefersStatusBarHiddenOverride = true
        // prefersHomeIndicatorAutoHiddenOverride = true
        // shouldAutorotateOverride = false
    }
    
    override func didReceiveMemoryWarning() {
        // Customize this method to release any cached game-specific data, images, etc. that aren't in use, so that the operating system can free up some memory.
        super.didReceiveMemoryWarning()
    }
    
}

