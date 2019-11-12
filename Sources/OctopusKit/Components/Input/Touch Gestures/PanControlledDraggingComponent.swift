//
//  PanControlledDraggingComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/216.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Fix for very fast touches.
// TODO: Inertial movement.
// TODO: FIX or WARN: Using `initialNodePosition` to determine the final position at the end of the dragging gesture does not account for changes in position by external forces during the gesture (e.g. physics.
// CHECK: Enforce `isUserInteractionEnabled`?
// CHECK: Behavior on physics bodies.
// PERFORMANCE: May need optimization?

// ⚠️ NOTE: For single touches, this seems to be a poor alternative to `TouchControlledDraggingComponent`, as the pan gesture recognizer begins around 7 frames after the first `touchesBegan` event is received by the `TouchEventComponent`, at least in the iOS Simulator. This component should probably be only used for multi-touch dragging.

// ℹ️ NOTE: For the above reason, we HAVE to use a `NodeTouchStateComponent` to get the initial touch and location.

import SpriteKit
import GameplayKit

#if os(iOS)

/// Drags the entity's `SpriteKitComponent` node based on input from the entity's `NodeTouchStateComponent` and `PanGestureRecognizerComponent`.
///
/// **Dependencies:** `NodeTouchStateComponent, PanGestureRecognizerComponent, SpriteKitComponent`
public final class PanControlledDraggingComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public static let inertialMovementKey = "OctopusKit.PanControlledDraggingComponent.Move"
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                NodeTouchStateComponent.self,
                PanGestureRecognizerComponent.self]
    }
    
    /// The minimum number of touches for a pan gesture to be processed.
    ///
    /// - NOTE: This value is distinct from the `minimumNumberOfTouches` property of the `UIPanGestureRecognizer` so that each `PanControlledRepositioningComponent` may specify its own minimum.
    ///
    /// - IMPORTANT: The `UIPanGestureRecognizer` will only register gestures that meet its own `minimumNumberOfTouches` property.
    public var minimumNumberOfTouches: Int
    
    public var isPaused: Bool = false
    
    public var isDragging: Bool = false {
        didSet {
            #if LOGINPUTEVENTS
            if isDragging != oldValue { debugLog("= \(oldValue) → \(isDragging)") }
            #endif
        }
    }
    
    /// If `true`, the node will slide for a distance depending on the panning velocity at the end of the gesture.
    public var isInertialScrollingEnabled: Bool
    
    private var initialNodePosition: CGPoint? {
        didSet {
            #if LOGINPUTEVENTS
            if initialNodePosition != oldValue { debugLog("= \(oldValue) → \(initialNodePosition)") }
            #endif
        }
    }
    
    private var newNodePosition: CGPoint? {
        didSet {
            #if LOGINPUTEVENTS
            if newNodePosition != oldValue { debugLog("= \(oldValue) → \(newNodePosition)") }
            #endif
        }
    }
    
    /// A flag that indicates whether there is a gesture to process for the `update(deltaTime:)` method.
    ///
    /// This prevents the component from responding to asynchronous events (such as player input) outside of the frame update cycle.
    private var haveGestureToProcess: Bool = false {
        didSet {
            #if LOGINPUTEVENTS
            if haveGestureToProcess != oldValue { debugLog("= \(oldValue) → \(haveGestureToProcess)") }
            #endif
        }
    }
    
    // MARK: -
    
    public init(minimumNumberOfTouches: Int = 1,
                isInertialScrollingEnabled: Bool = false)
    {
        self.minimumNumberOfTouches = minimumNumberOfTouches
        self.isInertialScrollingEnabled = isInertialScrollingEnabled
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let panGestureRecognizer = coComponent(PanGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        panGestureRecognizer.addTarget(self, action: #selector(gestureEvent))
    }

    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // A scene itself is not really draggable, so...
        
        if node is SKScene {
            OctopusKit.logForWarnings.add("A PanControlledDraggingComponent cannot be added to the scene entity — Removing.")
            OctopusKit.logForTips.add("See CameraPanComponent.")
            self.removeFromEntity()
        }
    }
    
    @objc fileprivate func gestureEvent(panGestureRecognizer: UIPanGestureRecognizer) {
        
        // ℹ️ This component performs its function inside the `update(deltaTime:)` method, and just uses this event-handling action method to mark a flag to denote that an event was received. This prevents the component from being active outside the frame-update cycle, or when it's [temporarily] removed from the entity or the scene's systems.
        
        // ℹ️ DESIGN: Do not confirm if the `tapGestureRecognizer` that sent this event is the same `TapGestureRecognizerComponent` that is associated with this entity, in case this component may have been explicitly made the target of some other gesture recognizer, and that is allowed in the name of flexible customizability.
        
        // ℹ️ Just check the minimim requirements for a gesture to be processed here. The `update(deltaTime:)` method should also check the relevant conditions because they may change between this event handler and the update method.
        
        guard
            !isPaused,
            panGestureRecognizer.numberOfTouches >= self.minimumNumberOfTouches,
            let view = self.entityNode?.scene?.view
            else { return }
        
        haveGestureToProcess = true
        
        if let initialNodePosition = self.initialNodePosition {
            
            // ℹ️ Do not convert to scene coordinates, as that may not report the correct translation of the touch on the screen when the underlying scene/camera is panned etc.
            
            var translation = panGestureRecognizer.translation(in: view)
            translation.y = -translation.y // A UIKit view's coordinate system (Y increases downward) is different from the SpriteKit coordinate system (Y increases upward). So we have to "fix" the Y axis.
            
            newNodePosition = initialNodePosition + translation
        }
        
        if panGestureRecognizer.state == .ended {
            initialNodePosition = nil
            isDragging = false
        }
        
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            !isPaused,
            let node = self.entityNode,
            let parent = node.parent,
            let nodeTouchComponent = coComponent(NodeTouchStateComponent.self),
            let trackedTouch = nodeTouchComponent.trackedTouch
            else {
                initialNodePosition = nil
                newNodePosition = nil
                isDragging = false
                return
        }
        
        #if LOGINPUTEVENTS
        let currentTouchLocation = trackedTouch.location(in: parent)
        let previousTouchLocation = trackedTouch.previousLocation(in: parent)
        let touchLocationDelta = currentTouchLocation - previousTouchLocation
        debugLog("trackedTouch.location in parent: \(previousTouchLocation) → \(currentTouchLocation), delta: \(touchLocationDelta), translation: \(nodeTouchComponent.touchTranslationInParent)")
        #endif
        
        // PERFORMANCE: Cache the touch component's properties locally so that we don't have to query another class's properties too much. CHECK: Should this be the job of the compiler?
        
        let currentTouchState = nodeTouchComponent.state
        let previousTouchState = nodeTouchComponent.previousState
        
        // #1: If we're in any state other than `ready` or `disabled`, then it means the touch may have moved, otherwise this component has nothing to do.
        
        guard currentTouchState != .ready || currentTouchState != .disabled else {
            initialNodePosition = nil
            newNodePosition = nil
            isDragging = false
            return
        }
        
        // #2: Store the initial position of the node if the player just began touching it.
        
        if  initialNodePosition == nil,
            currentTouchState == .touching,
            previousTouchState == .ready // CHECK: for `disabled` too?
        {
            initialNodePosition = node.position
        }
        
        // #3: Do we have a new position to move to? This is set by the gesture event handler.
        
        guard let newNodePosition = self.newNodePosition else { return }
        
        node.position = newNodePosition
        isDragging = true
        
        // #4: Update the interaction state.
        
        // ℹ️ After the node moves, the state of the `NodeTouchStateComponent` may no longer be correct. e.g. if the touch moves too fast, it may be outside the node's bounds, so the state will be `touchingOutside`. When this component moves the node to the touch's location, the state should be restored back to `touching`, so that other components which are affected by `NodeTouchStateComponent` can function correctly, e.g. so they don't show a `touchingOutside` behavior or visual effect for a single frame.
        
        // ℹ️ When the user performs a dragging operation, a "tap" operation is not expected, so we will instruct the `NodeTouchStateComponent` to not enter a `tapped` or `endedOutside` state when the user lifts the touch after moving the node.
        
        // CHECK: Should this suppression of taps be optional? Should it depend on whether the node has moved from its initial position?
        
        // ⚠️ NOTE: The `PanControlledDraggingComponent` will supress taps and cancles only if there has actually been a pan gesture; otherwise the `NodeTouchStateComponent` will still report taps if the player taps on the node without panning the node, because this code will not be called in the absence of a pan event.
        
        nodeTouchComponent.updateState(
            suppressStateChangedFlag: false,
            suppressTappedState: true,
            suppressCancelledState: true)
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        // Remove this component from the gesture notification targets.
        
        guard let panGestureRecognizer = coComponent(PanGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        panGestureRecognizer.removeTarget(self, action: #selector(gestureEvent)) // CHECK: Should `action` be `nil`?
        
        // Reset flags.
        
        self.haveGestureToProcess = false
        self.initialNodePosition = nil
        self.newNodePosition = nil
        self.isDragging = false
    }
}

#else

public final class PanControlledRepositioningComponent: iOSExclusiveComponent {}
    
#endif
