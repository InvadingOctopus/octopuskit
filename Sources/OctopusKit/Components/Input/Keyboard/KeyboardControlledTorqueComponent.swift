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
public final class KeyboardControlledTorqueComponent: OKComponent, OKUpdatableComponent {
    
    // TODO: Tests
    // TODO: Improve the feel
    // TODO: Move `maximumAngularVelocity` to `PhysicsComponent`
    
    public override var requiredComponents: [GKComponent.Type]? {
        [KeyboardEventComponent.self,
         PhysicsComponent.self]
    }
    
    /// Change this to a different code to customize the keys.
    public var arrowRight:  UInt16 = .arrowRight
    /// Change this to a different code to customize the keys.
    public var arrowLeft:   UInt16 = .arrowLeft

    /// The torque in Newton-meters to apply to the node every update, with optional acceleration. Affected by `timestep`.
    public var torquePerUpdate:      AcceleratedValue<CGFloat>
    
    /// Specifies a fixed or variable timestep for per-update changes.
    public var timestep:                TimeStep
    
    /// - Parameters:
    ///   - torquePerUpdate: The amount of torque to apply every update, with optional acceleration. Affected by `timestep`.
    ///   - timestep: Specifies a fixed or variable timestep for per-update changes. Default: `.perSecond`
    public init(torquePerUpdate:    AcceleratedValue<CGFloat>,
                timestep:           TimeStep = .perSecond)
    {
        self.torquePerUpdate    = torquePerUpdate
        self.timestep           = timestep
        super.init()
    }
    
    /// - Parameters:
    ///   - torquePerUpdate: The torque in Newton-meters to apply to the physics body every second. Affected by `timestep`.
    ///   - acceleration: The amount to increase the torque by per second, while there is keyboard input. The torque is reset to the `torquePerUpdate` when there is no keyboard input. Affected by `timestep`.
    ///   - maximum: The maximum torque to allow after acceleration has been applied.
    ///   - timestep: Specifies a fixed or variable timestep for per-update changes. Default: `.perSecond`
    public convenience init(torquePerUpdate:    CGFloat  = 0.01, // ÷ 60 per frame
                            acceleration:       CGFloat  = 0,
                            maximum:            CGFloat  = 0.01, // ÷ 60 per frame
                            timestep:           TimeStep = .perSecond)
    {
        self.init(torquePerUpdate: AcceleratedValue<CGFloat>(base:    torquePerUpdate,
                                                             current: torquePerUpdate,
                                                             maximum: maximum,
                                                             minimum: 0,
                                                             acceleration: acceleration),
                  timestep: timestep)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #0: If there is no input or valid entity for this frame, reset the acceleration and exit.
        
        guard
            let keyboardEventComponent = coComponent(KeyboardEventComponent.self),
            !keyboardEventComponent.codesPressed.isEmpty,
            let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody ?? entityNode?.physicsBody
            else {
                torquePerUpdate.reset() // TODO: PERFORMANCE: Figure out a better way than setting this every frame.
                return
        }
        
        // #1: Did player press a directional arrow key?
        
        // ❕ NOTE: Don't use `switch` or `else` because we want to process multiple keypresses, to cancel out opposing directions.
        // ❕ NOTE: Positive rotation = counter-clockwise :)
        
        let codesPressed            = keyboardEventComponent.codesPressed
        let torqueForCurrentFrame   = timestep.applying(torquePerUpdate.current, deltaTime: CGFloat(seconds))
        var torqueToApply: CGFloat  = 0
        
        if  codesPressed.contains(self.arrowRight) { torqueToApply -= torqueForCurrentFrame } // ➡️
        if  codesPressed.contains(self.arrowLeft)  { torqueToApply += torqueForCurrentFrame } // ⬅️
        
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
            torquePerUpdate.update(timestep: timestep, deltaTime: CGFloat(seconds))
            torquePerUpdate.clamp()
        }
    }
}

#endif

#if !canImport(AppKit)
// TODO: Add support for iOS/tvOS keyboards.
@available(iOS,  unavailable)
@available(tvOS, unavailable)
public final class KeyboardControlledTorqueComponent: macOSExclusiveComponent {}
#endif
