//
//  KeyboardControlledThrustComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/23.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if canImport(Appkit)

/// Applies a forward or backwards thrust to the entity's `PhysicsComponent` body on every frame, in the direction of the `SpriteKitComponent` node's rotation, based on `KeyboardEventComponent` input.
///
/// Set the `LOGINPUTEVENTS` compilation flag to log values.
///
/// **Dependencies:** `KeyboardEventComponent`, `PhysicsComponent`, `SpriteKitComponent`
@available(macOS 10.15, *)
public final class KeyboardControlledThrustComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [KeyboardEventComponent.self,
         PhysicsComponent.self,
         SpriteKitComponent.self]
    }
    
    /// Change this to a different code to customize the keys.
    public var arrowUp:     UInt16 = .arrowUp
    /// Change this to a different code to customize the keys.
    public var arrowDown:   UInt16 = .arrowDown
    
    public var baseMagnitudePerSecond:      CGFloat
    public var maximumMagnitudePerSecond:   CGFloat
    public var acceleratedMagnitude:        CGFloat = 0
    
    /// The amount to increase `acceleratedMagnitude` by per second, while there is keyboard input. `acceleratedMagnitude` is reset to `baseMagnitudePerSecond` when there is no keyboard input.
    public var accelerationPerSecond:       CGFloat
    
    /// Multiplies the force by the specified value. Default: `1`. To reverse the thrust, specify a negative value like `-1`. To disable thrust, specify `0`.
    public var factor:                      CGFloat = 1
    
    /// - Parameters:
    ///   - baseMagnitudePerSecond: The minimum magnitude to apply to the physics body every second.
    ///   - maximumMagnitudePerSecond: The maximum magnitude to allow after acceleration has been applied.
    ///   - accelerationPerSecond: The amount to increase the magnitude by per second, while there is keyboard input. The magnitude is reset to the `baseMagnitudePerSecond` when there is no keyboard input.
    ///   - factor: Multiply the force by this factor. Default: `1`. To reverse the thrust, specify a negative value like `-1`. To disable thrust, specify `0`.
    public init(baseMagnitudePerSecond:     CGFloat = 600,  // ÷ 60 = 10 per frame
                maximumMagnitudePerSecond:  CGFloat = 1200, // ÷ 60 = 20 per frame
                accelerationPerSecond:      CGFloat = 600,
                factor:                     CGFloat = 1)
    {
        self.baseMagnitudePerSecond     = baseMagnitudePerSecond
        self.maximumMagnitudePerSecond  = maximumMagnitudePerSecond
        self.accelerationPerSecond      = accelerationPerSecond
        self.factor                     = factor
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let keyboardEventComponent = coComponent(KeyboardEventComponent.self),
            !keyboardEventComponent.codesPressed.isEmpty,
            let node = entityNode,
            let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody ?? node.physicsBody
            else {
                acceleratedMagnitude = baseMagnitudePerSecond // TODO: PERFORMANCE: Figure out a better way than setting this every frame.
                return
        }
    
        // Did player press a directional arrow key?
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to cancel out opposing directions.
        
        let codesPressed = keyboardEventComponent.codesPressed
        var direction: CGFloat = 0
        
        if codesPressed.contains(self.arrowUp)    { direction += 1 } // ⬆️
        if codesPressed.contains(self.arrowDown)  { direction -= 1 } // ⬇️
        
        // Apply the force in relation to the node's current rotation.
        
        var magnitudeForCurrentFrame = acceleratedMagnitude * CGFloat(seconds)
        let vector = CGVector(radians: node.zRotation) * CGFloat(magnitudeForCurrentFrame * direction) * factor // TODO: Verify!
        
        // Apply the final vector to the body.
        
        #if LOGINPUTEVENTS
        debugLog("acceleratedMagnitude: \(acceleratedMagnitude), magnitudeForCurrentFrame: \(magnitudeForCurrentFrame), factor: \(factor), rotation: \(node.zRotation), force: \(vector)")
        #endif
        
        physicsBody.applyForce(vector)
        
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
public final class KeyboardControlledThrustComponent: macOSExclusiveComponent {}
#endif
