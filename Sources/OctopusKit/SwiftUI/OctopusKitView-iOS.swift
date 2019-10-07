//
//  OctopusKitView-iOS.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-07
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import SpriteKit

#if canImport(UIKit)

public struct OctopusKitView: UIViewControllerRepresentable {
  
    var gameControllerOverride: OctopusGameController?
    var sceneController: OctopusSceneController?
    
    public init(gameControllerOverride: OctopusGameController? = nil) {
        self.gameControllerOverride = gameControllerOverride
    }
    
    public func makeCoordinator() -> () {
        OctopusKit(appName: "OctopusKit QuickStart",
                   gameController: gameControllerOverride)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<OctopusKitView>) -> OctopusSceneController {
        
        self.sceneController = OctopusSceneController()
        
        if let self.sceneController = sceneController {
            OctopusKit.shared?.sceneController = sceneController
            sceneController.loadViewIfNeeded()
            sceneController.enterInitialState()
            return sceneController
        }
        else {
            fatalError("Could not create OctopusSceneController")
        }
    }
    
    public func updateUIViewController(_ uiViewController: OctopusKitView.UIViewControllerType,
                                       context: UIViewControllerRepresentableContext<OctopusKitView>) {
        
    }
    
    public static func dismantleUIViewController(_ uiViewController: OctopusKitView.UIViewControllerType, coordinator: OctopusKitView.Coordinator) {
        if  let sceneController = self.sceneController,
            OctopusKit.shared?.sceneController === sceneController
        {
            OctopusKit.shared?.sceneController = nil
        }
    }
    
}

#endif
