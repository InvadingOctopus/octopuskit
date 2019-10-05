//
//  TitleState.swift
//  OctopusKitQuickstart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  STEP 4.1: This is the initial game state for the Quickstart project.
//
//  It displays the OctopusLogoScene which is provided by OctopusKit. When the logo scene finishes its animations, it tells the game controller to transition to the next state, which for this project is the TitleState.

import GameplayKit
import OctopusKit

final class LogoState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass: OctopusLogoScene.self)
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // STEP 4.2: This method will be called by the OctopusLogoScene after it finishes animating.
        
        return stateMachine?.enter(TitleState.self) ?? false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // STEP 4.3: The game controller calls this method to check if the current state can transition to the specified state.
        
        return stateClass == TitleState.self
    }
    
}
