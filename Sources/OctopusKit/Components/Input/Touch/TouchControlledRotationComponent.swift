//
//  TouchControlledRotationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/14.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit
import GameplayKit

#if canImport(UIKit)

/// Modifies the `zRotation` of the entity's `SpriteKitComponent` node to gradually turn it towards the touch location as received via a `TouchEventComponent`.
///
/// See also: `PositionSeekingGoalComponent` and `TouchControlledSeekingComponent`
///
/// **Dependencies:** `SpriteKitComponent`, `TouchEventComponent`
@available(iOS 13.0, *)
public final class TouchControlledRotationComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // TODO: Add acceleration, like `KeyboardControlledRotationComponent`
    // TODO: Tests
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         TouchEventComponent.self]
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
    ///   - acceleration: The amount to increase the rotation by on every update, while there is touch input. The rotation is reset to `radiansPerUpdate` when there is no input. Affected by `timestep`.
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
        
        // CHECK: Would it be more natural to follow the LATEST touch instead of just the first?
        
        guard
            let node  = entityNode,
            let scene = node.scene,
            let touchEventComponent = coComponent(TouchEventComponent.self),
            let touch = touchEventComponent.touches.first
            else {
                 radiansPerUpdate.reset() // TODO: PERFORMANCE: Figure out a better way than setting this every update.
                return
        }
        
        // 💡 See alternative techniques for calculating the rotation at the bottom of this file.
        
        // #1: Get the target angle to rotate towards.
        
        var nodeRotationForThisFrame = node.zRotation // CHECK: .truncatingRemainder(dividingBy: .pi * 2) // PERFORMANCE: Does this local variable help performance by reducing property accesses, or is that the compiler's job?
        
        let touchLocation  = touch.location(in: scene) // TODO: Verify with nested nodes etc.
        let targetRotation = node.position.radians(to: touchLocation) //CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        
        // #2: Calculate the maximum rotation for this update, based on this component's property.
        
        let rotationAmountForCurrentFrame = timestep.applying(radiansPerUpdate.current, deltaTime: CGFloat(seconds))
        
        // #3: Exit if we're already aligned or the difference is very small.
        // CHECK: Make sure we snapped in the previous frame, before exiting early like this.
        
        guard abs(targetRotation - nodeRotationForThisFrame) > rotationAmountForCurrentFrame else { return }
        
        // #4: Decide the direction to rotate in.
        // THANKS: TheGreatDuck#9159 @ Reddit /r/GameDev Discord
        
        let a = (targetRotation - node.zRotation)
        let b = (2 * CGFloat.pi)
        let delta = a - b * floor(a / b) // `a modulo b` == `a - b * floor (a / b)` // PERFORMANCE: Should be more efficient than a lot of trigonometry math. Right?
        
        if  delta > .pi {
            nodeRotationForThisFrame -= rotationAmountForCurrentFrame
        }
        else if delta <= .pi {
            nodeRotationForThisFrame += rotationAmountForCurrentFrame
        }
        
        #if LOGINPUTEVENTS
        debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), targetRotation = \(targetRotation), delta = \(delta), rotationAmountForCurrentFrame = \(rotationAmountForCurrentFrame)")
        #endif
        
        // #5: Snap to the target angle if we passed it this frame.
        // CHECK: Confirm that we are snapping after passing, not "jumping" ahead [a frame earlier] when the difference is small enough.
        
        if  abs(targetRotation - nodeRotationForThisFrame) < rotationAmountForCurrentFrame {
            nodeRotationForThisFrame = targetRotation
        }
        
        // #6: Apply the calculated rotation to the node.
        node.zRotation = nodeRotationForThisFrame
        
        // #7: Apply any acceleration, and clamp the radians to the pre-specified bounds.
        radiansPerUpdate.update(timestep: timestep, deltaTime: CGFloat(seconds))
        radiansPerUpdate.clamp()
    }
}

#endif

#if !canImport(UIKit)
@available(macOS, unavailable, message: "Use PointerControlledRotationComponent")
public final class TouchControlledRotationComponent: iOSExclusiveComponent {}
#endif

// MARK: - Alternative Techniques

#if AlternativeImplementation

public extension TouchControlledRotationComponent {
    
    // ℹ️ Alternative techniques for calculating the rotation in `TouchControlledRotationComponent`.
    // ❕ May be outdated in relation to the APIs used by the active implementation.
    
    /// A variation of the rotation calculation algorithm, using `atan2`.
    @inlinable
    fileprivate func updateUsingAtan2(deltaTime seconds: TimeInterval) {
        
        // #1: Get the target angle to rotate towards.
        
        var nodeRotationForThisFrame = node.zRotation // CHECK: .truncatingRemainder(dividingBy: .pi * 2) // PERFORMANCE: Does this local variable help performance by reducing property accesses, or is that the compiler's job?
        
        let touchLocation  = touch.location(in: scene) // TODO: Verify with nested nodes etc.
        let targetRotation = node.position.radians(to: touchLocation) //CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        
        // #2: Calculate the maximum rotation for this frame, based on this component's property.
        
        let rotationAmountForCurrentFrame = radiansPerUpdate * CGFloat(seconds)
        
        // #3: Exit if we're already aligned or the difference is very small.
        // CHECK: Make sure we snapped in the previous frame, before exiting early like this.
        
        guard abs(targetRotation - nodeRotationForThisFrame) > rotationAmountForCurrentFrame else { return }
        
        // #4: Decide the direction to rotate in.
        
        let delta = node.deltaBetweenRotation(and: targetRotation)
        
        if  delta > 0 {
            nodeRotationForThisFrame += rotationAmountForCurrentFrame
        
        } else if delta < 0 {
            nodeRotationForThisFrame -= rotationAmountForCurrentFrame
        }
        
        // #5: Snap to the target angle if we passed it this frame.
        
        if  abs(delta) < abs(rotationAmountForCurrentFrame) {
            nodeRotationForThisFrame = targetRotation
        }
        
        // #6: Apply the calculated rotation to the node.
        
        #if LOGINPUTEVENTS
        debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), touchLocation = \(touchLocation), targetRotation = \(targetRotation), delta = \(delta), rotationAmountForCurrentFrame = \(rotationAmountForCurrentFrame)")
        #endif
        
        node.zRotation = nodeRotationForThisFrame
    }
    
    /// A variation of the rotation calculation algorithm, using a modulo operation, as suggested by TheGreatDuck#9159 from the Reddit /r/GameDev Discord server.
    @inlinable
    fileprivate func updateUsingModulo(deltaTime seconds: TimeInterval) {
        
        // #1: Get the target angle to rotate towards.
        
        var nodeRotationForThisFrame = node.zRotation // CHECK: .truncatingRemainder(dividingBy: .pi * 2) // PERFORMANCE: Does this local variable help performance by reducing property accesses, or is that the compiler's job?
        
        let touchLocation  = touch.location(in: scene) // TODO: Verify with nested nodes etc.
        let targetRotation = node.position.radians(to: touchLocation) //CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        
        // #2: Calculate the maximum rotation for this frame, based on this component's property.
        
        let rotationAmountForCurrentFrame = radiansPerUpdate * CGFloat(seconds)
        
        // #3: Exit if we're already aligned or the difference is very small.
        // CHECK: Make sure we snapped in the previous frame, before exiting early like this.
        
        guard abs(targetRotation - nodeRotationForThisFrame) > rotationAmountForCurrentFrame else { return }
        
        // #4: Decide the direction to rotate in.
        // THANKS: TheGreatDuck#9159 @ Reddit /r/GameDev Discord
        
        let a = (targetRotation - node.zRotation)
        let b = (2 * .pi)
        let delta = a - b * floor(a / b) // `a modulo b` == `a - b * floor (a / b)` // PERFORMANCE: Should be more efficient than a lot of trigonometry math. Right?
        
        if  delta > .pi {
            nodeRotationForThisFrame -= rotationAmountForCurrentFrame
        
        } else if delta <= .pi {
            nodeRotationForThisFrame += rotationAmountForCurrentFrame
        }
        
        #if LOGINPUTEVENTS
        debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), targetRotation = \(targetRotation), delta = \(delta), rotationAmountForCurrentFrame = \(rotationAmountForCurrentFrame)")
        #endif
        
        // #5: Snap to the target angle if we passed it this frame.
        // CHECK: Confirm that we are snapping after passing, not "jumping" ahead [a frame earlier] when the difference is small enough.
        
        if  abs(targetRotation - nodeRotationForThisFrame) < rotationAmountForCurrentFrame {
            nodeRotationForThisFrame = targetRotation
        }
        
        // #6: Apply the calculated rotation to the node.
        node.zRotation = nodeRotationForThisFrame
        
    }
    
    /// A variation of the rotation calculation algorithm, using Euclidean distance, as suggested by DefecateRainbows#1650 from the Reddit /r/GameDev Discord server.
    @inlinable
    fileprivate func updateUsingEuclideanDistance(deltaTime seconds: TimeInterval) {
        
        // #1: Get two points; one in front of the node, rotated slightly clockwise, and another in front of the node, rotated slightly counterclockwise.
        
        let touchLocation  = touch.location(in: scene) // TODO: Verify with nested nodes etc.
        let touchDistance  = node.position.distance(to: touchLocation)
        let targetRotation = node.position.radians(to: touchLocation)
        
        if Float(nodeRotationForThisFrame) == Float(targetRotation) { return }
        
        let nodePosition = node.position // PERFORMANCE: Does this local variable help performance by reducing property accesses, or is that the compiler's job?
        let rotationAmountForCurrentFrame = radiansPerUpdate * CGFloat(seconds)
        
        let slightlyClockwisePoint = nodePosition.point(
            atAngle:  nodeRotationForThisFrame - rotationAmountForCurrentFrame,
            distance: touchDistance)
        
        let slightlyCounterclockwisePoint = nodePosition.point(
            atAngle:  nodeRotationForThisFrame + rotationAmountForCurrentFrame,
            distance: touchDistance)
        
        // #2: Get the Euclidean distance between each points and the touch location.
        
        let touchDistanceToClockwisePoint = touchLocation.distance(to: slightlyClockwisePoint)
        let touchDistanceToCounterclockwisePoint = touchLocation.distance(to: slightlyCounterclockwisePoint)
        
        // #3a: If the clockwise point is closer to the touch location, rotate clockwise.
        
        if  touchDistanceToClockwisePoint < touchDistanceToCounterclockwisePoint {
            nodeRotationForThisFrame -= rotationAmountForCurrentFrame
        }
        // #3b: If the counterclockwise point is closer to the touch location, rotate counterclockwise.
        else if touchDistanceToClockwisePoint > touchDistanceToCounterclockwisePoint {
            nodeRotationForThisFrame += rotationAmountForCurrentFrame
        }
        
        // #4: Apply the calculated rotation to the node.
        // TODO: Snap
        
        #if LOGINPUTEVENTS
        debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), targetRotation = \(targetRotation), delta = \(targetRotation - node.zRotation), touchDistanceToClockwisePoint = \(touchDistanceToClockwisePoint), touchDistanceToCounterclockwisePoint = \(touchDistanceToCounterclockwisePoint), rotationAmountForCurrentFrame = \(rotationAmountForCurrentFrame)")
        #endif
        
        node.zRotation = nodeRotationForThisFrame
    }
    
}

#endif
