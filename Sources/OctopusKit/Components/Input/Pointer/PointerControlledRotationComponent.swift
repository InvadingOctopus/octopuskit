//
//  PointerControlledRotationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/14.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Modifies the `zRotation` of the entity's `SpriteKitComponent` node to gradually turn it towards the pointed location as received via a `PointerEventComponent`.
///
/// See also: `PositionSeekingGoalComponent` and `PointerControlledSeekingComponent`
///
/// **Dependencies:** `SpriteKitComponent`, `PointerEventComponent`
public final class PointerControlledRotationComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // TODO: Tests
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         PointerEventComponent.self]
    }
    
    /// The amount to rotate the node by in a single update, with optional acceleration.
    public var radiansPerUpdate: AcceleratedValue<CGFloat>
    
    /// Specifies a fixed or variable timestep for per-update changes.
    public var timestep: TimeStep
    
    /// - Parameters:
    ///   - radiansPerUpdate: The amount of rotation to apply every update, with optional acceleration. Affected by `timestep`.
    ///   - timestep: Specifies a fixed or variable timestep for per-update changes. Default: `.perSecond`
    public init(radiansPerUpdate: AcceleratedValue<CGFloat>,
                timestep:         TimeStep = .perSecond)
    {
        self.radiansPerUpdate = radiansPerUpdate
        self.timestep = timestep
        super.init()
    }
    
    /// - Parameters:
    ///   - radiansPerUpdate: The amount of rotation to apply every update. Affected by `timestep`.
    ///   - timestep: Specifies a fixed or variable timestep for per-update changes. Default: `.perSecond`
    ///   - acceleration: The amount to increase the rotation by on every update, while there is pointer input. The rotation is reset to `radiansPerUpdate` when there is no input. Affected by `timestep`.
    ///   - maximum: The maximum permitted rotation per update.
    public convenience init(radiansPerUpdate:   CGFloat  = 1.0, // ÷ 60 = 0.01666666667 per frame
                            acceleration:       CGFloat  = 0,
                            maximum:            CGFloat  = 1.0,
                            timestep:           TimeStep = .perSecond)
    {
        self.init(radiansPerUpdate: AcceleratedValue<CGFloat>(base:    radiansPerUpdate,
                                                              current: radiansPerUpdate,
                                                              maximum: maximum,
                                                              minimum: 0,
                                                              acceleration: acceleration),
                  timestep: timestep)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let node = entityNode,
            let scene = node.scene,
            let pointerEventComponent = coComponent(PointerEventComponent.self),
            let lastEvent = pointerEventComponent.lastEvent, // NOTE: Use `lastEvent` instead of `latestEventForCurrentFrame`, because we want to continue the rotation if needed, even if the pointer does not move.
            lastEvent.category != .ended // We shouldn't continue rotating if the pointer ended. // TODO: Test with multi-touch.
            else {
                radiansPerUpdate.reset() // TODO: PERFORMANCE: Figure out a better way than setting this every update.
                return
        }
        
        // #1: Get the target angle to rotate towards.
        
        let pointerLocation = lastEvent.location(in: scene) // TODO: Verify with nested nodes etc.
        let targetRotation  = node.position.radians(to: pointerLocation) //CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        
        // #2: Calculate the maximum rotation for this update.
        
        let rotationAmountForCurrentFrame = timestep.applying(radiansPerUpdate.current, deltaTime: CGFloat(seconds))
        
        // #3: Rotate Your Owl
        
        #if LOGINPUTEVENTS
        let nodeRotationForThisFrame = node.zRotation.rotated(towards: targetRotation, by: rotationAmountForCurrentFrame)
        debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), targetRotation = \(targetRotation), delta = \(delta), rotationAmountForCurrentFrame = \(rotationAmountForCurrentFrame)")
        #endif
        
        node.zRotation.rotate(towards: targetRotation, by: rotationAmountForCurrentFrame)
        
        // #4: Apply any acceleration, and clamp the radians to the pre-specified bounds.
        
        if  radiansPerUpdate.isWithinBounds { // CHECK: PERFORMANCE
            radiansPerUpdate.update(timestep: timestep, deltaTime: CGFloat(seconds))
            radiansPerUpdate.clamp()
        }
    }
}
