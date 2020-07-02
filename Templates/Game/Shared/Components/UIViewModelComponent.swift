//
//  UIViewModelComponent.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

final class UIViewModelComponent: OKComponent,
                                  RequiresUpdatesPerFrame,
                                  ObservableObject
{

    @Published private(set) var playerScore:    Int     = 0
    @Published private(set) var playerRotation: CGFloat = 0

    var updateRateInFrames:         Int = 10 // 6 times a second.
    private(set) var frameCount:    Int = 0

    override var requiredComponents: [GKComponent.Type]? {
        [PlayerStatsComponent.self]
    }

    @inlinable
    override func update(deltaTime seconds: TimeInterval) {

        // TODO: PERFORMANCE: Replace with Combine-based reactive updates.

        frameCount += 1

        guard frameCount !< updateRateInFrames else { return }

        if  let playerStatsComponent = coComponent(PlayerStatsComponent.self) {
            self.playerScore = playerStatsComponent.score
        }

        if  let node = self.entity?.node {
            self.playerRotation = node.zRotation
        }

        frameCount = 0
    }

}

