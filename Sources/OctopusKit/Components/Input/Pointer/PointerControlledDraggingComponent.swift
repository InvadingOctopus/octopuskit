//
//  PointerControlledDraggingComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/14.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Enforce `isUserInteractionEnabled`?
// CHECK: Add an option for `force` sensitivity?
// CHECK: Add an option for "dead zone" radius tolerance?
// CHECK: Behavior on physics bodies.

// CHECKED: This component works whether the `PointerEventComponent` is added to a sprite entity or the scene entity (via a `RelayComponent`) :)

// TODO: FIX or WARN: Using `initialNodePosition` to determine the final position at the end of the dragging gesture does not account for changes in position by external forces during the gesture (e.g. physics.)
// TODO: Verify documentation and comments that were copied from TouchControlledDraggingComponent but are not relevant here.

// PERFORMANCE: May need optimization?

// 💡💬 NOTE: It's possible to make the node move only when the pointer moves out through its edges, by writing:
//
//  let nodePositionAndCenterDelta = node.position - node.frame.center
//  node.position = (currentPointerLocation - initialNodeCenterAndPointerPositionDelta) + nodePositionAndCenterDelta
//
//  But that does not make the pointer be able to move around inside the node again without moving it. This could be a technique to improve and use for something else.

import OctopusCore
import SpriteKit
import GameplayKit

/// Allows the player to drag the entity's `NodeComponent` node based on input from the entity's `NodePointerStateComponent`.
///
/// **Dependencies:** `NodePointerStateComponent, NodeComponent`
public final class PointerControlledDraggingComponent: OKComponent, RequiresUpdatesPerFrame {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         NodePointerStateComponent.self]
    }
    
    /// Stores the initial position of the node to compare against the `PointerStateComponent`'s translation over time.
    private var initialNodePosition: CGPoint?
    
    /// If `true`, which is the default, the node is only moved to the pointer's location when the pointer moves, i.e. when the pointer's timestamp delta is greater than `0`, but the node will drift away from the pointer when the camera or the node's parent moves.
    ///
    /// If `false`, the node's location is always updated to match the pointer's location, even if the pointer is stationary. This produced the correct and expected behavior in cases such as a moving camera, but may decrease performance.
    public var onlyMoveWhenPointerTimestampChanges: Bool = true
    
    @LogInputEventChanges(propertyName: "PointerControlledDraggingComponent.isDragging")
    public var isDragging: Bool = false
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // A scene itself is not really draggable, so...
        
        if  node is SKScene {
            OKLog.logForWarnings.debug("A PointerControlledDraggingComponent cannot be added to the scene entity — Removing.")
            OctopusKit.logForTips ("See CameraPanComponent")
            self.removeFromEntity()
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #1: Make sure we have a node, that has a parent, and a pointer is being tracked.
        
        guard
            let node = self.entityNode,
            let parent = node.parent,
            let nodePointerStateComponent = coComponent(NodePointerStateComponent.self),
            let latestEvent = nodePointerStateComponent.latestEventForCurrentFrame
            else {
                initialNodePosition = nil
                isDragging = false
                return
        }
        
        // PERFORMANCE: Cache the pointer component's properties locally so that we don't have to query another class's properties too much. CHECK: Should this be the job of the compiler?
        
        let currentPointerLocation = latestEvent.location(in: parent)
        
        #if LOGINPUTEVENTS
        let previousPointerLocation = nodePointerStateComponent.previousEvent?.location(in: parent) ?? currentPointerLocation // Instead of `CGPoint.zero` so we don't report a false delta for the first event in a sequence.
        let pointerLocationDelta    = currentPointerLocation - previousPointerLocation
        debugLog("latestEventForCurrentFrame.location in node parent: \(previousPointerLocation) → \(currentPointerLocation), delta: \(pointerLocationDelta), translation: \(nodePointerStateComponent.pointerTranslationInParent)")
        #endif
        
        let currentPointerState  = nodePointerStateComponent.state
        let previousPointerState = nodePointerStateComponent.previousState
        
        // #2: If we're in any state other than `ready` or `disabled`, then it means the pointer may have moved, otherwise this component has nothing to do.
        
        guard currentPointerState != .ready || currentPointerState != .disabled else {
            initialNodePosition = nil
            return
        }
        
        // #3: Store the initial position of the node if the player just began pointing it.
        
        if  self.initialNodePosition == nil,
            currentPointerState      == .pointing,
            previousPointerState     == .ready // CHECK: for `disabled` too?
        {
            self.initialNodePosition = node.position
        }
        
        // #4.1: Are we tracking a pointer?
        
        guard
            let initialNodePosition = self.initialNodePosition,
            let initialPointerLocationInParent = nodePointerStateComponent.initialPointerLocationInParent
            else { return }
        
        // #4.2: Should we move the node only when tracked pointer moves?
        
        // ℹ️ If the node is only moved when the pointer moves, the node may drift away from the pointer when the camera or the node's parent moves, because this component will not reposition the node to the pointer's position.
        
        // PERFORMANCE: If the node's location is always updated every frame regardless of the pointer's movement, then the dragging operation will behave as expected, but it may decrease performance.
        
        if onlyMoveWhenPointerTimestampChanges {
            
            // ℹ️ NOTE: Do NOT compare `trackedPointer.location` with `trackedPointer.previousLocation`, because if the pointer moves a short distance for one frame then remains stationary, there will always be a difference between `trackedPointer.location` and `trackedPointer.previousLocation`, causing the node to move even if the pointer remains stationary. To prevent that, we only move the node if the `trackedPointer.timestamp` has mutated, by checking the `nodePointerComponent.trackedPointerTimestampDelta`
            
            // BUG: 20180502C: APPLEBUG? `UIPointer.phase: UIPointer.UIPointerPhase` does not seem to work for this situation, as it seems to report an `stationary` case by the time this component is updated.
            
            guard nodePointerStateComponent.timestampDelta > 0 else { return }
        }
        
        // #5: Reposition the node.
        
        // ⚠️ BUG: 20180502A: APPLEBUG? If using touch, see comments for `TouchControlledDraggingComponent.update(deltaTime:)`

        // ⚠️ BUG: 20180504B: APPLEBUG RADAR 39997859: If using touch, see comments for `TouchControlledDraggingComponent.update(deltaTime:)`
    
        // ℹ️ NOTE: Do not move the node by comparing the `location` and `previousLocation` of the pointer. That does not seem to be accurate, and can cause "drifts" where the "pointer" ends up in a different point in the node than where it started pointing the node, at least in the iOS Simulator. Instead, store the initial position of the node, then compare the initial position of the pointer with its latest position, and directly set the node's position to the final translation. This works the same way as the `translation` property of a `UIPanGestureRecognizer`: https://developer.apple.com/documentation/uikit/uipangesturerecognizer/1621207-translation
        
        // ℹ️ PERFORMANCE: Calculating the translation here should be faster than accessing the `NodePointerStateComponent.pointerTranslationInParent` computed property which checks for and unwraps many optionals (node, parent, etc.)
        
        node.position = initialNodePosition + (currentPointerLocation - initialPointerLocationInParent)
        isDragging = true
        
        // #6: Update the interaction state.
        
        // ℹ️ After the node moves, the state of the `NodePointerStateComponent` may no longer be correct. e.g. if the pointer moves too fast, it may be outside the node's bounds, so the state will be `pointingOutside`. When this component moves the node to the pointer's location, the state should be restored back to `pointing`, so that other components which are affected by `NodePointerStateComponent` can function correctly, e.g. so they don't show a `pointingOutside` behavior or visual effect for a single frame.
        
        // ℹ️ When the user performs a dragging operation, a "tap" operation is not expected, so we will instruct the `NodePointerStateComponent` to not enter a `tapped` or `endedOutside` state when the user lifts the pointer after moving the node.
        
        // CHECK: Should this suppression of taps be optional? Should it depend on whether the node has moved from its initial position?
        
        nodePointerStateComponent.updateState(
            suppressStateChangedFlag: false,
            suppressTappedState:      true,
            suppressCancelledState:   true)
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        self.initialNodePosition = nil
        self.isDragging = false
    }
}
