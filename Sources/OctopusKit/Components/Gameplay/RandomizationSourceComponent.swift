//
//  RandomizationSourceComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/09.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Encapsulates a `GKRandom` object.
public final class RandomizationSourceComponent: OctopusComponent {
    
    public var randomizationSource: GKRandom
    
    init(randomizationSource: GKRandom) {
        self.randomizationSource = randomizationSource
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

