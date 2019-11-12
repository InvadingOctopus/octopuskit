//
//  TouchControlledImpulseComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/07/07.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Improve physics?
// CHECK: Add options for customizing the behavior?
// PERFORMANCE: May need optimization.

import SpriteKit
import GameplayKit

#if os(iOS)

/// Allows the player to drag the entity's `PhysicsComponent` body based on input from the entity's `NodeTouchStateComponent`.
///
/// - Prevents the body from being affected by gravity while it is being held.
/// - Modifies the body's velocity.
///
/// **Dependencies:** `NodeTouchStateComponent, PhysicsComponent.self, SpriteKitComponent`
public final class TouchControlledPhysicsDraggingComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // ℹ️ DESIGN: Not pinning to the specific point of touch, because that would be inconvenient for the user to control on a [small] touchscreen, and also seems like overkill in the amount of code it takes and the temporary node it needs to create, as well as likely impacting performance.
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                PhysicsComponent.self,
                NodeTouchStateComponent.self]
    }
    
    @LogInputEventChanges public var isDragging: Bool = false
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // A scene itself is not really draggable, so...
        
        if node is SKScene {
            OctopusKit.logForWarnings.add("A TouchControlledPhysicsDraggingComponent cannot be added to the scene entity — Removing.")
            OctopusKit.logForTips.add("See CameraPanComponent.")
            self.removeFromEntity()
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #1: Make sure we have a node, that has a parent and a physics body, and a touch is being tracked.
        
        // If the touch is in any state other than `ready` or `disabled`, then it means the touch may have moved, otherwise this component has nothing to do.
        
        guard
            let node = self.entityNode,
            let parent = node.parent,
            let physicsBody = coComponent(ofType: PhysicsComponent.self)?.physicsBody,
            let nodeTouchComponent = coComponent(NodeTouchStateComponent.self),
            nodeTouchComponent.state != .ready || nodeTouchComponent.state != .disabled,
            let trackedTouch = nodeTouchComponent.trackedTouch
            else {
                releaseBody()
                return
        }
        
        // PERFORMANCE: Cache the touch component's properties locally so that we don't have to query another class's properties too much. CHECK: Should this be the job of the compiler?
        
        let currentTouchLocation = trackedTouch.location(in: parent)
        
        #if LOGINPUTEVENTS
        let previousTouchLocation = trackedTouch.previousLocation(in: parent)
        let touchLocationDelta = currentTouchLocation - previousTouchLocation
        debugLog("trackedTouch.location in parent: \(previousTouchLocation) → \(currentTouchLocation), delta: \(touchLocationDelta), translation: \(nodeTouchComponent.touchTranslationInParent)")
        #endif
        
        // #2: Move the node's physics body.
        
        // ℹ️ NOTE: We have to move the body to the touched position in EVERY FRAME, REGARDLESS of whether the touch has moved or not, otherwise the body may get affected by external forces and drift away from the player's finger even if the touch is stationary. CHECK: PERFORMANCE: Is there a better way to do this to improve performance?
        
        // ⚠️ BUG: 20180502A: APPLEBUG? `UITouch.location(in:)` and `UITouch.previousLocation(in:)` are sometimes not updated for many frames, causing a node to remain stationary for 10 or so frames before "jumping" many pixels in one frame. Same issue with `preciseLocation(in:)` and `precisePreviousLocation(in:)`
        
        // ⚠️ BUG: 20180504B: APPLEBUG RADAR 39997859: `UITouch.location(in:)` and `UITouch.preciseLocation(in:)` for a touch "wobbles" when a 2nd touch moves near it, even if the tracked touch is stationary. ⚠️ Seems to be a problem since iOS 11.3 on all devices, in all apps, including system apps like Photos.
        
        // CREDIT: https://stackoverflow.com/users/5190564/j-doe - https://stackoverflow.com/questions/31814741/spritekit-move-physics-body-on-touch-air-hockey-game
        
        let seconds = CGFloat(seconds) // Cast only once instead of multiple times ahead.
        
        // CHECK: Is damping necessary? Should there be an option for it?
        //
        // let distance = node.position.distance(to: currentTouchLocation)
        // var damping = sqrt(distance / seconds)
        // if damping < 0 { damping = 0.0 }
        // physicsBody.linearDamping = damping
        // physicsBody.angularDamping = damping
        
        let translation = CGPoint(x: currentTouchLocation.x - node.position.x,
                                  y: currentTouchLocation.y - node.position.y)
        
        physicsBody.affectedByGravity = false // "Grab" the body so it stays under the player's finger.
        
        physicsBody.velocity = CGVector(dx: translation.x / seconds,
                                        dy: translation.y / seconds)
        
        self.isDragging = true
        
        // #6: Update the interaction state.
        
        // ℹ️ After the node moves, the state of the `NodeTouchStateComponent` may no longer be correct. e.g. if the touch moves too fast, it may be outside the node's bounds, so the state will be `touchingOutside`. When this component moves the node to the touch's location, the state should be restored back to `touching`, so that other components which are affected by `NodeTouchStateComponent` can function correctly, e.g. so they don't show a `touchingOutside` behavior or visual effect for a single frame.
        
        // ℹ️ When the user performs a dragging operation, a "tap" operation is not expected, so we will instruct the `NodeTouchStateComponent` to not enter a `tapped` or `endedOutside` state when the user lifts the touch after moving the node.
        
        // CHECK: Should this suppression of taps be optional? Should it depend on whether the node has moved from its initial position?
        
        nodeTouchComponent.updateState(
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

#endif

#if !canImport(UIKit)
public final class TouchControlledImpulseComponent: iOSExclusiveComponent {}
#endif
