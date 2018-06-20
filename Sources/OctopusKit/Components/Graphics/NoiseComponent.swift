//
//  NoiseComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/15.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Encapsulates a `GKNoise` object.
public final class NoiseComponent: OctopusComponent {
    
    public var noise: GKNoise
    
    init(noise: GKNoise) {
        self.noise = noise
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

