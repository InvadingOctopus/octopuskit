//
//  OctopusUIOverlay.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-20
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import Combine

/// Displays the SwiftUI overlay for the `OctopusGameCoordinatorType`'s current `OctopusGameState`.
public struct OctopusUIOverlay <OctopusGameCoordinatorType> : View
    where OctopusGameCoordinatorType: OctopusGameCoordinator
{
    
    @EnvironmentObject var gameCoordinator: OctopusGameCoordinatorType
    
    public init() {}
    
    public var body: some View {
        gameCoordinator.currentGameState?.associatedSwiftUIView ?? AnyView(EmptyView())
    }
}
