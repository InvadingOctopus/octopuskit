//
//  GlobalDataComponent.swift
//  OctopusKitQuickstart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/07/27.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

/// A custom component for the Quickstart project that holds some simple data to be shared across multiple game states and scenes.
final class GlobalDataComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public var secondsElapsed: TimeInterval = 0
    
    public var dataString: String {
        return "\(String(secondsElapsed).prefix(6))"
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        secondsElapsed += seconds
    }
}

