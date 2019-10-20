//
//  TitleState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5A: The title state displays the title scene for the QuickStart project, then segues into the PlayState.

import GameplayKit
import OctopusKit
import SwiftUI

final class TitleState: OctopusGameState {
    
    init() {
        
        // 🔶 STEP 5A.1: Associates a scene and SwiftUI overlay with this state.
        //
        // The "scene" displays the SpriteKit/SceneKit/Metal content, and the SwiftUI view is overlaid on top of the gameplay.
        //
        // This hybridization lets you use an Entity-Component-System architecture for your gameplay, with a convenient declarative syntax for your user interface.
        
        super.init(associatedSceneClass: TitleScene.self,
                   associatedSwiftUIView: AnyView(TitleUI()))
    }

    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // 🔶 STEP 5A.2: This method will be called by the TitleScene when the "Cycle Game States" button is tapped.
        
        return stateMachine?.enter(PlayState.self) ?? false
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // 🔶 STEP 5A.3: The OctopusGameCoordinator's superclass GKStateMachine calls this method to ask if the current state can transition to the requested state.
        
        return stateClass == PlayState.self
    }
    
}
