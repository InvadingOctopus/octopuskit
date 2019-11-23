//
//  KeyboardControlledTorqueComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/23.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if canImport(Appkit)

/// Applies a torque to the entity's `PhysicsComponent` body every frame based on `KeyboardEventComponent` input.
///
/// Set the `LOGINPUTEVENTS` compilation flag to log values.
///
/// **Dependencies:** `KeyboardEventComponent`, `PhysicsComponent`
@available(macOS 10.15, *)
public final class KeyboardControlledTorqueComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // TODO: Reset the acceleration when the direction reverses, as that is more natural.
    // TODO: Move `maximumAngularVelocity` to `PhysicsComponent`
    // TODO: Improve
    
    public override var requiredComponents: [GKComponent.Type]? {
        [KeyboardEventComponent.self,
         PhysicsComponent.self]
    }
    
    /// Change this to a different code to customize the keys.
    public var arrowRight:  UInt16 = .arrowRight
    /// Change this to a different code to customize the keys.
    public var arrowLeft:   UInt16 = .arrowLeft

    /// The minimum amount to rotate the node by in a single second.
    public var baseMagnitudePerSecond:      CGFloat
    
    public var maximumMagnitudePerSecond:   CGFloat
    public var acceleratedMagnitude:        CGFloat = 0
    public var accelerationPerSecond:       CGFloat
    public var maximumAngularVelocity:      CGFloat
    
    public init(baseMagnitudePerSecond:     CGFloat = 1.0,  // ÷ 60 per frame
                maximumMagnitudePerSecond:  CGFloat = 1.0,
                maximumAngularVelocity:     CGFloat = 2.0,
                accelerationPerSecond:      CGFloat = 0)
    {
        self.baseMagnitudePerSecond     = baseMagnitudePerSecond
        self.maximumMagnitudePerSecond  = maximumMagnitudePerSecond
        self.maximumAngularVelocity     = maximumAngularVelocity
        self.accelerationPerSecond      = accelerationPerSecond
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let keyboardEventComponent = coComponent(KeyboardEventComponent.self),
            !keyboardEventComponent.codesPressed.isEmpty,
            let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody ?? entityNode?.physicsBody
            else {
                acceleratedMagnitude = baseMagnitudePerSecond // TODO: PERFORMANCE: Figure out a better way than setting this every frame.
                return
        }
        
        // Did player press a directional arrow key?
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to cancel out opposing directions.
        // ❕ NOTE: Positive rotation = counter-clockwise :)
        
        let codesPressed = keyboardEventComponent.codesPressed
        let magnitudeForCurrentFrame = acceleratedMagnitude * CGFloat(seconds)
        let currentAngularVelocity   = physicsBody.angularVelocity
        var torqueForCurrentFrame: CGFloat = 0
        
        if codesPressed.contains(self.arrowRight) { torqueForCurrentFrame -= magnitudeForCurrentFrame } // ➡️
        if codesPressed.contains(self.arrowLeft)  { torqueForCurrentFrame += magnitudeForCurrentFrame } // ⬅️
        
        if  abs(currentAngularVelocity) < maximumAngularVelocity {
            physicsBody.applyTorque(torqueForCurrentFrame)
        }
        
        // Limit the body's maximum angular velocity.
        
        if  abs(currentAngularVelocity) > maximumAngularVelocity {
            // CHECK: Find a better way?
            physicsBody.angularVelocity = maximumAngularVelocity * CGFloat(sign(Float(physicsBody.angularVelocity)))
        }
        
        #if LOGINPUTEVENTS
        debugLog("acceleratedMagnitude: \(acceleratedMagnitude), magnitudeForCurrentFrame: \(magnitudeForCurrentFrame), torqueForCurrentFrame: \(torqueForCurrentFrame), angularVelocity: \(physicsBody.angularVelocity)")
        #endif
        
        // Apply acceleration for the next frame.
        
        if  acceleratedMagnitude < maximumMagnitudePerSecond {
            acceleratedMagnitude += (accelerationPerSecond * CGFloat(seconds))
            if  acceleratedMagnitude > maximumMagnitudePerSecond {
                acceleratedMagnitude = maximumMagnitudePerSecond
            }
        }
    }
}

#endif

#if !canImport(AppKit)
// TODO: Add support for iOS/tvOS keyboards.
@available(iOS, unavailable)
@available(tvOS, unavailable)
public final class KeyboardControlledTorqueComponent: macOSExclusiveComponent {}
#endif
