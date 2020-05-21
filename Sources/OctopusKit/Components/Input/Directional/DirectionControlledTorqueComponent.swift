//
//  DirectionControlledTorqueComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Applies a torque to the entity's `PhysicsComponent` body every frame based on `DirectionEventComponent` input.
///
/// Set the `LOGINPUTEVENTS` compilation flag to log values.
///
/// **Dependencies:** `DirectionEventComponent`, `PhysicsComponent`
public final class DirectionControlledTorqueComponent: OKComponent, RequiresUpdatesPerFrame {
    
    // TODO: Tests
    // TODO: Improve the feel
    
    public override var requiredComponents: [GKComponent.Type]? {
        [DirectionEventComponent.self,
         PhysicsComponent.self]
    }
    
    /// The torque in Newton-meters to apply to the node every update, with optional acceleration. Affected by `timeStep`.
    public var torquePerUpdate: AcceleratedValue<CGFloat>
    
    /// Specifies a fixed or variable time step for per-update changes.
    public var timeStep:        TimeStep
    
    /// - Parameters:
    ///   - torquePerUpdate: The amount of torque to apply every update, with optional acceleration. Affected by `timeStep`.
    ///   - timeStep: Specifies a fixed or variable time step for per-update changes. Default: `.perSecond`
    public init(torquePerUpdate:    AcceleratedValue<CGFloat>,
                timeStep:           TimeStep = .perSecond)
    {
        self.torquePerUpdate    = torquePerUpdate
        self.timeStep           = timeStep
        super.init()
    }
    
    /// - Parameters:
    ///   - torquePerUpdate: The torque in Newton-meters to apply to the physics body every second. Affected by `timeStep`.
    ///   - acceleration: The amount to increase the torque by per second, while there is player input. The torque is reset to the `torquePerUpdate` when there is no player input. Affected by `timeStep`.
    ///   - maximum: The maximum torque to allow after acceleration has been applied.
    ///   - timeStep: Specifies a fixed or variable time step for per-update changes. Default: `.perSecond`
    public convenience init(torquePerUpdate:    CGFloat  = 0.01, // ÷ 60 per frame
                            acceleration:       CGFloat  = 0,
                            maximum:            CGFloat  = 0.01, // ÷ 60 per frame
                            timeStep:           TimeStep = .perSecond)
    {
        self.init(torquePerUpdate: AcceleratedValue<CGFloat>(base:    torquePerUpdate,
                                                             current: torquePerUpdate,
                                                             maximum: maximum,
                                                             minimum: 0,
                                                             acceleration: acceleration),
                  timeStep: timeStep)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #0: If there is no input or valid entity for this frame, reset the acceleration and exit.
        
        guard
            let directionEventComponent = coComponent(DirectionEventComponent.self),
            !directionEventComponent.directionsActive.isEmpty,
            let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody ?? entityNode?.physicsBody
            else {
                torquePerUpdate.reset() // TODO: PERFORMANCE: Figure out a better way than setting this every frame.
                return
        }
        
        // #1: Did player press a directional arrow key?
        
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to cancel out opposing directions.
        // ❕ NOTE: Positive rotation = counter-clockwise :)
        
        let directionsActive        = directionEventComponent.directionsActive
        let torqueForCurrentFrame   = timeStep.applying(torquePerUpdate.current, deltaTime: CGFloat(seconds))
        var torqueToApply: CGFloat  = 0
        
        if  directionsActive.contains(.right) { torqueToApply -= torqueForCurrentFrame } // ➡️
        if  directionsActive.contains(.left)  { torqueToApply += torqueForCurrentFrame } // ⬅️
        
        // #2: Exit if multiple directional inputs cancel each other out, this prevents accumulation of acceleration when there is no movement.
        
        guard torqueToApply != 0 else {
            torquePerUpdate.reset()
            #if LOGINPUTEVENTS
            debugLog("torquePerUpdate: \(torquePerUpdate), torqueForCurrentFrame: \(torqueForCurrentFrame), torqueToApply: \(torqueToApply), angularVelocity: \(physicsBody.angularVelocity)")
            #endif
            return
        }
        
        // #3: Apply the final torque to the physics body.
        
        physicsBody.applyTorque(torqueToApply)
        
        #if LOGINPUTEVENTS
        debugLog("torquePerUpdate: \(torquePerUpdate), torqueForCurrentFrame: \(torqueForCurrentFrame), torqueToApply: \(torqueToApply), angularVelocity: \(physicsBody.angularVelocity)")
        #endif
        
        // #4: Apply acceleration for the next frame.
        
        if  torquePerUpdate.isWithinBounds { // CHECK: PERFORMANCE
            torquePerUpdate.update(timeStep: timeStep, deltaTime: CGFloat(seconds))
            torquePerUpdate.clamp()
        }
    }
}
