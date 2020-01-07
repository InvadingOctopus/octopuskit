//
//  DirectionControlledRotationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/25.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Rotates the entity's `SpriteKitComponent` node based on `DirectionEventComponent` input which may come from a keyboard, gamepad or joystick.
///
/// Set the `LOGINPUTEVENTS` compilation flag to log values.
///
/// **Dependencies:** `DirectionEventComponent`, `SpriteKitComponent`
public final class DirectionControlledRotationComponent: OKComponent, OKUpdatableComponent {
    
    // TODO: Tests
    
    public override var requiredComponents: [GKComponent.Type]? {
        [DirectionEventComponent.self,
         SpriteKitComponent.self]
    }
    
    /// The amount to rotate the node by in a single update, with optional acceleration. Affected by `timestep`.
    public var radiansPerUpdate:    AcceleratedValue<CGFloat>
    
    /// Specifies a fixed or variable timestep for per-update changes.
    public var timestep:            TimeStep

    /// If `true`, `radiansPerUpdate` is reset to its base value when there is no rotation, for realistic inertia.
    ///
    /// `radiansPerUpdate` is always reset when there is no player input.
    public var resetAccelerationWhenChangingDirection: Bool
    
    /// Records the previous direction for use with `resetAccelerationWhenChangingDirection`.
    public var directionForPreviousFrame: Int = 0 // Not private(set) so update(deltaTime:) can be @inlinable
    
    public init(radiansPerUpdate:   AcceleratedValue<CGFloat>,
                timestep:           TimeStep = .perSecond,
                resetAccelerationWhenChangingDirection: Bool = true)
    {
        self.radiansPerUpdate       = radiansPerUpdate
        self.timestep               = timestep
        self.resetAccelerationWhenChangingDirection = resetAccelerationWhenChangingDirection
        super.init()
    }

    public convenience init(radiansPerUpdate:   CGFloat  = 1.0, // ÷ 60 = 0.01666666667 per frame
                            acceleration:       CGFloat  = 0,
                            maximum:            CGFloat  = 1.0,
                            timestep:           TimeStep = .perSecond,
                            resetAccelerationWhenChangingDirection: Bool = true)
    {
        self.init(radiansPerUpdate: AcceleratedValue<CGFloat>(base:    radiansPerUpdate,
                                                              current: radiansPerUpdate,
                                                              maximum: maximum,
                                                              minimum: 0,
                                                              acceleration: acceleration),
                  timestep: timestep,
                  resetAccelerationWhenChangingDirection: resetAccelerationWhenChangingDirection)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #0: If there is no input for this frame, reset the acceleration and exit.
        
        guard
            let directionEventComponent = coComponent(DirectionEventComponent.self),
            !directionEventComponent.directionsActive.isEmpty,
            let node = entityNode
            else {
                // TODO: PERFORMANCE: Figure out a better way than setting these every frame.
                radiansPerUpdate.reset()
                directionForPreviousFrame = 0
                return
        }
        
        // #1: Did player press a directional arrow key?
        
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to cancel out opposing directions.
        // ❕ NOTE: Positive rotation = counter-clockwise :)
        
        let directionsActive = directionEventComponent.directionsActive
        var directionForCurrentFrame: Int = 0
        
        if  directionsActive.contains(.right) { directionForCurrentFrame -= 1 } // ➡️
        if  directionsActive.contains(.left)  { directionForCurrentFrame += 1 } // ➡️
        
        // #2: Reset the acceleration if the player changed the direction between updates.
        
        if  resetAccelerationWhenChangingDirection,
            self.directionForPreviousFrame != directionForCurrentFrame
        {
            radiansPerUpdate.reset()
        }
        
        self.directionForPreviousFrame = directionForCurrentFrame
        
        // #3: Exit if multiple directional inputs cancel each other out, this prevents accumulation of acceleration when there is no movement.
        
        guard directionForCurrentFrame != 0 else { return }
        
        // #4: Apply the rotation.
        
        // DESIGN: Multiplication instead of a couple `if`s may look smarter, but it would require CGFloat instead of Int :)
        
        let radiansForCurrentFrame = timestep.applying(radiansPerUpdate.current, deltaTime: CGFloat(seconds))
        var rotationAmountForCurrentFrame: CGFloat = 0
        
        if  directionsActive.contains(.right) { // ➡️
            rotationAmountForCurrentFrame -= radiansForCurrentFrame
        }
        
        if  directionsActive.contains(.left)  { // ⬅️
            rotationAmountForCurrentFrame += radiansForCurrentFrame
        }
        
        node.zRotation += rotationAmountForCurrentFrame
        
        #if LOGINPUTEVENTS
        debugLog("node.zRotation = \(node.zRotation), rotationAmountForCurrentFrame =  \(rotationAmountForCurrentFrame), radiansPerUpdate = \(radiansPerUpdate), \(timestep)")
        #endif
        
        // #5: Apply any acceleration, and clamp the speed to the pre-specified bounds.
        
        if  radiansPerUpdate.isWithinBounds { // CHECK: PERFORMANCE
            radiansPerUpdate.update(timestep: timestep, deltaTime: CGFloat(seconds))
            radiansPerUpdate.clamp()
        }
    }
}
