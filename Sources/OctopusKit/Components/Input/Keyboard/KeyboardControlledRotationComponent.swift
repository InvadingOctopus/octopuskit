//
//  KeyboardControlledRotationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/23.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if canImport(Appkit)

/// Rotates the entity's `SpriteKitComponent` node based on `KeyboardEventComponent` input.
///
/// Set the `LOGINPUTEVENTS` compilation flag to log values.
///
/// **Dependencies:** `KeyboardEventComponent`, `SpriteKitComponent`
@available(macOS 10.15, *)
public final class KeyboardControlledRotationComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // TODO: Reset the acceleration when the direction reverses, as that is more natural.
    
    public override var requiredComponents: [GKComponent.Type]? {
        [KeyboardEventComponent.self,
         SpriteKitComponent.self]
    }
    
    /// Change this to a different code to customize the keys.
    public var arrowRight:  UInt16 = .arrowRight
    /// Change this to a different code to customize the keys.
    public var arrowLeft:   UInt16 = .arrowLeft

    /// The minimum amount to rotate the node by in a single second.
    public var baseRadiansPerSecond:     CGFloat = 1.0
    
    public var maximumRadiansPerSecond:  CGFloat = 1.0
    public var acceleratedRadians:       CGFloat = 0
    public var accelerationPerSecond:    CGFloat = 0
    
    public init(baseRadiansPerSecond:    CGFloat = 2.0,  // ÷ 60 per frame
                maximumRadiansPerSecond: CGFloat = 4.0,
                accelerationPerSecond:   CGFloat = 2.0)
    {
        self.baseRadiansPerSecond    = baseRadiansPerSecond
        self.maximumRadiansPerSecond = maximumRadiansPerSecond
        self.accelerationPerSecond   = accelerationPerSecond
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let keyboardEventComponent = coComponent(KeyboardEventComponent.self),
            !keyboardEventComponent.codesPressed.isEmpty,
            let node = entityNode
            else {
                acceleratedRadians = baseRadiansPerSecond // TODO: PERFORMANCE: Figure out a better way than setting this every frame.
                return
        }
        
        // Did player press a directional arrow key?
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to cancel out opposing directions.
        // ❕ NOTE: Positive rotation = counter-clockwise :)
        
        let codesPressed = keyboardEventComponent.codesPressed
        let radiansForCurrentFrame = acceleratedRadians * CGFloat(seconds)
        var rotationAmountForCurrentFrame: CGFloat = 0
        
        if codesPressed.contains(self.arrowRight) { rotationAmountForCurrentFrame -= radiansForCurrentFrame } // ➡️
        if codesPressed.contains(self.arrowLeft)  { rotationAmountForCurrentFrame += radiansForCurrentFrame } // ⬅️
        
        node.zRotation += rotationAmountForCurrentFrame
        
        // Apply acceleration for the next frame.
        
        if  acceleratedRadians < maximumRadiansPerSecond {
            acceleratedRadians += (accelerationPerSecond * CGFloat(seconds))
            if  acceleratedRadians > maximumRadiansPerSecond {
                acceleratedRadians = maximumRadiansPerSecond
            }
        }
    }
}

#endif

#if !canImport(AppKit)
// TODO: Add support for iOS/tvOS keyboards.
@available(iOS, unavailable)
@available(tvOS, unavailable)
public final class KeyboardControlledRotationComponent: macOSExclusiveComponent {}
#endif
