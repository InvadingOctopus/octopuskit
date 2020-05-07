//
//  MotionControlledParallaxComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Implement

import SpriteKit
import GameplayKit

#if os(iOS)
    
import CoreMotion

/// Adds a shift in the position of the entity's `NodeComponent` node every frame, based on the device's motion.
///
/// **Dependencies:** `MotionManagerComponent`, `NodeComponent`
public class MotionControlledParallaxComponent: OKComponent, OKUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         MotionManagerComponent.self]
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
    }
}

#else

public final class MotionControlledParallaxComponent: iOSExclusiveComponent {}

#endif
