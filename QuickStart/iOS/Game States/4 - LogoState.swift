//
//  TitleState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 4: This is the initial game state for the QuickStart project.
//
//  It displays the OctopusLogoScene which is provided by OctopusKit. When the logo scene finishes its animations, it tells the game coordinator to transition to the next state, which for this project is the TitleState.

import GameplayKit
import OctopusKit

final class LogoState: OctopusGameState {
    
    init() {
        
        // 🔶 STEP 4.1: Associates a scene with this state.
        // Each state may have only one scene, but a scene may represent multiple states (such as playing and paused.)
        
        super.init(associatedSceneClass: OctopusLogoScene.self)
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // 🔶 STEP 4.2: This method will be called by the OctopusLogoScene after it finishes animating.
        
        return stateMachine?.enter(TitleState.self) ?? false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // 🔶 STEP 4.3: The game coordinator calls this method to check if the current state can transition to the specified state.
        
        return stateClass == TitleState.self
    }
    
}
