//
//  TitleState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5A: The title state displays the title scene for the QuickStart project, then segues into the PlayState.

import GameplayKit
import OctopusKit
import SwiftUI

final class TitleState: OKGameState {
    
    init() {
        
        // 🔶 STEP 5A.1: Associates a scene and SwiftUI overlay with this state.
        //
        // The "scene" displays the SpriteKit/SceneKit/Metal content, and the SwiftUI view is overlaid on top of the gameplay.
        //
        // This hybridization lets you use an Entity-Component-System architecture for your gameplay, with a convenient declarative syntax for your user interface.
        
        super.init(associatedSceneClass:  TitleScene.self,
                   associatedSwiftUIView: TitleUI())
    }

    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OKScene) -> Bool {
        
        // 🔶 STEP 5A.2: This method will be called by the TitleScene when the "Cycle Game States" button is tapped.
        
        return stateMachine?.enter(PlayState.self) ?? false
    }

    override var validNextStates: [OKGameState.Type] {
        
        // 🔶 STEP 5A.3: This property lists all the valid states which this state is allowed to transition to.
        
        [PlayState.self]
    }
    
}
