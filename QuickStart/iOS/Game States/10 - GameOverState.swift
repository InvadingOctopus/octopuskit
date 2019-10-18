//
//  GameOverState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 10: The "game over" state for the QuickStart project, represented by the PlayScene (which also displays the content for the PlayState and PausedState.)
//
//  Cycles back to STEP 6 (PlayState).

import GameplayKit
import OctopusKit

final class GameOverState: OctopusGameState {
    
    init() {
        
        // 🔶 STEP 10.1: Associates a scene with this state.
        // The PlayScene is also associated with the PlayState and PausedState.
        
        super.init(associatedSceneClass: PlayScene.self)
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // 🔶 STEP 10.2: This method will be called by the PlayScene when the "Enter next state" button is tapped.
        
        return stateMachine?.enter(TitleState.self) ?? false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // 🔶 STEP 10.3: The game coordinator calls this method to check if the current state can transition to the specified state.
        //
        // The GameOverState can only lead to either the TitleState or the PlayState.
        
        return stateClass == TitleState.self
            || stateClass == PlayState.self
    }
    
}
