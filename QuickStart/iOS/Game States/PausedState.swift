//
//  PausedState.swift
//  OctopusKitQuickstart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  STEP 9.1: The paused state for the Quickstart project, represented by the PlayScene (which also displays the content for the PlayState and GameOverState.)

import GameplayKit
import OctopusKit

final class PausedState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass: PlayScene.self)
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // STEP 9.2: This method will be called by the PlayScene when the "Enter next state" button is tapped.
        
        return stateMachine?.enter(GameOverState.self) ?? false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // STEP 9.3: The game controller calls this method to check if the current state can transition to the specified state.
        //
        // The PausedState can only lead to the PlayState, the GameOverState or the TitleState.
        
        return stateClass == PlayState.self
            || stateClass == GameOverState.self
            || stateClass == TitleState.self
    }
    
}

