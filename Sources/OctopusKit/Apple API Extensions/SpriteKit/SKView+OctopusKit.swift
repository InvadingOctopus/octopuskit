//
//  SKView+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

extension SKView {
    
    /// Sets the visibility of all debugging-related information and overlays.
    open func setAllDebugStatsVisibility(to visibility: Bool) {
        self.showsFPS = visibility
        self.showsDrawCount = visibility
        self.showsFields = visibility
        self.showsNodeCount = visibility
        self.showsPhysics = visibility
        self.showsQuadCount = visibility
    }
}
