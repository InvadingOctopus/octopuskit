//
//  MainMenuScene.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

final class MainMenuScene: OKScene {

    override func setName() -> String? { "MainMenuScene" }

    override func createComponentSystems() -> [GKComponent.Type] {
        // Customize. Each component must be listed after the components it depends on (as per its `requiredComponents` property.)
        // See OKScene.createComponentSystems() for the default set of commonly-used systems.
        super.createComponentSystems()
    }

    override func createContents() {
        // Customize: This is where you construct entities to add to your scene.

        self.entity? += ([sharedMouseOrTouchEventComponent,
                          sharedPointerEventComponent])

        addEntity(OKEntity(name: "", components: [
            // Customize
        ]))
    }

}

