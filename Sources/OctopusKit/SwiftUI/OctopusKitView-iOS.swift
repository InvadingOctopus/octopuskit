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
public struct OctopusKitView<OctopusViewControllerType>: UIViewControllerRepresentable
    where OctopusViewControllerType: OctopusViewController
{
    
    let gameController: OctopusGameController
    let viewController: OctopusViewControllerType
    
    public init(gameControllerOverride: OctopusGameController? = nil) {
        self.gameController = gameControllerOverride!
        self.viewController = OctopusViewControllerType(gameController: self.gameController)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<OctopusKitView>) -> OctopusViewControllerType {
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: OctopusViewControllerType,
                                       context: UIViewControllerRepresentableContext<OctopusKitView>) {
        if !gameController.didEnterInitialState {
            gameController.enterInitialState()
        }
    }
  
    public static func dismantleUIViewController(_ uiViewController: OctopusViewControllerType, coordinator: OctopusKitView.Coordinator) {
    }
    
}

#endif
