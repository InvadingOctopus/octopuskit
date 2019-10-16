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

/// Displays OctopusKit content.
public struct OctopusKitView <OctopusGameCoordinatorType, OctopusViewControllerType> : UIViewControllerRepresentable
    where OctopusGameCoordinatorType: OctopusGameController,
    OctopusViewControllerType: OctopusViewController
{
    
    @EnvironmentObject var gameController: OctopusGameCoordinatorType
    
    public init() {}
    
    public func makeCoordinator() -> OctopusKitView.Coordinator<OctopusViewControllerType> {
        OctopusKitView.Coordinator() //(gameController: gameController)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<OctopusKitView>) -> OctopusViewControllerType {
        return context.coordinator.createViewController(with: self.gameController)
        //return context.coordinator.viewController
    }
    
    public func updateUIViewController(_ uiViewController: OctopusViewControllerType,
                                       context: UIViewControllerRepresentableContext<OctopusKitView>)
    {
        if !gameController.didEnterInitialState {
            gameController.enterInitialState()
        }
    }
  
    public static func dismantleUIViewController(_ uiViewController: OctopusViewControllerType,
                                                 coordinator: OctopusKitView.Coordinator<OctopusViewControllerType>)
    {
        // CHECK
        coordinator.viewController.spriteKitView?.scene?.isPaused = true
        coordinator.viewController.gameController?.currentScene?.didPauseBySystem()
    }
    
}

#endif

extension OctopusKitView {
    
    public class Coordinator <OctopusViewControllerType> : NSObject
    where OctopusViewControllerType: OctopusViewController
    {

        var viewController: OctopusViewControllerType!
        
//        var parent: OctopusKitView

        override init() { super.init() }
        
        init(gameController: OctopusGameController) {
            self.viewController = OctopusViewControllerType(gameController: gameController)
            super.init()
        }

        func createViewController(with gameController: OctopusGameController) -> OctopusViewControllerType {
            self.viewController = OctopusViewControllerType(gameController: gameController)
//                self.viewController = viewController
            return viewController!
        }
    }
}
