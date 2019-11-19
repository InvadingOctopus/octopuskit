//
//  OctopusKitContainerView.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-20
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI

public typealias OKContainerView = OctopusKitContainerView

/// The primary view for an OctopusKit game in a SwiftUI view hierarchy.
///
/// Combines an `OctopusViewControllerRepresentable` with a SwiftUI overlay, for presenting SpriteKit content in a SwiftUI application along with the game user interface controls related to the current game state.
///
/// The views are combined in a static ZStack, so the UI layer is always displayed on top of the 2D sprite layer.
///
/// To use the entire screen on iOS, add the following view modifiers:
///
///     .edgesIgnoringSafeArea(.all)
///     .statusBar(hidden: true)
public struct OctopusKitContainerView <OctopusGameCoordinatorType, OctopusViewControllerType> : View
    where OctopusGameCoordinatorType: OctopusGameCoordinator,
          OctopusViewControllerType:  OctopusViewController
{
    
    @EnvironmentObject var gameCoordinator: OctopusGameCoordinatorType
    
    public init() {}
    
    public var body: some View {
        
        ZStack {
            
            OctopusViewControllerRepresentable<OctopusGameCoordinatorType, OctopusViewControllerType>()
            
            OctopusUIOverlay<OctopusGameCoordinatorType>()
        }
    }
}
