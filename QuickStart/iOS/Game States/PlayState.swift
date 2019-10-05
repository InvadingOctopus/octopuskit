//
//  PlayableState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  STEP 7.1: The "gameplay" state for the QuickStart project, represented by the PlayScene (which also displays the content for the PausedState and GameOverState.)

import GameplayKit
import OctopusKit

final class PlayState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass: PlayScene.self)
    }
    
    override func didEnter(from previousState: GKState?) {
        
        // STEP 7.2: This method is called when a state begins.
        //
        // Here we add a component to the global game controller entity (a property of OctopusGameController and its subclasses) which is available to all states and all scenes, to demonstrate how to hold data which will persist throughout the game.
        
        if OctopusKit.shared?.gameController.entity.component(ofType: GlobalDataComponent.self) == nil {
            OctopusKit.shared?.gameController.entity.addComponent(GlobalDataComponent())
        }
        
        // Note that we pass control to the OctopusGameState superclass AFTER we've added the global component, so that it will be available to the PlayScene when it's presented by the code in the superclass.
        
        super.didEnter(from: previousState)
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        
        // STEP 7.3: This method will be called by the PlayScene when the "Enter next state" button is tapped.
        
        return stateMachine?.enter(PausedState.self) ?? false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        // STEP 7.4: The game controller calls this method to check if the current state can transition to the specified state.
        //
        // The PlayState can only lead to either the PausedState or the GameOverState.
        
        return stateClass == PausedState.self
            || stateClass == GameOverState.self
    }
    
}

