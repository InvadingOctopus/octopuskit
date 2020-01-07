//
//  OKContainerView.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-20
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI

public typealias OctopusContainerView = OKContainerView

/// The primary view for an OctopusKit game in a SwiftUI view hierarchy.
///
/// Combines an `OKViewControllerRepresentable` with a SwiftUI overlay, for presenting SpriteKit content in a SwiftUI application along with the game user interface controls related to the current game state.
///
/// The views are combined in a static ZStack, so the UI layer is always displayed on top of the 2D sprite layer.
///
/// To use the entire screen on iOS, add the following view modifiers:
///
///     .edgesIgnoringSafeArea(.all)
///     .statusBar(hidden: true)
public struct OKContainerView <OKGameCoordinatorType, OKViewControllerType> : View
    where OKGameCoordinatorType: OKGameCoordinator,
          OKViewControllerType:  OKViewController
{
    
    @EnvironmentObject var gameCoordinator: OKGameCoordinatorType
    
    public init() {}
    
    public var body: some View {
        
        ZStack {
            
            OKViewControllerRepresentable<OKGameCoordinatorType, OKViewControllerType>()

            OKUIOverlay<OKGameCoordinatorType>()
            
            // CHECK: Should `OKUIOverlay` be an `.overlay` modifier for `OKViewControllerRepresentable`?
        }
    }
}
