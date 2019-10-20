//
//  GameOverState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 8: The "game over" state for the QuickStart project, represented by the PlayScene (which also displays the content for the PlayState and PausedState.)
//
//  Cycles back to STEP 6 (PlayState).

import GameplayKit
import OctopusKit
import SwiftUI

final class GameOverState: OctopusGameState {
    
    init() {
        
        // 🔶 STEP 8.1: Associates a scene with this state.
        // The PlayScene is also associated with the PlayState and PausedState.
        
        super.init(associatedSceneClass: PlayScene.self,
                   associatedSwiftUIView: AnyView(TitleUI()))
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // 🔶 STEP 8.2: This method will be called by the PlayScene when the "Cycle Game States" button is tapped.
        
        return stateMachine?.enter(TitleState.self) ?? false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // 🔶 STEP 8.3: The OctopusGameCoordinator's superclass GKStateMachine calls this method to ask if the current state can transition to the requested state.
        //
        // The GameOverState can cycle back to either the TitleState or the PlayState.
        
        return stateClass == TitleState.self
            || stateClass == PlayState.self
    }
    
}
