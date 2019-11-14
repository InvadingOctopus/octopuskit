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

/// Modifies the `zRotation` of the entity's `SpriteKitComponent` node to face it towards the point touched by the player, as received via a `TouchEventComponent`.
///
/// See also: `PositionSeekingGoalComponent` and `TouchControlledSeekingComponent`
///
/// **Dependencies:** `SpriteKitComponent`, `TouchEventComponent`
public final class TouchControlledRotationComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         TouchEventComponent.self]
    }
    
    /// The maximum amount to rotate the node by in a single second.
    public var radiansPerSecond: CGFloat = 1.0
    
    public init(radiansPerSecond: CGFloat = 1.0) {
        self.radiansPerSecond = radiansPerSecond
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // CHECK: Would it be more natural to follow the LATEST touch instead of just the first?
        
        guard
            let node = entityNode,
            let scene = node.scene,
            let touchEventComponent = coComponent(TouchEventComponent.self),
            let touch = touchEventComponent.touches.first
            else { return }
        
        // #1: Get the target angle to rotate towards.
        
        var nodeRotationForThisFrame = node.zRotation // CHECK: .truncatingRemainder(dividingBy: CGFloat.pi * 2) // PERFORMANCE: Does this local variable help performance by reducing property accesses, or is that the compiler's job?
        
        let touchLocation = touch.location(in: scene) // TODO: Verify with nested nodes etc.
        let targetRotation = node.position.radians(to: touchLocation) //CHECK: .truncatingRemainder(dividingBy: CGFloat.pi * 2)
        
        // #2: Calculate the maximum rotation for this frame, based on this component's property.
        
        let rotationAmountForThisFrame = radiansPerSecond * CGFloat(seconds)
        
        /// A variation of the rotation calculation method, using `atan2`.
        func updateUsingAtan2(deltaTime seconds: TimeInterval) {
            
            // #3: Exit if we're already aligned or the difference is very small.
            // CHECK: Make sure we snapped in the previous frame, before exiting early like this.
            
            guard abs(targetRotation - nodeRotationForThisFrame) > rotationAmountForThisFrame else { return }
            
            // #4: Decide the direction to rotate in.
            
            let delta = node.deltaBetweenRotation(and: targetRotation)
            
            if delta > 0 {
                nodeRotationForThisFrame += rotationAmountForThisFrame
            }
            else if delta < 0 {
                nodeRotationForThisFrame -= rotationAmountForThisFrame
            }
            
            // #5: Snap to the target angle if we passed it this frame.
            
            if abs(delta) < abs(rotationAmountForThisFrame) {
                nodeRotationForThisFrame = targetRotation
            }
            
            #if LOGINPUTEVENTS
            debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), touchLocation = \(touchLocation), targetRotation = \(targetRotation), delta = \(delta), rotationAmountForThisFrame = \(rotationAmountForThisFrame)")
            #endif
        }
        
        /// A variation of the rotation calculation method, using a modulo operation, as suggested by TheGreatDuck#9159 from the Reddit /r/GameDev Discord server.
        func updateUsingModulo(deltaTime seconds: TimeInterval) {
            
            // #3: Exit if we're already aligned or the difference is very small.
            
            guard abs(targetRotation - nodeRotationForThisFrame) > rotationAmountForThisFrame else { return }
            
            // #4: Decide the direction to rotate in.
            // THANKS: TheGreatDuck#9159 @ Reddit /r/GameDev Discord
            
            let a = (targetRotation - node.zRotation)
            let b = (2 * CGFloat.pi)
            let delta = a - b * floor(a / b) // `a modulo b` == `a - b * floor (a / b)` // PERFORMANCE: Should be more efficient than a lot of trigonometry math. Right?
            
            if  delta > CGFloat.pi {
                nodeRotationForThisFrame -= rotationAmountForThisFrame
            }
            else if delta <= CGFloat.pi {
                nodeRotationForThisFrame += rotationAmountForThisFrame
            }
            
            #if LOGINPUTEVENTS
            debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), targetRotation = \(targetRotation), delta = \(delta), rotationAmountForThisFrame = \(rotationAmountForThisFrame)")
            #endif
            
            // #5: Snap to the target angle if we passed it this frame.
            // CHECK: Confirm that we are snapping after passing, not "jumping" ahead [a frame earlier] when the difference is small enough.
            
            if  abs(targetRotation - nodeRotationForThisFrame) < rotationAmountForThisFrame {
                nodeRotationForThisFrame = targetRotation
            }
        }
        
        /// A variation of the rotation calculation method, using Euclidean distance, as suggested by DefecateRainbows#1650 from the Reddit /r/GameDev Discord server.
        func updateUsingEuclideanDistance(deltaTime seconds: TimeInterval) {
            
            // #1: Get two points; one in front of the node, rotated slightly clockwise, and another in front of the node, rotated slightly counterclockwise.
            
            let touchLocation = touch.location(in: scene) // TODO: Verify with nested nodes etc.
            let touchDistance = node.position.distance(to: touchLocation)
            let targetRotation = node.position.radians(to: touchLocation)
            
            if Float(nodeRotationForThisFrame) == Float(targetRotation) { return }
            
            let nodePosition = node.position // PERFORMANCE: Does this local variable help performance by reducing property accesses, or is that the compiler's job?
            let rotationAmountForThisFrame = radiansPerSecond * CGFloat(seconds)
            
            let slightlyClockwisePoint = nodePosition.point(
                atAngle: nodeRotationForThisFrame - rotationAmountForThisFrame,
                distance: touchDistance)
            
            let slightlyCounterclockwisePoint = nodePosition.point(
                atAngle: nodeRotationForThisFrame + rotationAmountForThisFrame,
                distance: touchDistance)
            
            // #2: Get the Euclidean distance between each points and the touch location.
            
            let touchDistanceToClockwisePoint = touchLocation.distance(to: slightlyClockwisePoint)
            let touchDistanceToCounterclockwisePoint = touchLocation.distance(to: slightlyCounterclockwisePoint)
            
            // #3a: If the clockwise point is closer to the touch location, rotate clockwise.
            
            if  touchDistanceToClockwisePoint < touchDistanceToCounterclockwisePoint {
                nodeRotationForThisFrame -= rotationAmountForThisFrame
            }
            // #3b: If the counterclockwise point is closer to the touch location, rotate counterclockwise.
            else if touchDistanceToClockwisePoint > touchDistanceToCounterclockwisePoint {
                nodeRotationForThisFrame += rotationAmountForThisFrame
            }
            
            // TODO: Snap
            
            #if LOGINPUTEVENTS
            debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), targetRotation = \(targetRotation), delta = \(targetRotation - node.zRotation), touchDistanceToClockwisePoint = \(touchDistanceToClockwisePoint), touchDistanceToCounterclockwisePoint = \(touchDistanceToCounterclockwisePoint), rotationAmountForThisFrame = \(rotationAmountForThisFrame)")
            #endif
        }
        
        // MARK: Choose which function to use
        
        updateUsingModulo(deltaTime: seconds)
        
        // #?: Apply the calculated rotation to the node.
        
        node.zRotation = nodeRotationForThisFrame
    }
}

#endif

#if !canImport(UIKit)
public final class TouchControlledRotationComponent: iOSExclusiveComponent {}
#endif
