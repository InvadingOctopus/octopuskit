//
//  LogoState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 4: This is the initial game state for the OctopusKit QuickStart project.
//
//  It displays the OKLogoScene which is provided by OctopusKit. When the logo scene finishes its animations, it tells the game coordinator to transition to the next state, which for this project is the TitleState.

import GameplayKit
import OctopusKit
import SwiftUI

final class LogoState: OKGameState {
    
    init() {
        
        // 🔶 STEP 4.1: Associates a scene with this state.
        // Each state may have only one scene, but a scene may represent multiple states (such as playing and paused.)
        //
        // Note that the LogoState has no associated SwiftUI overlay, which we will see in the upcoming TitleState.
        
        super.init(associatedSceneClass: OKLogoScene.self)
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OKScene) -> Bool {
        
        // 🔶 STEP 4.2: This method will be called by the OKLogoScene after it finishes animating.
        
        return stateMachine?.enter(TitleState.self) ?? false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // 🔶 STEP 4.3: The OKGameCoordinator's superclass GKStateMachine calls this method to ask if the current state can transition to the requested state.
        
        return stateClass == TitleState.self
    }
    
}
