//
//  OctopusViewControllerRepresentable-iOS.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-07
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import SpriteKit

#if canImport(UIKit)

/// Encapsulates an OctopusViewController for presenting SpriteKit/SceneKit/Metal content in a SwiftUI application.
public struct OctopusViewControllerRepresentable <OctopusGameCoordinatorType, OctopusViewControllerType> : UIViewControllerRepresentable
    where OctopusGameCoordinatorType: OctopusGameCoordinator,
    OctopusViewControllerType: OctopusViewController
{
    
    // typealias Context = UIViewControllerRepresentableContext<Self> // Defined in UIViewControllerRepresentable
    
    @EnvironmentObject var gameCoordinator: OctopusGameCoordinatorType
    
    public init() {}
    
    public func makeCoordinator() -> Coordinator<OctopusViewControllerType> {
        OctopusViewControllerRepresentable.Coordinator(gameCoordinator: self.gameCoordinator)
    }
    
    public func makeUIViewController(context: Context) -> OctopusViewControllerType {
        return context.coordinator.viewController
    }
    
    public func updateUIViewController(_ uiViewController: OctopusViewControllerType,
                                       context: Context)
    {
        // Enter the first game state if the game coordinator has not already done so.
        if !gameCoordinator.didEnterInitialState {
            gameCoordinator.enterInitialState()
        }
    }
  
    public static func dismantleUIViewController(_ uiViewController: OctopusViewControllerType,
                                                 coordinator: Coordinator<OctopusViewControllerType>)
    {
        uiViewController.gameCoordinator?.currentScene?.didPauseBySystem()
    }
    
}

#endif

public extension OctopusViewControllerRepresentable { // CHECK: Should this be public?
    
    class Coordinator <OctopusViewControllerType> : NSObject
        where OctopusViewControllerType: OctopusViewController
    {
        var viewController: OctopusViewControllerType
        
        init(gameCoordinator: OctopusGameCoordinator) {
            self.viewController = OctopusViewControllerType(gameCoordinator: gameCoordinator)
            super.init()
        }
    }
}
