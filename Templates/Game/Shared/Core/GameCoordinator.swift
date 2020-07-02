//
//  GameCoordinator.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import OctopusKit

class GameCoordinator: OKGameCoordinator {

    init() {
        super.init(states: [MainMenuState(),
                            PlayState(),
                            PausedState()],
                   initialStateClass: MainMenuState.self)
    }

    override func willEnterInitialState() {
        self.entity.addComponents([])
    }
}
