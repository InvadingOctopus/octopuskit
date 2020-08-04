//
//  PhysicsMovementType.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/8/4.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// Defines an option between forces (continuous) or impulses (instantaneous) for components that handle physics-based movement.
///
/// - Note: See the SpriteKit documentation on **Making Physics Bodies Move** for details.
public enum PhysicsMovementType {

    // 📖 https://developer.apple.com/documentation/spritekit/skphysicsbody/making_physics_bodies_move

    /// A continuous force to a physics body that must be re-applied on every frame update to maintain movement.
    ///
    /// A *force* is applied for a length of time based on the amount of simulation time that passes between when you apply the force and when the next frame of the simulation is processed. So, to apply a continuous force to an body, you need to make the appropriate method calls each time a new frame is processed. Forces are usually used for continuous effects.
    case force

    /// An instantaneous change to a physics body’s velocity, generally applied only once or in discrete steps.
    ///
    /// An *impulse* makes an instantaneous change to the body’s velocity that is independent of the amount of simulation time that has passed. Impulses are usually used for immediate changes to a body’s velocity.
    case impulse
}
