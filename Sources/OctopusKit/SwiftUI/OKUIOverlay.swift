//
//  OKUIOverlay.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-20
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import Combine

public typealias OctopusUIOverlay = OKUIOverlay

/// Displays the SwiftUI overlay for the `OKGameCoordinatorType`'s current `OKGameState`.
public struct OKUIOverlay <OKGameCoordinatorType> : View
    where OKGameCoordinatorType: OKGameCoordinator
{
    
    @EnvironmentObject var gameCoordinator: OKGameCoordinatorType
    
    public var body: some View {
        Group {
            if  gameCoordinator.currentGameState != nil {
                gameCoordinator.currentGameState!.associatedSwiftUIView
            }
        }
    }
}
