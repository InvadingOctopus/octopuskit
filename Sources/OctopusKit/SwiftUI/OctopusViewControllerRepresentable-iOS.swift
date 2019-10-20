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
    
    @EnvironmentObject var gameCoordinator: OctopusGameCoordinatorType
    
    public init() {}
    
    public func makeCoordinator() -> OctopusViewControllerRepresentable.Coordinator<OctopusViewControllerType> {
        OctopusViewControllerRepresentable.Coordinator()
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<OctopusViewControllerRepresentable>) -> OctopusViewControllerType {
        return context.coordinator.createViewController(with: self.gameCoordinator)
        //return context.coordinator.viewController
    }
    
    public func updateUIViewController(_ uiViewController: OctopusViewControllerType,
                                       context: UIViewControllerRepresentableContext<OctopusViewControllerRepresentable>)
    {
        if !gameCoordinator.didEnterInitialState {
            gameCoordinator.enterInitialState()
        }
    }
  
    public static func dismantleUIViewController(_ uiViewController: OctopusViewControllerType,
                                                 coordinator: OctopusViewControllerRepresentable.Coordinator<OctopusViewControllerType>)
    {
        coordinator.viewController.gameCoordinator?.currentScene?.didPauseBySystem()
    }
    
}

#endif

extension OctopusViewControllerRepresentable {
    
    public class Coordinator <OctopusViewControllerType> : NSObject
    where OctopusViewControllerType: OctopusViewController
    {

        var viewController: OctopusViewControllerType!
        
        override init() { super.init() }
        
        init(gameCoordinator: OctopusGameCoordinator) {
            self.viewController = OctopusViewControllerType(gameCoordinator: gameCoordinator)
            super.init()
        }

        func createViewController(with gameCoordinator: OctopusGameCoordinator) -> OctopusViewControllerType {
            self.viewController = OctopusViewControllerType(gameCoordinator: gameCoordinator)
//                self.viewController = viewController
            return viewController!
        }
    }
}
