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

/// Applies a force to the entity's `PhysicsComponent` body on every frame, based on `KeyboardEventComponent` input.
///
/// **Dependencies:** `KeyboardEventComponent`, `PhysicsComponent`
///
/// Set the `LOGINPUTEVENTS` compilation flag to log the `acceleratedMagnitude`.
@available(macOS 10.15, *)
public final class KeyboardControlledForceComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [PhysicsComponent.self,
         KeyboardEventComponent.self]
    }
    
    public var baseMagnitude:           CGFloat
    public var maximumMagnitude:        CGFloat
    public var acceleratedMagnitude:    CGFloat = 0
    
    /// The amount to increase `acceleratedMagnitude` by on every frame. `acceleratedMagnitude` is reset to the base value when there is no keyboard input.
    public var accelerationPerFrame:    CGFloat
    
    public var reverseHorizontal, reverseVertical: Bool
    
    /// Change this to a different code to customize the keys.
    public var arrowUp:     UInt16 = .arrowUp
    /// Change this to a different code to customize the keys.
    public var arrowRight:  UInt16 = .arrowRight
    /// Change this to a different code to customize the keys.
    public var arrowDown:   UInt16 = .arrowDown
    /// Change this to a different code to customize the keys.
    public var arrowLeft:   UInt16 = .arrowLeft
    
    
    /// - Parameters:
    ///   - baseMagnitude: The minimum magnitude to apply to the physics body on every frame.
    ///   - maximumMagnitude: The maximum magnitude to allow after acceleration has been applied.
    ///   - accelerationPerFrame: The amount to increase the magnitude by on every frame while there is keyboard input. The magnitude is reset to the `baseMagnitude` when there is no keyboard input.
    ///   - reverseHorizontal: Reverse the X axis.
    ///   - reverseVertical: Reverse the Y axis.
    public init(baseMagnitude:          CGFloat = 10,
                maximumMagnitude:       CGFloat = 10,
                accelerationPerFrame:   CGFloat = 0,
                reverseHorizontal:      Bool    = false,
                reverseVertical:        Bool    = false)
    {
        self.baseMagnitude          = baseMagnitude
        self.maximumMagnitude       = maximumMagnitude
        self.accelerationPerFrame   = accelerationPerFrame
        self.reverseHorizontal      = reverseHorizontal
        self.reverseVertical        = reverseVertical
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let keyboardEventComponent = coComponent(KeyboardEventComponent.self),
            !keyboardEventComponent.codesPressed.isEmpty,
            let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody
            else
        {
            acceleratedMagnitude = baseMagnitude
            return
        }
        
        #if LOGINPUTEVENTS
        debugLog("acceleratedMagnitude: \(acceleratedMagnitude)")
        #endif
        
        // Did player press a directional arrow key?
        
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to generate diagonal forces and also cancel out opposing arrow keys.
        
        let codesPressed = keyboardEventComponent.codesPressed
        var vector       = CGVector.zero
        
        if codesPressed.contains(arrowUp)    { vector.dy += acceleratedMagnitude } // ⬆️
        if codesPressed.contains(arrowRight) { vector.dx += acceleratedMagnitude } // ➡️
        if codesPressed.contains(arrowDown)  { vector.dy -= acceleratedMagnitude } // ⬇️
        if codesPressed.contains(arrowLeft)  { vector.dx -= acceleratedMagnitude } // ⬅️
        
        // Apply any optional inversions.
        
        if reverseHorizontal { vector.dx = -vector.dx }
        if reverseVertical { vector.dy = -vector.dy }
        
        // Apply the final vector to the body.
                
        physicsBody.applyForce(vector)
        
        // Apply acceleration for the next frame.
        
        if  acceleratedMagnitude < maximumMagnitude {
            acceleratedMagnitude += accelerationPerFrame
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
public final class KeyboardControlledForceComponent: macOSExclusiveComponent {}
#endif
