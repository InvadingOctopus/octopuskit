//
//  PausedState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 7: The paused state for the QuickStart project.
//
//  This state does not provide a scene or UI, as it is represented by the PlayScene (which also displays the content for the PlayState and GameOverState.)

import GameplayKit
import OctopusKit
import SwiftUI

final class PausedState: OKGameState {
    
    init() {
        
        // 🔶 STEP 7.1: Associates a scene and UI with this state.
        // The PlayScene and PlayUI are also associated with the PlayState and GamerOverState.
        
        super.init(associatedSceneClass:  PlayScene.self,
                   associatedSwiftUIView: PlayUI())
    }
    
    @discardableResult func octopusSceneDidChooseNextGameState(_ scene: OKScene) -> Bool {
        
        // 🔶 STEP 7.2: This method will be called by the PlayScene when the "Cycle Game States" button is tapped.
        
        return stateMachine?.enter(GameOverState.self) ?? false
    }
    
    override var validNextStates: [OKGameState.Type] {
        
        // 🔶 STEP 7.3: This property lists all the valid states which this state is allowed to transition to.
        //
        // The PausedState can lead to the PlayState, the GameOverState or the TitleState.
        
        [PlayState.self, GameOverState.self, TitleState.self]
    }
    
}

