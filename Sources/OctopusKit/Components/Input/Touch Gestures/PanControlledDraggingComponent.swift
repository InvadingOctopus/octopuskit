//
//  PanControlledDraggingComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/216.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Fix for very fast touches.
// TODO: Inertial movement.
// CHECK: Enforce `isUserInteractionEnabled`?
// CHECK: Behavior on physics bodies.
// PERFORMANCE: May need optimization.

// ⚠️ NOTE: For single touches, this seems to be a poor alternative to `TouchControlledDraggingComponent`, as the pan gesture recognizer begins around 7 frames after the first `touchesBegan` event is received by the `TouchEventComponent`, at least in the iOS Simulator. This component should probably be only used for multi-touch dragging.

// ⚠️ NOTE: For the above reason, we HAVE to use a `NodeTouchComponent` to get the initial touch and location.

import SpriteKit
import GameplayKit

#if os(iOS)

/// Drags the entity's `SpriteKitComponent` node based on input from the entity's `NodeTouchComponent` and `PanGestureRecognizerComponent`.
///
/// **Dependencies:** `NodeTouchComponent, PanGestureRecognizerComponent, SpriteKitComponent`
public final class PanControlledDraggingComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public static let inertialMovementKey = "OctopusKit.PanControlledDraggingComponent.Move"
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                NodeTouchComponent.self,
                PanGestureRecognizerComponent.self]
    }
    
    /// The minimum number of touches for a pan gesture to be processed.
    ///
    /// - NOTE: This value is distinct from the `minimumNumberOfTouches` property of the `UIPanGestureRecognizer` so that each `PanControlledRepositioningComponent` may specify its own minimum.
    ///
    /// - IMPORTANT: The `UIPanGestureRecognizer` will only register gestures that meet its own `minimumNumberOfTouches` property.
    public var minimumNumberOfTouches: Int
    
    public var isPaused: Bool = false
    
    /// If `true`, the node will slide for a distance depending on the panning velocity at the end of the gesture.
    public var isInertialScrollingEnabled: Bool
    
    private var initialNodePosition: CGPoint? {
        didSet {
            #if LOGINPUT
            if initialNodePosition != oldValue { debugLog("\(String(optional: oldValue)) → \(String(optional: initialNodePosition))") }
            #endif
        }
    }
    
    private var newNodePosition: CGPoint? {
        didSet {
            #if LOGINPUT
            if newNodePosition != oldValue { debugLog("\(String(optional: oldValue)) → \(String(optional: newNodePosition))") }
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

    @objc fileprivate func gestureEvent(panGestureRecognizer: UIPanGestureRecognizer) {
        
        // ℹ️ This component performs its function inside the `update(deltaTime:)` method, and just uses this event-handling action method to mark a flag to denote that an event was received. This prevents the component from being active outside the frame-update cycle, or when it's [temporarily] removed from the entity or the scene's systems.
        
        // ℹ️ DESIGN: Do not confirm if the `tapGestureRecognizer` that sent this event is the same `TapGestureRecognizerComponent` that is associated with this entity, in case this component may have been explicitly made the target of some other gesture recognizer, and that is allowed in the name of flexible customizability.
        
        // ℹ️ Just check the minimim requirements for a gesture to be processed here; e.g. that the gesture is inside our node, so other nodes don't needlessly set their flags. The `update(deltaTime:)` method should also check the relevant conditions because they may change between this event handler and the update method.
        
        //guard panGestureRecognizer.numberOfTouches >= self.minimumNumberOfTouches else { return }
        
        guard
            !isPaused,
            let node = entityNode,
            let scene = node.scene,
            let view = scene.view,
            let initialNodePosition = self.initialNodePosition,
            panGestureRecognizer.numberOfTouches >= self.minimumNumberOfTouches
            else { return }

        // ℹ️ Don't convert to scene coordinates.
        var translation = panGestureRecognizer.translation(in: view) // See comment about coordinate systems and axis inversion above.
        translation.y = -translation.y
        
        newNodePosition = initialNodePosition + translation

        if panGestureRecognizer.state == .ended {
            self.initialNodePosition = nil
        }
        
    }
    
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
        
        #if LOGINPUT
        let currentTouchLocation = trackedTouch.location(in: scene)
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
        
        // #4.1: Do we have a new position to move to?
        
        guard let newNodePosition = self.newNodePosition else { return }
        
        node.position = newNodePosition
        
        // #6: Update the interaction state.
        
        // ℹ️ After the node moves, the state of the `NodeTouchComponent` may no longer be correct. e.g. if the touch moves too fast, it may be outside the node's bounds, so the state will be `touchingOutside`. When this component moves the node to the touch's location, the state should be restored back to `touching`, so that other components which are affected by `NodeTouchComponent` can function correctly, e.g. so they don't show a `touchingOutside` behavior or visual effect for a single frame.
        
        // ℹ️ When the user performs a dragging operation, a "tap" operation is not expected, so we will instruct the `NodeTouchComponent` to not enter a `tapped` or `endedOutside` state when the user lifts the touch after moving the node.
        
        // CHECK: Should this suppression of taps be optional? Should we check if the node has moved from its initial position?
        
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
    }
}

#else

public final class PanControlledRepositioningComponent: iOSExclusiveComponent {}
    
#endif
