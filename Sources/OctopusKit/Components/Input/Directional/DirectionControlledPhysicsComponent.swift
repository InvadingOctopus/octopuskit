//
//  DirectionControlledPhysicsComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Applies a force or impulse to the entity's `PhysicsComponent` body on every update, based on input from a `DirectionEventComponent`.
///
/// Set the `LOGINPUTEVENTS` compilation flag to log values.
///
/// **Dependencies:** `DirectionEventComponent`, `PhysicsComponent`
public final class DirectionControlledPhysicsComponent: OKComponent, RequiresUpdatesPerFrame {

    // TODO: Tests
    
    // DESIGN: A `resetAccelerationWhenChangingDirection` is probably not needed because the inertia and friction of the physics body should take care of that anyway, right?

    // 📖 https://developer.apple.com/documentation/spritekit/skphysicsbody/making_physics_bodies_move

    public override var requiredComponents: [GKComponent.Type]? {
        [DirectionEventComponent.self,
        PhysicsComponent.self]
    }

    /// Specifies whether this component represents a continuous force or an instantaneous impulse.
    public let movementType:        PhysicsMovementType

    public var magnitude:           AcceleratedValue<CGFloat>

    public var horizontalFactor:    CGFloat
    public var verticalFactor:      CGFloat
    
    /// Specifies a fixed or variable time step for per-update changes.
    ///
    /// For physics effects, a per-second time step may be suitable.
    public var timeStep:            TimeStep
    
    /// - Parameters:
    ///   - movementType:       Specifies whether this component represents a continuous force (applied every frame) or an instantaneous impulse (applied in discrete steps). Default: `.force`.
    ///   - timeStep:           Specifies a fixed or variable time step for per-update changes. Default: `.perSecond`.
    ///   - magnitude:          The magnitude to apply to the physics body on every update. Affected by `timeStep`.
    ///   - horizontalFactor:   Multiply the X axis by this factor. Default: `1.0`. To reverse the X axis, specify a negative value like `-1`. To disable the X axis, specify `0`.
    ///   - verticalFactor:     Multiply the Y axis by this factor. Default: `1.0`. To reverse the Y axis, specify a negative value like `-1`. To disable the Y axis, specify `0`.
    public init(movementType:       PhysicsMovementType = .force,
                timeStep:           TimeStep = .perSecond,
                magnitude:          AcceleratedValue<CGFloat>,
                horizontalFactor:   CGFloat  = 1.0,
                verticalFactor:     CGFloat  = 1.0)
    {
        self.movementType       = movementType
        self.timeStep           = timeStep

        self.magnitude          = magnitude
        self.horizontalFactor   = horizontalFactor
        self.verticalFactor     = verticalFactor

        super.init()
    }
    
    /// - Parameters:
    ///   - movementType: Specifies whether this component represents a continuous force (applied every frame) or an instantaneous impulse (applied in discrete steps). Default: `.force`.
    ///   - timeStep:           Specifies a fixed or variable time step for per-update changes. Default: `.perSecond`.
    ///   - baseMagnitude:      The minimum magnitude to apply to the physics body on every update. Affected by `timeStep`.
    ///   - maximumMagnitude:   The maximum magnitude to allow after acceleration has been applied.
    ///   - acceleration:       The amount to increase the magnitude by, per update, while there is player input. The magnitude is reset to the `baseMagnitude` when there is no player input. Affected by `timeStep`.
    ///   - horizontalFactor:   Multiply the X axis by this factor. Default: `1.0`. To reverse the X axis, specify a negative value like `-1`. To disable the X axis, specify `0`.
    ///   - verticalFactor:     Multiply the Y axis by this factor. Default: `1.0`. To reverse the Y axis, specify a negative value like `-1`. To disable the Y axis, specify `0`.
    public convenience init(movementType:       PhysicsMovementType = .force,
                            timeStep:           TimeStep = .perSecond,
                            baseMagnitude:      CGFloat  = 600,  // ÷ 60 = 10 per frame
                            maximumMagnitude:   CGFloat  = 1200, // ÷ 60 = 20 per frame
                            acceleration:       CGFloat  = 600,
                            horizontalFactor:   CGFloat  = 1.0,
                            verticalFactor:     CGFloat  = 1.0)
    {
        self.init(movementType: movementType,
                  timeStep:     timeStep,
                  magnitude:    AcceleratedValue<CGFloat>(base:         baseMagnitude,
                                                          current:      baseMagnitude,
                                                          maximum:      maximumMagnitude,
                                                          minimum:      0,
                                                          acceleration: acceleration),
                  horizontalFactor: horizontalFactor,
                  verticalFactor:   verticalFactor)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let directionEventComponent = coComponent(DirectionEventComponent.self),
            !directionEventComponent.directionsActive.isEmpty,
            let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody ?? entityNode?.physicsBody
            else {
                magnitude.reset() // TODO: PERFORMANCE: Figure out a better way than setting this every update.
                return
        }
        
        // Did player input a direction?
        
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to generate diagonal forces and also cancel out opposing directions.
        
        let magnitudeForCurrentUpdate = timeStep.applying(magnitude.current, deltaTime: CGFloat(seconds))
        var vector = CGVector.zero

        // TODO: Options for discrete (D-Pad) and analog (joystick) input.
        
        vector = directionEventComponent.combinedDirection * magnitudeForCurrentUpdate

        // Apply any multipliers.
        
        vector.dx *= horizontalFactor
        vector.dy *= verticalFactor
        
        // Apply the final vector to the body.
        
        #if LOGINPUTEVENTS
        debugLog("magnitude: \(magnitude), magnitudeForCurrentUpdate: \(magnitudeForCurrentUpdate), factors: (\(horizontalFactor), \(verticalFactor)), force: \(vector)")
        #endif

        switch movementType {
        case .force:    physicsBody.applyForce(vector)
        case .impulse:  physicsBody.applyImpulse(vector)
        }

        // Apply acceleration for the next update.
        
        if  magnitude.isWithinBounds {
            magnitude.update(timeStep: timeStep, deltaTime: CGFloat(seconds))
            magnitude.clamp()
        }
    }
}
