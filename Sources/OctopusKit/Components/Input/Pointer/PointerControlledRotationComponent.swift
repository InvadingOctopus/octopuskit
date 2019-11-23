//
//  PointerControlledRotationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/14.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests
// CHECK: Make it "PositionControlled" to be usable with joystick input too?

import SpriteKit
import GameplayKit

/// Modifies the `zRotation` of the entity's `SpriteKitComponent` node to face it towards the point pointed by the player, as received via a `PointerEventComponent`.
///
/// See also: `PositionSeekingGoalComponent` and `PointerControlledSeekingComponent`
///
/// **Dependencies:** `SpriteKitComponent`, `PointerEventComponent`
public final class PointerControlledRotationComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // TODO: Add acceleration, like `KeyboardControlledRotationComponent`.
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         PointerEventComponent.self]
    }
    
    /// The maximum amount to rotate the node by in a single second.
    public var radiansPerSecond: CGFloat = 1.0
    
    public init(radiansPerSecond: CGFloat = 1.0) {
        self.radiansPerSecond = radiansPerSecond
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let node = entityNode,
            let scene = node.scene,
            let pointerEventComponent = coComponent(PointerEventComponent.self),
            let lastEvent = pointerEventComponent.lastEvent // NOTE: Use `lastEvent` instead of `latestEventForCurrentFrame`, because we want to continue the rotation if needed, even if the pointer does not move.
            else { return }
        
        // #1: Get the target angle to rotate towards.
        
        var nodeRotationForThisFrame = node.zRotation // CHECK: .truncatingRemainder(dividingBy: CGFloat.pi * 2) // PERFORMANCE: Does this local variable help performance by reducing property accesses, or is that the compiler's job?
        
        let pointerLocation = lastEvent.location(in: scene) // TODO: Verify with nested nodes etc.
        
        let targetRotation = node.position.radians(to: pointerLocation) //CHECK: .truncatingRemainder(dividingBy: CGFloat.pi * 2)
        
        // #2: Calculate the maximum rotation for this frame, based on this component's property.
        
        let rotationAmountForCurrentFrame = radiansPerSecond * CGFloat(seconds)
        
        /// A variation of the rotation calculation method, using `atan2`.
        func updateUsingAtan2(deltaTime seconds: TimeInterval) {
            
            // #3: Exit if we're already aligned or the difference is very small.
            // CHECK: Make sure we snapped in the previous frame, before exiting early like this.
            
            guard abs(targetRotation - nodeRotationForThisFrame) > rotationAmountForCurrentFrame else { return }
            
            // #4: Decide the direction to rotate in.
            
            let delta = node.deltaBetweenRotation(and: targetRotation)
            
            if  delta > 0 {
                nodeRotationForThisFrame += rotationAmountForCurrentFrame
            }
            else if delta < 0 {
                nodeRotationForThisFrame -= rotationAmountForCurrentFrame
            }
            
            // #5: Snap to the target angle if we passed it this frame.
            
            if  abs(delta) < abs(rotationAmountForCurrentFrame) {
                nodeRotationForThisFrame = targetRotation
            }
            
            #if LOGINPUTEVENTS
            debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), pointerLocation = \(pointerLocation), targetRotation = \(targetRotation), delta = \(delta), rotationAmountForCurrentFrame = \(rotationAmountForCurrentFrame)")
            #endif
        }
        
        /// A variation of the rotation calculation method, using a modulo operation, as suggested by TheGreatDuck#9159 from the Reddit /r/GameDev Discord server.
        func updateUsingModulo(deltaTime seconds: TimeInterval) {
            
            // #3: Exit if we're already aligned or the difference is very small.
            
            guard abs(targetRotation - nodeRotationForThisFrame) > rotationAmountForCurrentFrame else { return }
            
            // #4: Decide the direction to rotate in.
            // THANKS: TheGreatDuck#9159 @ Reddit /r/GameDev Discord
            
            let a = (targetRotation - node.zRotation)
            let b = (2 * CGFloat.pi)
            let delta = a - b * floor(a / b) // `a modulo b` == `a - b * floor (a / b)` // PERFORMANCE: Should be more efficient than a lot of trigonometry math. Right?
            
            if  delta > CGFloat.pi {
                nodeRotationForThisFrame -= rotationAmountForCurrentFrame
            }
            else if delta <= CGFloat.pi {
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
        }
        
        /// A variation of the rotation calculation method, using Euclidean distance, as suggested by DefecateRainbows#1650 from the Reddit /r/GameDev Discord server.
        func updateUsingEuclideanDistance(deltaTime seconds: TimeInterval) {
            
            // THANKS: DefecateRainbows#1650 @ Reddit /r/GameDev Discord
            // TODO: A better or more elegant/efficient way to do all this?
            
            // #1: Get two points; one in front of the node, rotated slightly clockwise, and another in front of the node, rotated slightly counterclockwise.
            
            let pointerDistance = node.position.distance(to: pointerLocation)
            let targetRotation = node.position.radians(to: pointerLocation)
            
            if Float(nodeRotationForThisFrame) == Float(targetRotation) { return }
            
            let nodePosition = node.position // PERFORMANCE: Does this local variable help performance by reducing property accesses, or is that the compiler's job?
            let rotationAmountForCurrentFrame = radiansPerSecond * CGFloat(seconds)
            
            let slightlyClockwisePoint = nodePosition.point(
                atAngle: nodeRotationForThisFrame - rotationAmountForCurrentFrame,
                distance: pointerDistance)
            
            let slightlyCounterclockwisePoint = nodePosition.point(
                atAngle: nodeRotationForThisFrame + rotationAmountForCurrentFrame,
                distance: pointerDistance)
            
            // #2: Get the Euclidean distance between each points and the pointer location.
            
            let pointerDistanceToClockwisePoint = pointerLocation.distance(to: slightlyClockwisePoint)
            let pointerDistanceToCounterclockwisePoint = pointerLocation.distance(to: slightlyCounterclockwisePoint)
            
            // #3a: If the clockwise point is closer to the pointer location, rotate clockwise.
            
            if  pointerDistanceToClockwisePoint < pointerDistanceToCounterclockwisePoint {
                nodeRotationForThisFrame -= rotationAmountForCurrentFrame
            }
            // #3b: If the counterclockwise point is closer to the pointer location, rotate counterclockwise.
            else if pointerDistanceToClockwisePoint > pointerDistanceToCounterclockwisePoint {
                nodeRotationForThisFrame += rotationAmountForCurrentFrame
            }
            
            // TODO: Snap
            
            #if LOGINPUTEVENTS
            debugLog("node.zRotation = \(node.zRotation) → \(nodeRotationForThisFrame), targetRotation = \(targetRotation), delta = \(targetRotation - node.zRotation), pointerDistanceToClockwisePoint = \(pointerDistanceToClockwisePoint), pointerDistanceToCounterclockwisePoint = \(pointerDistanceToCounterclockwisePoint), rotationAmountForCurrentFrame = \(rotationAmountForCurrentFrame)")
            #endif
        }
        
        // MARK: Choose which function to use
        
        updateUsingModulo(deltaTime: seconds)
        
        // #?: Apply the calculated rotation to the node.
        
        node.zRotation = nodeRotationForThisFrame
    }
}
