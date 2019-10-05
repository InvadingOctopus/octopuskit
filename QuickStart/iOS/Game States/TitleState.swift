//
//  TitleState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  STEP 5.1: The title state displays the title scene for the QuickStart project, then segues into the PlayState.

import GameplayKit
import OctopusKit

final class TitleState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass: TitleScene.self)
    }

    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // STEP 5.2: This method will be called by the TitleScene when the "Start" button is tapped.
        
        return stateMachine?.enter(PlayState.self) ?? false
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // STEP 5.3: The game controller calls this method to check if the current state can transition to the specified state.
        
        return stateClass == PlayState.self
    }
    
}
