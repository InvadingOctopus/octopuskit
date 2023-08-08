//
//  PointerControlledImpulseComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/14.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Improve physics?
// CHECK: Add options for customizing the behavior?
// PERFORMANCE: May need optimization.

import OctopusCore
import SpriteKit
import GameplayKit

/// Allows the player to drag the entity's `PhysicsComponent` body based on input from the entity's `NodePointerStateComponent`.
///
/// - Prevents the body from being affected by gravity while it is being held.
/// - Modifies the body's velocity.
///
/// **Dependencies:** `NodePointerStateComponent, PhysicsComponent, NodeComponent`
public final class PointerControlledPhysicsDraggingComponent: OKComponent, RequiresUpdatesPerFrame {
    
    // ℹ️ DESIGN: Not pinning to the specific pointer location, because that would be inconvenient for the user to control on a [small] screen, and also seems like overkill in the amount of code it takes and the temporary node it needs to create, as well as likely impacting performance.
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         PhysicsComponent.self,
         NodePointerStateComponent.self]
    }
    
    @LogInputEventChanges(propertyName: "PointerControlledPhysicsDraggingComponent.isDragging")
    public var isDragging: Bool = false
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // A scene itself is not really draggable, so...
        
        if  node is SKScene {
            OKLog.logForWarnings.debug("\(📜("A PointerControlledPhysicsDraggingComponent cannot be added to the scene entity — Removing."))")
            OctopusKit.logForTips ("See CameraPanComponent.")
            self.removeFromEntity()
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #1: Make sure we have a node, that has a parent and a physics body, and a pointer is being tracked.
        
        // If the pointer is in any state other than `ready` or `disabled`, then it means the pointer may have moved, otherwise this component has nothing to do.
        
        guard
            let node        = self.entityNode,
            let parent      = node.parent,
            let physicsBody = coComponent(ofType: PhysicsComponent.self)?.physicsBody,
            let nodePointerStateComponent = coComponent(NodePointerStateComponent.self),
                nodePointerStateComponent.state != .ready || nodePointerStateComponent.state != .disabled,
            let latestEvent = nodePointerStateComponent.latestEventForCurrentFrame
            else {
                releaseBody()
                return
        }
        
        // PERFORMANCE: Cache the pointer component's properties locally so that we don't have to query another class's properties too much. CHECK: Should this be the job of the compiler?
        
        let currentPointerLocation = latestEvent.location(in: parent)
        
        #if LOGINPUTEVENTS
        let previousPointerLocation = nodePointerStateComponent.previousEvent?.location(in: parent) ?? currentPointerLocation // Instead of `CGPoint.zero` so we don't report a false delta for the first event in a sequence.
        let pointerLocationDelta = currentPointerLocation - previousPointerLocation
        debugLog("trackedPointer.location in parent: \(previousPointerLocation) → \(currentPointerLocation), delta: \(pointerLocationDelta), translation: \(nodePointerStateComponent.pointerTranslationInParent)")
        #endif
        
        // #2: Move the node's physics body.
        
        // ℹ️ NOTE: We have to move the body to the pointed position in EVERY FRAME, REGARDLESS of whether the pointer has moved or not, otherwise the body may get affected by external forces and drift away from the player's finger even if the pointer is stationary. CHECK: PERFORMANCE: Is there a better way to do this to improve performance?
        
        // ⚠️ BUG: 20180502A: If using touch, see comments for `TouchControlledPhysicsDraggingComponent.update(deltaTime:)`
        
        // ⚠️ BUG: 20180504B: APPLEBUG RADAR 39997859: If using touch, see comments for `TouchControlledPhysicsDraggingComponent.update(deltaTime:)`
        
        // CREDIT: https://stackoverflow.com/users/5190564/j-doe - https://stackoverflow.com/questions/31814741/spritekit-move-physics-body-on-pointer-air-hockey-game
        
        let seconds = CGFloat(seconds) // Cast only once instead of multiple times ahead.
        
        // CHECK: Is damping necessary? Should there be an option for it?
        //
        // let distance = node.position.distance(to: currentPointerLocation)
        // var damping = sqrt(distance / seconds)
        // if damping < 0 { damping = 0.0 }
        // physicsBody.linearDamping = damping
        // physicsBody.angularDamping = damping
        
        let translation = CGPoint(x: currentPointerLocation.x - node.position.x,
                                  y: currentPointerLocation.y - node.position.y)
        
        physicsBody.affectedByGravity = false // "Grab" the body so it stays under the player's finger.
        
        physicsBody.velocity = CGVector(dx: translation.x / seconds,
                                        dy: translation.y / seconds)
        
        self.isDragging = true
        
        // #6: Update the interaction state.
        
        // ℹ️ After the node moves, the state of the `NodePointerStateComponent` may no longer be correct. e.g. if the pointer moves too fast, it may be outside the node's bounds, so the state will be `pointingOutside`. When this component moves the node to the pointer's location, the state should be restored back to `pointing`, so that other components which are affected by `NodePointerStateComponent` can function correctly, e.g. so they don't show a `pointingOutside` behavior or visual effect for a single frame.
        
        // ℹ️ When the user performs a dragging operation, a "tap" operation is not expected, so we will instruct the `NodePointerStateComponent` to not enter a `tapped` or `endedOutside` state when the user lifts the pointer after moving the node.
        
        // CHECK: Should this suppression of taps be optional? Should it depend on whether the node has moved from its initial position?
        
        nodePointerStateComponent.updateState(
            suppressStateChangedFlag: false,
            suppressTappedState: true,
            suppressCancelledState: true)
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        releaseBody()
    }
    
    private func releaseBody() {
        guard let physicsBody = coComponent(ofType: PhysicsComponent.self)?.physicsBody else { return }
        physicsBody.affectedByGravity = true
        self.isDragging = false
    }
}
