//
//  MotionControlledThrustComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/12/06.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Other types of motion input sources (e.g. besides deviceMotion)

import GameplayKit

#if os(iOS)
    
/// Controls the entity's `ThrustComponent` based on the motion data from a `MotionManagerComponent`.
///
/// **Dependencies:** `MotionManagerComponent`, `ThrustComponent`
public final class MotionControlledThrustComponent: OKComponent, UpdatedPerFrame {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [MotionManagerComponent.self,
         ThrustComponent.self]
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        guard let motionManagerComponent = coComponent(MotionManagerComponent.self) else { return }
        
        // Tilt to move/thrust.
        
        if  let motion = motionManagerComponent.motionManager?.deviceMotion,
            let thrustComponent = coComponent(ThrustComponent.self)
        {
            thrustComponent.thrustVector = CGVector(dx: CGFloat(motion.gravity.x),
                                                    dy: CGFloat(motion.gravity.y))
        }
    }
}

#else

public final class MotionControlledThrustComponent: iOSExclusiveComponent {}

#endif
