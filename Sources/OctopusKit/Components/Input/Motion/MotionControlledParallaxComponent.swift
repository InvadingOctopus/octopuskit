//
//  MotionControlledParallaxComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/16.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Implement

import SpriteKit
import GameplayKit

#if os(iOS)
    
import CoreMotion

/// Adds a shift in the position of the entity's `SpriteKitComponent` node every frame, based on the device's motion.
///
/// **Dependencies:** `MotionManagerComponent`, `SpriteKitComponent`
public class MotionControlledParallaxComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                MotionManagerComponent.self]
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
    }
}

#else

public final class MotionControlledParallaxComponent: iOSExclusiveComponent {}

#endif
