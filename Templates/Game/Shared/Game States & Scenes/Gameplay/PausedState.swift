//
//  PausedState.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusKit

final class PausedState: OKGameState {
    
    init() {
        // NOTE: Game state classes are initialized when the game coordinator is initialized: on game launch.
        super.init(associatedSceneClass:  PlayScene.self,
                   associatedSwiftUIView: PausedUI())
    }
    
    override var validNextStates: [OKState.Type] {
        // Customize: Specify the valid states that this state can transition to.
        // NOTE: Do not perform any logic to conditionally control state transitions here. See `OKGameState` documentation.
        [PlayState.self,
         MainMenuState.self]
    }
    
}
