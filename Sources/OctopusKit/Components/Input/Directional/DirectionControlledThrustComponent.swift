//
//  DirectionControlledThrustComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import SpriteKit
import GameplayKit

/// Applies a forward or backwards thrust to the entity's `PhysicsComponent` body on every frame, in the direction of the `NodeComponent` node's rotation, based on `DirectionEventComponent` input.
///
/// Set the `LOGINPUTEVENTS` compilation flag to log values.
///
/// **Dependencies:** `DirectionEventComponent`, `PhysicsComponent`, `NodeComponent`
public final class DirectionControlledThrustComponent: OKComponent, RequiresUpdatesPerFrame {
    
    // TODO: Tests
    
    // DESIGN: A `resetAccelerationWhenChangingDirection` is probably not needed because the inertia and friction of the physics body should take care of that anyway, right?
    
    public override var requiredComponents: [GKComponent.Type]? {
        [DirectionEventComponent.self,
         PhysicsComponent.self,
         NodeComponent.self]
    }
        
    /// The amount of thrust to apply in a single update, with optional acceleration. Affected by `timeStep`. Reset when there is no player input.
    public var magnitudePerUpdate:  AcceleratedValue<CGFloat>
    
    /// Multiplies the force by the specified value. Default: `1`. To reverse the thrust, specify a negative value like `-1`. To disable thrust, specify `0`.
    public var scalingFactor:       CGFloat = 1
    
    /// Specifies a fixed or variable time step for per-update changes.
    public var timeStep:            TimeStep
    
    /// - Parameters:
    ///   - magnitudePerUpdate: The amount of thrust to apply every update, with optional acceleration. Affected by `timeStep`.
    ///   - scalingFactor: Multiplies the force by the specified factor. Default: `1`. To reverse the thrust, specify a negative value like `-1`. To disable thrust, specify `0`.
    ///   - timeStep: Specifies a fixed or variable time step for per-update changes. Default: `.perSecond`
    public init(magnitudePerUpdate: AcceleratedValue<CGFloat>,
                scalingFactor:      CGFloat  = 1.0,
                timeStep:           TimeStep = .perSecond)
    {
        self.magnitudePerUpdate = magnitudePerUpdate
        self.scalingFactor      = scalingFactor
        self.timeStep           = timeStep
        super.init()
    }
    
    /// - Parameters:
    ///   - magnitudePerUpdate: The minimum magnitude to apply to the physics body every second. Affected by `timeStep`.
    ///   - acceleration: The amount to increase the magnitude by per second, while there is player input. The magnitude is reset to the `magnitudePerUpdate` when there is no player input. Affected by `timeStep`.
    ///   - maximum: The maximum magnitude to allow after acceleration has been applied.
    ///   - scalingFactor: Multiplies the force by the specified factor. Default: `1`. To reverse the thrust, specify a negative value like `-1`. To disable thrust, specify `0`.
    ///   - timeStep: Specifies a fixed or variable time step for per-update changes. Default: `.perSecond`
    public convenience init(magnitudePerUpdate: CGFloat  = 600, // ÷ 60 = 10 per frame
                            acceleration:       CGFloat  = 100,
                            maximum:            CGFloat  = 900, // ÷ 60 = 15 per frame
                            scalingFactor:      CGFloat  = 1,
                            timeStep:           TimeStep = .perSecond)
    {
        self.init(magnitudePerUpdate: AcceleratedValue<CGFloat>(base:    magnitudePerUpdate,
                                                                current: magnitudePerUpdate,
                                                                maximum: maximum,
                                                                minimum: 0,
                                                                acceleration: acceleration),
                  scalingFactor: scalingFactor,
                  timeStep: timeStep)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #0: If there is no input or valid entity for this frame, reset the acceleration and exit.
        
        guard
            let directionEventComponent = coComponent(DirectionEventComponent.self),
            !directionEventComponent.directionsActive.isEmpty,
            let node = entityNode,
            let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody ?? node.physicsBody
            else {
                magnitudePerUpdate.reset() // TODO: PERFORMANCE: Figure out a better way than setting this every frame.
                return
        }
    
        // #1: Did player input a direction?
        
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to cancel out opposing directions.
        
        let directionsActive   = directionEventComponent.directionsActive
        var direction: CGFloat = 0
        
        if directionsActive.contains(.up)   { direction += 1 } // ⬆️
        if directionsActive.contains(.down) { direction -= 1 } // ⬇️
        
        // #2: Exit if multiple directional inputs cancel each other out, this prevents accumulation of acceleration when there is no movement.
        
        guard direction != 0 else {
            magnitudePerUpdate.reset()
            return
        }
        
        // #3: Apply the force in relation to the node's current rotation.
        
        let magnitudeForCurrentFrame = timeStep.applying(magnitudePerUpdate.current, deltaTime: CGFloat(seconds))
        let vector = CGVector(radians: node.zRotation) * CGFloat(magnitudeForCurrentFrame * direction) * scalingFactor // TODO: Verify!
        
        // Apply the final vector to the body.
        
        #if LOGINPUTEVENTS
        debugLog("magnitudePerUpdate: \(magnitudePerUpdate), magnitudeForCurrentFrame: \(magnitudeForCurrentFrame), scalingFactor: \(scalingFactor), rotation: \(node.zRotation), force: \(vector)")
        #endif
        
        physicsBody.applyForce(vector)
        
        // #4: Apply acceleration for the next frame.
        
        if  magnitudePerUpdate.isWithinBounds { // CHECK: PERFORMANCE
            magnitudePerUpdate.update(timeStep: timeStep, deltaTime: CGFloat(seconds))
            magnitudePerUpdate.clamp()
        }
    }
}

