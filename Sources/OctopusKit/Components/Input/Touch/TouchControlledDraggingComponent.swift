//
//  TouchControlledDraggingComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Enforce `isUserInteractionEnabled`?

// CHECKED: This component works whether the `TouchEventComponent` is added to a sprite entity or the scene entity (via a `RelayComponent`) :)

// CHECK: Add a `force` option?
// CHECK: Add an optional "dead zone" radius tolerance?
// CHECK: Behavior on physics bodies.

// TODO: Camera movement support

// TODO: BUG: Fix multitouch handling even if not tracking multiple touches. (BUG 20180504B)

// PERFORMANCE: May need optimization?

// 💬 It's possible to make the node move only when the touch moves out through its edges, by writing:
//
//  let nodePositionAndCenterDelta = node.position - node.frame.center
//  node.position = (currentTouchLocation - initialNodeCenterAndTouchPositionDelta) + nodePositionAndCenterDelta
//
//  But that does not make the touch be able to move around inside the node again without moving it. This could be a technique to improve and use for something else.

import SpriteKit
import GameplayKit

#if os(iOS)

/// Allows the player to drag the entity's `SpriteKitComponent` node based on input from the entity's `NodeTouchComponent`.
///
/// **Dependencies:** `SpriteKitComponent`, `NodeTouchComponent`
public final class TouchControlledDraggingComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                NodeTouchComponent.self]
    }
    
    /// Stores the initial position of the node, to compare against the `TouchStateComponent`'s translation over time.
    private var initialNodePosition: CGPoint?
    
    /// If `true`, the node is only moved to the touch's location when the touch moves, i.e. the touch's timestamp delta is greater than 0, but the node will drift away from the touch when the camera or the node's parent moves.
    ///
    /// If `false`, the node's location is always updated to match the touch's location, even if the touch is stationary. This produced the correct and expected visual behavior in cases such as a moving camera, but may decrease performance.
    public var onlyMoveWhenTouchTimestampChanges: Bool = true
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #1: Do we have a node, a scene, and are we tracking a touch?
        
        guard
            let node = self.entityNode,
            let scene = node.scene,
            let nodeTouchComponent = coComponent(NodeTouchComponent.self),
            let trackedTouch = nodeTouchComponent.trackedTouch
            else {
                initialNodePosition = nil
                return
        }
        
        let currentTouchLocation = trackedTouch.location(in: scene) // Used for debugging log and ahead.
        
        #if LOGINPUT
        let previousTouchLocation = trackedTouch.previousLocation(in: scene)
        let touchLocationDelta = currentTouchLocation - previousTouchLocation
        debugLog("trackedTouch.location in scene: \(previousTouchLocation) → \(currentTouchLocation), delta: \(touchLocationDelta), translation: \(String(optional: nodeTouchComponent.touchTranslationInScene))")
        #endif
        
        // PERFORMANCE: Cache the states so that we don't have to query another class's property too much. CHECK: Should that be the job of the compiler?
        
        let currentTouchState = nodeTouchComponent.state
        let previousTouchState = nodeTouchComponent.previousState
        
        // #2: If we're in any state other than `ready` or `disabled`, then it means the touch may have moved, otherwise this component has nothing to do.
        
        guard currentTouchState != .ready || currentTouchState != .disabled else {
            initialNodePosition = nil
            return
        }
        
        // #3: Store the initial position of the node if the player just began touching it.
        
        if  initialNodePosition == nil,
            currentTouchState == .touching,
            previousTouchState == .ready // CHECK: for `disabled` too?
        {
            initialNodePosition = node.position
        }
        
        // #4.1: Are we tracking a touch?
        
        guard
            let initialNodePosition = self.initialNodePosition,
            let initialTouchLocationInScene = nodeTouchComponent.initialTouchLocationInScene
            else { return }
        
        // #4.2: Should we move the node only when tracked touch moves?
        
        // ℹ️ If the node is only moved when the touch moves, the node may drift away from the touch when the camera or the node's parent moves.
        
        // PERFORMANCE: If the node's location is always updated every frame regardless of the touch's movement, then the dragging operation will behave as expected, but it may decrease performance.
        
        if onlyMoveWhenTouchTimestampChanges {
            
            // ⚠️ Do NOT just compare `trackedTouch.location` with `trackedTouch.previousLocation`, because if the touches moves a short distance for one frame then remains stationary, there will always be a difference between `trackedTouch.location` and `trackedTouch.previousLocation`, causing the node to move even if the touch remains stationary. To prevent that, we only move the node if the `trackedTouch.timestamp` has mutated, by checking the `nodeTouchComponent.trackedTouchTimestampDelta`
            
            // BUG: 20180502C: APPLEBUG? `UITouch.phase: UITouch.UITouchPhase` does not seem to work for this situation, as it seems to be stuck on `stationary` case throughout the touch.
            
            guard nodeTouchComponent.trackedTouchTimestampDelta > 0 else { return }
        }
        
        // #5: Move the node.
        
        // ⚠️ BUG: 20180502A: APPLEBUG? `UITouch.location(in:)` and `UITouch.previousLocation(in:)` are sometimes not updated for many frames, causing a node to "jump" many pixels after 10 or so frames. Same issue with `preciseLocation(in:)` and `precisePreviousLocation(in:)`

        // ⚠️ BUG: 20180504B: APPLEBUG? `UITouch.location(in:)` and `UITouch.preciseLocation(in:)` for a touch "wobbles" when a 2nd touch moves near it, even if the tracked touch is stationary. ⚠️ Seems to be a problem on the iOS 11.3 on all devices, in all apps, like Photos.
    
        // ℹ️ Do not move the node by comparing the `location` and `previousLocation` of the touch. That does not seem to be accurate, and can cause "drifts" where the "pointer" ends up in a different point in the node than where it started touching the node, at least in the iOS Simulator. Instead, store the initial position of the node, then compare the initial position of the touch with its latest position, and directly set the node's position to the final translation. This works the same as the `translation` property of a `UIPanGestureRecognizer`: https://developer.apple.com/documentation/uikit/uipangesturerecognizer/1621207-translation
        
        // ℹ️ PERFORMANCE: Calculating the translation here should be faster than accessing the `NodeTouchComponent.touchTranslationInScene` computed property which checks for and unwraps a many optionals (node, scene, etc.)
        
        node.position = initialNodePosition + (currentTouchLocation - initialTouchLocationInScene)
        
        // #6: Update the interaction state.
        
        // ℹ️ After the node moves, the state of the `NodeTouchComponent` may no longer be correct. e.g. if the touch moves too fast, it may be outside the node's bounds, so the state will be `touchingOutside`. When this component moves the node to the touch's location, the state should be restored back to `touching`, so that other components which are affected by `NodeTouchComponent` can function correctly, e.g. so they don't show a `touchingOutside` behavior or visual effect for a single frame.
        
        // ℹ️ When the user performs a dragging operation, a "tap" operation is not expected, so we will instruct the `NodeTouchComponent` to not enter a `tapped` or `endedOutside` state when the user lifts the touch after moving the node.
        
        // CHECK: Should this suppression of taps be optional? Should we check if the node has moved from its initial position?
        
        nodeTouchComponent.updateState(
            suppressStateChangedFlag: false,
            suppressTappedState: true,
            suppressCancelledState: true)
    }
}

#else

public final class TouchControlledRepositioningComponent: iOSExclusiveComponent {}
    
#endif
