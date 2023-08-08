//
//  TouchControlledDraggingComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Enforce `isUserInteractionEnabled`?
// CHECK: Add an option for `force` sensitivity?
// CHECK: Add an option for "dead zone" radius tolerance?
// CHECK: Behavior on physics bodies.

// CHECKED: This component works whether the `TouchEventComponent` is added to a sprite entity or the scene entity (via a `RelayComponent`) :)

// TODO: BUG: Fix multitouch handling even if not tracking multiple touches. (BUG 20180504B, RADAR 39997859)
// TODO: FIX or WARN: Using `initialNodePosition` to determine the final position at the end of the dragging gesture does not account for changes in position by external forces during the gesture (e.g. physics.)

// PERFORMANCE: May need optimization?

// 💡💬 NOTE: It's possible to make the node move only when the touch moves out through its edges, by writing:
//
//  let nodePositionAndCenterDelta = node.position - node.frame.center
//  node.position = (currentTouchLocation - initialNodeCenterAndTouchPositionDelta) + nodePositionAndCenterDelta
//
//  But that does not make the touch be able to move around inside the node again without moving it. This could be a technique to improve and use for something else.

import SpriteKit
import GameplayKit

#if canImport(UIKit)

/// Allows the player to drag the entity's `NodeComponent` node based on input from the entity's `NodeTouchStateComponent`.
///
/// **Dependencies:** `NodeTouchStateComponent, NodeComponent`
@available(iOS 13.0, *)
public final class TouchControlledDraggingComponent: OKComponent, RequiresUpdatesPerFrame {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         NodeTouchStateComponent.self]
    }
    
    /// Stores the initial position of the node to compare against the `TouchStateComponent`'s translation over time.
    private var initialNodePosition: CGPoint?
    
    /// If `true`, which is the default, the node is only moved to the touch's location when the touch moves, i.e. when the touch's timestamp delta is greater than `0`, but the node will drift away from the touch when the camera or the node's parent moves.
    ///
    /// If `false`, the node's location is always updated to match the touch's location, even if the touch is stationary. This produced the correct and expected behavior in cases such as a moving camera, but may decrease performance.
    public var onlyMoveWhenTouchTimestampChanges: Bool = true
    
    @LogInputEventChanges(propertyName: "TouchControlledDraggingComponent.isDragging")
    public var isDragging: Bool = false
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // A scene itself is not really draggable, so...
        
        if  node is SKScene {
            OKLog.logForWarnings.debug("\(📜("A TouchControlledDraggingComponent cannot be added to the scene entity — Removing."))")
            OKLog.logForTips.debug("\(📜("See CameraPanComponent."))")
            self.removeFromEntity()
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #1: Make sure we have a node, that has a parent, and a touch is being tracked.
        
        guard
            let node   = self.entity?.node,
            let parent = node.parent,
            let nodeTouchStateComponent = coComponent(NodeTouchStateComponent.self),
            let trackedTouch = nodeTouchStateComponent.trackedTouch
            else {
                initialNodePosition = nil
                isDragging = false
                return
        }
        
        // PERFORMANCE: Cache the touch component's properties locally so that we don't have to query another class's properties too much. CHECK: Should this be the job of the compiler?
        
        let currentTouchLocation = trackedTouch.location(in: parent)
        
        #if LOGINPUTEVENTS
        let previousTouchLocation = trackedTouch.previousLocation(in: parent)
        let touchLocationDelta = currentTouchLocation - previousTouchLocation
        debugLog("trackedTouch.location in node parent: \(previousTouchLocation) → \(currentTouchLocation), delta: \(touchLocationDelta), translation: \(nodeTouchStateComponent.touchTranslationInParent)")
        #endif
        
        let currentTouchState  = nodeTouchStateComponent.state
        let previousTouchState = nodeTouchStateComponent.previousState
        
        // #2: If we're in any state other than `ready` or `disabled`, then it means the touch may have moved, otherwise this component has nothing to do.
        
        guard currentTouchState != .ready || currentTouchState != .disabled else {
            initialNodePosition = nil
            return
        }
        
        // #3: Store the initial position of the node if the player just began touching it.
        
        if  self.initialNodePosition == nil,
            currentTouchState  == .touching,
            previousTouchState == .ready // CHECK: for `disabled` too?
        {
            self.initialNodePosition = node.position
        }
        
        // #4.1: Are we tracking a touch?
        
        guard
            let initialNodePosition = self.initialNodePosition,
            let initialTouchLocationInParent = nodeTouchStateComponent.initialTouchLocationInParent
            else { return }
        
        // #4.2: Should we move the node only when tracked touch moves?
        
        // ℹ️ If the node is only moved when the touch moves, the node may drift away from the touch when the camera or the node's parent moves, because this component will not reposition the node to the touch's position.
        
        // PERFORMANCE: If the node's location is always updated every frame regardless of the touch's movement, then the dragging operation will behave as expected, but it may decrease performance.
        
        if onlyMoveWhenTouchTimestampChanges {
            
            // ℹ️ NOTE: Do NOT compare `trackedTouch.location` with `trackedTouch.previousLocation`, because if the touch moves a short distance for one frame then remains stationary, there will always be a difference between `trackedTouch.location` and `trackedTouch.previousLocation`, causing the node to move even if the touch remains stationary. To prevent that, we only move the node if the `trackedTouch.timestamp` has mutated, by checking the `nodeTouchComponent.trackedTouchTimestampDelta`
            
            // BUG: 20180502C: APPLEBUG? `UITouch.phase: UITouch.UITouchPhase` does not seem to work for this situation, as it seems to report an `stationary` case by the time this component is updated.
            
            guard nodeTouchStateComponent.trackedTouchTimestampDelta > 0 else { return }
        }
        
        // #5: Reposition the node.
        
        // ⚠️ BUG: 20180502A: APPLEBUG? `UITouch.location(in:)` and `UITouch.previousLocation(in:)` are sometimes not updated for many frames, causing a node to remain stationary for 10 or so frames before "jumping" many pixels in one frame. Same issue with `preciseLocation(in:)` and `precisePreviousLocation(in:)`

        // ⚠️ BUG: 20180504B: APPLEBUG RADAR 39997859: `UITouch.location(in:)` and `UITouch.preciseLocation(in:)` for a touch "wobbles" when a 2nd touch moves near it, even if the tracked touch is stationary. ⚠️ Seems to be a problem since iOS 11.3 on all devices, in all apps, including system apps like Photos.
    
        // ℹ️ NOTE: Do not move the node by comparing the `location` and `previousLocation` of the touch. That does not seem to be accurate, and can cause "drifts" where the "pointer" ends up in a different point in the node than where it started touching the node, at least in the iOS Simulator. Instead, store the initial position of the node, then compare the initial position of the touch with its latest position, and directly set the node's position to the final translation. This works the same way as the `translation` property of a `UIPanGestureRecognizer`: https://developer.apple.com/documentation/uikit/uipangesturerecognizer/1621207-translation
        
        // ℹ️ PERFORMANCE: Calculating the translation here should be faster than accessing the `NodeTouchStateComponent.touchTranslationInParent` computed property which checks for and unwraps many optionals (node, parent, etc.)
        
        node.position = initialNodePosition + (currentTouchLocation - initialTouchLocationInParent)
        isDragging = true
        
        // #6: Update the interaction state.
        
        // ℹ️ After the node moves, the state of the `NodeTouchStateComponent` may no longer be correct. e.g. if the touch moves too fast, it may be outside the node's bounds, so the state will be `touchingOutside`. When this component moves the node to the touch's location, the state should be restored back to `touching`, so that other components which are affected by `NodeTouchStateComponent` can function correctly, e.g. so they don't show a `touchingOutside` behavior or visual effect for a single frame.
        
        // ℹ️ When the user performs a dragging operation, a "tap" operation is not expected, so we will instruct the `NodeTouchStateComponent` to not enter a `tapped` or `endedOutside` state when the user lifts the touch after moving the node.
        
        // CHECK: Should this suppression of taps be optional? Should it depend on whether the node has moved from its initial position?
        
        nodeTouchStateComponent.updateState(
            suppressStateChangedFlag: false,
            suppressTappedState: true,
            suppressCancelledState: true)
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        self.initialNodePosition = nil
        self.isDragging = false
    }
}

#endif

#if !canImport(UIKit)
@available(macOS, unavailable, message: "Use PointerControlledDraggingComponent")
public final class TouchControlledDraggingComponent: iOSExclusiveComponent {}
#endif
