//
//  KeyboardControlledForceComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/22.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if canImport(Appkit)

/// Applies a force to the entity's `PhysicsComponent` body on every update, based on `KeyboardEventComponent` input.
///
/// Set the `LOGINPUTEVENTS` compilation flag to log values.
///
/// **Dependencies:** `KeyboardEventComponent`, `PhysicsComponent`
@available(macOS 10.15, *)
public final class KeyboardControlledForceComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [KeyboardEventComponent.self,
        PhysicsComponent.self]
    }
    
    /// Change this to a different code to customize the keys.
    public var arrowUp:     UInt16 = .arrowUp
    /// Change this to a different code to customize the keys.
    public var arrowRight:  UInt16 = .arrowRight
    /// Change this to a different code to customize the keys.
    public var arrowDown:   UInt16 = .arrowDown
    /// Change this to a different code to customize the keys.
    public var arrowLeft:   UInt16 = .arrowLeft
    
    public var baseMagnitude:           CGFloat
    public var maximumMagnitude:        CGFloat
    public var acceleratedMagnitude:    CGFloat = 0
    
    /// The amount to increase `acceleratedMagnitude` by, per update, while there is keyboard input. `acceleratedMagnitude` is reset to `baseMagnitude` when there is no keyboard input.
    public var acceleration:            CGFloat
    
    public var horizontalFactor:        CGFloat = 1
    public var verticalFactor:          CGFloat = 1
    
    /// Specifies a fixed or variable timestep for per-update changes.
    ///
    /// For physics effects, a per-second timestep may be suitable.
    public var timestep:            TimeStep
    
    /// - Parameters:
    ///   - baseMagnitude: The minimum magnitude to apply to the physics body on every update.
    ///   - maximumMagnitude: The maximum magnitude to allow after acceleration has been applied.
    ///   - acceleration: The amount to increase the magnitude by, per update, while there is keyboard input. The magnitude is reset to the `baseMagnitude` when there is no keyboard input.
    ///   - horizontalFactor: Multiply the X axis force by this factor. Default: `1`. To reverse the X axis, specify a negative value like `-1`. To disable the X axis, specify `0`.
    ///   - verticalFactor: Multiply the Y axis force by this factor. Default: `1`. To reverse the Y axis, specify a negative value like `-1`. To disable the Y axis, specify `0`.
    ///   - timestep: Specifies a fixed or variable timestep for per-update changes. Default: `.perSecond`
    public init(baseMagnitude:      CGFloat = 600,  // ÷ 60 = 10 per frame
                maximumMagnitude:   CGFloat = 1200, // ÷ 60 = 20 per frame
                acceleration:       CGFloat = 600,
                horizontalFactor:   CGFloat = 1,
                verticalFactor:     CGFloat = 1,
                timestep:           TimeStep = .perSecond)
    {
        self.baseMagnitude      = baseMagnitude
        self.maximumMagnitude   = maximumMagnitude
        self.acceleration       = acceleration
        self.horizontalFactor   = horizontalFactor
        self.verticalFactor     = verticalFactor
        self.timestep           = timestep
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
                acceleratedMagnitude = baseMagnitude // TODO: PERFORMANCE: Figure out a better way than setting this every update.
                return
        }
        
        // Did player press a directional arrow key?
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to generate diagonal forces and also cancel out opposing directions.
        
        let codesPressed = keyboardEventComponent.codesPressed
        let magnitudeForCurrentUpdate = acceleratedMagnitude * ((timestep == .perFrame) ? 1 : CGFloat(seconds))
        var vector = CGVector.zero

        if codesPressed.contains(self.arrowUp)    { vector.dy += magnitudeForCurrentUpdate } // ⬆️
        if codesPressed.contains(self.arrowRight) { vector.dx += magnitudeForCurrentUpdate } // ➡️
        if codesPressed.contains(self.arrowDown)  { vector.dy -= magnitudeForCurrentUpdate } // ⬇️
        if codesPressed.contains(self.arrowLeft)  { vector.dx -= magnitudeForCurrentUpdate } // ⬅️
        
        // Apply any multipliers.
        
        vector.dx *= horizontalFactor
        vector.dy *= verticalFactor
        
        // Apply the final vector to the body.
        
        #if LOGINPUTEVENTS
        debugLog("acceleratedMagnitude: \(acceleratedMagnitude), magnitudeForCurrentUpdate: \(magnitudeForCurrentUpdate), acceleration: \(acceleration), horizontalFactor: \(horizontalFactor), verticalFactor: \(horizontalFactor), force: \(vector)")
        #endif
        
        physicsBody.applyForce(vector)
        
        // Apply acceleration for the next update.
        
        if  acceleratedMagnitude < maximumMagnitude {
            timestep.apply(acceleration, to: &acceleratedMagnitude, deltaTime: CGFloat(seconds)) // acceleratedMagnitude += (acceleration * CGFloat(seconds))
            if  acceleratedMagnitude > maximumMagnitude {
                acceleratedMagnitude = maximumMagnitude
            }
        }
    }
}

#endif

#if !canImport(AppKit)
// TODO: Add support for iOS/tvOS keyboards.
@available(iOS, unavailable)
@available(tvOS, unavailable)
public final class KeyboardControlledForceComponent: macOSExclusiveComponent {}
#endif
