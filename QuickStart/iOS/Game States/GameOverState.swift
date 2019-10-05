//
//  GameOverState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  STEP 10.1: The "game over" state for the QuickStart project, represented by the PlayScene (which also displays the content for the PlayState and PausedState.)
//
//  Cycles back to STEP 5.

import GameplayKit
import OctopusKit

final class GameOverState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass: PlayScene.self)
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // STEP 10.2: This method will be called by the PlayScene when the "Enter next state" button is tapped.
        
        return stateMachine?.enter(TitleState.self) ?? false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // STEP 10.3: The game controller calls this method to check if the current state can transition to the specified state.
        //
        // The GameOverState can only lead to either the TitleState or the PlayState.
        
        return stateClass == TitleState.self
            || stateClass == PlayState.self
    }
    
}
