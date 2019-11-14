//
//  NodeTouchStateComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/19.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Fix multitouch handling even if not tracking multiple touches. (BUG 20180502B)

// TODO: An option for only tracking a touch if the node has the highest `zPosition`, and maybe only nodes with an entity that has a `NodeTouchStateComponent` should count.

// PERFORMANCE: May need optimization?

// ⚠️ BUG: 20180502A: APPLEBUG? `UITouch.location(in:)` and `UITouch.previousLocation(in:)` are sometimes not updated for many frames, causing a node to "jump" many pixels after 10 or so frames. Same issue with `preciseLocation(in:)` and `precisePreviousLocation(in:)`

// ⚠️ BUG: 20180504B: APPLEBUG? `UITouch.location(in:)` and `UITouch.preciseLocation(in:)` for a touch "wobbles" when a 2nd touch moves near it, even if the tracked touch is stationary.

import SpriteKit
import GameplayKit

#if canImport(UIKit)
    
/// Tracks a single touch if it begins in the entity's `SpriteKitComponent` node, and updates its state depending on the position of the touch in relation to the node's bounds.
///
/// Other components can simply query this component's `state` and `trackedTouch` properties to implement touch-controlled behavior, such as moving a node while it's being touched or updating a button's visual state, without having to track touches themselves.
///
/// - NOTE: To ensure that the state reported by this component remains valid even if the node is modified during the frame, other components should call the `updateState(...)` method after modifying the node or before using this component's state.
///
/// - NOTE: Whereas a `TouchEventComponent` should generally be added to a scene and then linked to other entities via `RelayComponent`s, a `NodeTouchStateComponent` should be added to every entity whose nodes represent a visually interactive area in the scene, such as buttons.
///
/// - NOTE: This component only tracks a single touch by design; specifically the first touch that begins inside the entity's `SpriteKitComponent` node. For multi-touch gestures, use components based on gesture-recognizers.
///
/// **Dependencies:** `SpriteKitComponent`, `TouchEventComponent`
public final class NodeTouchStateComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         TouchEventComponent.self]
    }
    
    // MARK: - Properties
    
    // MARK: State
    
    /// The current state of player interaction with the entity's `SpriteKitComponent` node. See the descriptions for each case of `TouchStateComponent.TouchInteractionState`.
    ///
    /// Changing this property copies the old value to `previousState.`
    @LogInputEventChanges(propertyName: "NodeTouchStateComponent.state")
    public fileprivate(set) var state: NodeTouchState = .ready {
        didSet {
            // CHECK: PERFORMANCE: Will this observer degrade performance compared to just setting `previousState` in `update(deltaTime:)` etc.?
            if  state != oldValue { // Update only when changed.
                
                previousState = oldValue
                stateChangedThisFrame = true
                
                // Discard the tracked touch if the state changed to `ready` or `disabled`.
                
                if  state == .ready || state == .disabled {
                    self.trackedTouch = nil
                }
            }
        }
    }
    
    // ℹ️ `previousState` should initially be the same as `state` so that other components that animate state transitions do not think there has been a transition.
    
    /// Stores the previous value of `state` when it changes.
    public fileprivate(set) var previousState: NodeTouchState = .ready
    
    /// Set to `true` for a single frame after the `state` changes.
    @LogInputEventChanges(propertyName: "NodeTouchStateComponent.stateChangedThisFrame")
    public fileprivate(set) var stateChangedThisFrame: Bool = false
    
    // MARK: Touch
    
    /// Tracks a touch which began inside the entity's `SpriteKitComponent` node.
    @LogInputEventChanges(propertyName: "NodeTouchStateComponent.trackedTouch")
    public fileprivate(set) var trackedTouch: UITouch? = nil {
        didSet {
            if trackedTouch != oldValue { // Reset the timestamps only if we stopped tracking a touch or started tracking a different touch.
                
                previousTouchTimestamp = 0
                trackedTouchTimestampDelta = 0

                if  trackedTouch == nil {
                    initialTouchLocationInScene = nil
                    initialTouchLocationInParent = nil
                }
            }
        }
    }
    
    // CHECK: Keep `initialTouchLocationInScene`, or just `initialTouchLocationInParent`?
    
    /// The first observed location of the currently-tracked touch, in scene coordinates.
    ///
    /// Other components can compare the current location of the touch with this value to obtain the total translation over time.
    @LogInputEventChanges(propertyName: "NodeTouchStateComponent.initialTouchLocationInScene")
    public fileprivate(set) var initialTouchLocationInScene: CGPoint? = nil
    
    // CHECK: Keep `touchTranslationInScene`, or just `touchTranslationInParent`?
    
    /// Returns the total translation over time of the currently-tracked touch's location, in scene coordinates.
    ///
    /// - NOTE: This is *not* a delta value from the last time that the translation was reported.
    public  var touchTranslationInScene: CGPoint? {
        if  let trackedTouch = self.trackedTouch,
            let initialTouchLocationInScene = self.initialTouchLocationInScene,
            let node = self.entityNode,
            let scene = node.scene
            {
            return trackedTouch.location(in: scene) - initialTouchLocationInScene
        } else {
            return nil
        }
    }
    
    /// The first observed location of the currently-tracked touch, in the coordinate system of the parent node containing the entity's `SpriteKitComponent` node.
    ///
    /// Other components can compare the current location of the touch with this value to obtain the total translation over time.
    @LogInputEventChanges(propertyName: "NodeTouchStateComponent.initialTouchLocationInParent")
    public fileprivate(set) var initialTouchLocationInParent: CGPoint? = nil
    
    /// Returns the total translation over time of the currently-tracked touch's location, in the coordinate system of the parent node containing the entity's `SpriteKitComponent` node.
    ///
    /// - NOTE: This is *not* a delta value from the last time that the translation was reported.
    public  var touchTranslationInParent: CGPoint? {
        if  let trackedTouch = self.trackedTouch,
            let initialTouchLocationInParent = self.initialTouchLocationInParent,
            let node = self.entityNode,
            let parent = node.parent
        {
            return trackedTouch.location(in: parent) - initialTouchLocationInParent
        }
        else {
            return nil
        }
    }
    
    // PERFORMANCE: Initializing `previousTouchTimestamp` to `0` instead of making it optional is probably better for performance. (and `-1` may cause conflicts in case of overflows or something :P)
    
    // PERFORMANCE: Comparing timestamps would be more performance-efficient than storing an optional `previousCurrentTouchLocation` and comparing `CGPoint`s.
    
    // ℹ️ It's pointless to make `previousTouchTimestamp` `public` for use by other components, because `previousTouchTimestamp == trackedTouch.timeStamp` at the end of our `update(deltaTime:)`. Better to have a delta property for other components to observe.
    
    /// Stores the previous value of the `timestamp` for the tracked touch.
    @LogInputEventChanges(propertyName: "NodeTouchStateComponent.previousTouchTimestamp")
    private var previousTouchTimestamp: TimeInterval = 0
    
    /// Stores the change in the timestamp of the tracked touch between the previous frame and the current frame.
    ///
    /// Useful for other components to see if the `trackedTouch` has moved.
    @LogInputEventChanges(propertyName: "NodeTouchStateComponent.trackedTouchTimestampDelta")
    public fileprivate(set) var trackedTouchTimestampDelta: TimeInterval = 0
    
    // MARK: Settings
    
    /// ⚠️ TODO: Not implemented. Will only check nodes associated with entities that have a `TouchStateComponent`.
    public var onlyProcessIfNodeHasHighestZPosition: Bool = false
    
    // MARK: - Update
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // TODO: FIX: guard statement passes every frame, even when there is no input.
        
        // Clear the state mutation flag until the state changes again.
        
        if  stateChangedThisFrame { // Otherwise property observers will trigger on every frame!
            stateChangedThisFrame = false // NOTE: This may trigger the property observers multiple times if the state changes later on during this method.
        }
        
        // CHECK: This component should be usable on an `OctopusScene.entity` as well as any other subentity. Should we find a better way to do this than making `parent` and `scene` equal to the `node`?
        
        guard
            self.state != .disabled,
            let node    = entityNode,
            let parent  = (node is SKScene ? node : node.parent), // If the component's node is a scene, `parent` would be set to the node itself.
            let scene   = (node.scene as? OctopusScene) ?? (node as? OctopusScene), // We need the scene to be an `OctopusScene`.
            !scene.didDismissSubsceneThisFrame, // CHECK: Include `didPresentSubsceneThisFrame`?
            let touchEventComponent = coComponent(TouchEventComponent.self)
            else {
                
                // Forget any previously active interaction if we no longer have the required co-components.
                // CHECK: Is this necessary?
                
                // ℹ️ The state should not be automatically set to `disabled` here; that case is meant to be set explicitly, and may affect visual effects from other components.
                
                if  state != .ready && state != .disabled {
                    state  = .ready // Resets `trackedTouch` and timestamps via the property observer.
                }
                return
        }
        
        // If the state was `tapped` or `endedOutside` in the last frame, reset it to `ready` and forget the previously-tracked touch before processing inputs for this frame.
        
        if  state == .tapped || state == .endedOutside {
            // CHECK: Should this be updated regardless of any guard conditions?
            state  = .ready // Resets `trackedTouch` and timestamps via the property observer.
        }
        
        // MARK: Touch Processing
        
        // If we're tracking a touch, update the difference in the touch's timestamp between the last frame and this frame. This lets other components quickly see if the touch was updated.
        
        if  let trackedTouch = self.trackedTouch {
            // CHECK: Should this be updated regardless of any guard conditions?
            trackedTouchTimestampDelta = trackedTouch.timestamp - previousTouchTimestamp
        }

        // ℹ️ We do not use a `switch` statement here, because a single touch may begin AND move in the same frame, generating both a `touchesBegan` event and `touchesMoved` event, so we check all cases every frame, instead of just the first matching case.
        
        // #1: Did the player begin touching the node?
        
        if  trackedTouch == nil,
            state == .ready,
            let touchEvent = touchEventComponent.touchesBegan
        {
            touchesIteration: for touch in touchEvent.touches {
                
                // Start tracking the first touch that is inside our node and set the state to `touching`.
                
                if  node.contains(touch.location(in: parent)) { // TODO: Verify, i.e. with nested nodes.
                    self.trackedTouch = touch
                    self.previousTouchTimestamp = touch.timestamp
                    self.trackedTouchTimestampDelta = 0
                    self.initialTouchLocationInScene = touch.location(in: scene)
                    self.initialTouchLocationInParent = touch.location(in: parent)
                    state = .touching
                    break touchesIteration
                }
            }
        }
        
        // #2: Are we tracking a touch? See if it has moved or ended.
        // NOTE: A touch may begin and move in the same frame.
        
        if  let trackedTouch = self.trackedTouch,
            state == .touching || state == .touchingOutside
        {
            
            // #2.1: Did the player move the touch across the node's bounds?
            
            if  let touchEvent = touchEventComponent.touchesMoved,
                touchEvent.touches.contains(trackedTouch) // CHECK: Necessary?
            {
                // Avoid redundant state changes in case the property is being observed.
                if   node.contains(trackedTouch.location(in: parent)) { // TODO: Verify, i.e. with nested nodes.
                     if state != .touching { state = .touching }
                }
                else if state != .touchingOutside {
                     state = .touchingOutside
                }
            }
            
            // #2.2: Did the player lift the touch inside or outside the node?
            
            // ℹ️ If an `else if` is used, then `touchesEnded`/`touchesCancelled` events would NOT be acted on if there was also an `touchesBegan`/`touchesMoved` event in the same update.
            
            // ℹ️ Also, we must not use `??` and look for only one of `touchesEnded` and `touchesCancelled` — BOTH must be checked for `trackedTouch`, because if there IS a `touchesEnded` event but it doesn't contain `trackedTouch`, we won't get to check if  `touchesCancelled` contains `trackedTouch`.
            
            // CHECK: Is it necessary to check for `trackedTouch` membership, instead of just looking at event type?
            
            let trackedTouchCancelled = touchEventComponent.touchesCancelled?.touches.contains(trackedTouch) ?? false
            let trackedTouchEnded     = touchEventComponent.touchesEnded?.touches.contains(trackedTouch) ?? false
            
            if  trackedTouchCancelled || trackedTouchEnded
            {
                // Avoid redundant state changes in case the property is being observed.
                if   node.contains(trackedTouch.location(in: parent)) { // TODO: Verify, i.e. with nested nodes.
                     if state != .tapped { state = .tapped }
                }
                else if state != .endedOutside {
                     state = .endedOutside
                }
                
                // ℹ️ `trackedTouch` should not become `nil` here, because other components may need its final position etc. when processing a `tapped` or `endedOutside` state.
                
                // `trackedTouch` will be set to `nil` on the next frame after a `tapped` or `endedOutside` state.
                
            }
            
            // Record the timestamp of the tracked touch to compare if it changes later.
            
            // CHECK: PERFORMANCE: Should `previousTouchTimestamp` always be recorded, which would require unwrapping an optional, instead of only during `touching` and `touchingOutside`?
            
            self.previousTouchTimestamp = trackedTouch.timestamp
        }
        
    }
    
    // MARK: - Control
    
    /// Rechecks the tracked touch, if any, against the node's current position and updates the state, and/or optionally suppresses any specified states.
    ///
    /// Other components should call this method after they have moved the entity's node, or if other components want to modify the interaction in some way, so that this component can reflect the correct state for other observers.
    @discardableResult public func updateState(
        suppressStateChangedFlag: Bool = false,
        suppressTappedState: Bool = false,
        suppressCancelledState: Bool = false)
        -> NodeTouchState
    {
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        // If there's no touch being tracked, or no node or scene, just set the state to `ready`.
        
        guard
            let trackedTouch = self.trackedTouch,
            let node = self.entityNode,
            let parent = node.parent
            else {
                
                // ℹ️ The state should not be automatically set to `disabled` here; that case is meant to be set explicitly, and may affect visual effects from other components.
                
                if  state != .ready || state != .disabled {
                    state = .ready // Resets `trackedTouch` and timestamps via the property observer.
                }
                return state
        }
        
        switch state {
            
        case .touching, .touchingOutside:

            // If a touch is still being tracked, check it against the current position of the node.
            
            // Avoid redundant state changes in case the property is being observed.
            if   node.contains(trackedTouch.location(in: parent)) { // TODO: Verify, i.e. with nested nodes.
                 if state != .touching { state = .touching }
            }
            else if state != .touchingOutside {
                 state = .touchingOutside
            }
        
        case .tapped:
            // Suppress a `tapped` state if specified.
            if suppressTappedState { state = .ready }
            
        case .endedOutside:
            // Suppress an `endedOutside` state if specified.
            if suppressCancelledState { state = .ready }
            
        default: break
        }
        
        // Suppress the `stateChangedThisFrame` flag if specified.
        if suppressStateChangedFlag { stateChangedThisFrame = false }
        
        return state
    }
    
    /// Sets the `trackedTouch` to `nil` and if `state` is not `disabled`, sets it to `ready`.
    public func stopTracking() {
        trackedTouch = nil
        
        if  state != .disabled {
            state = .ready
        }
    }
}

@available(*, unavailable, renamed: "NodeTouchStateComponent")
public final class NodeTouchComponent: OctopusComponent, OctopusUpdatableComponent {}

#endif

#if !canImport(UIKit)
public final class NodeTouchStateComponent: iOSExclusiveComponent {}

@available(*, unavailable, renamed: "NodeTouchStateComponent")
public final class NodeTouchComponent: OctopusComponent, OctopusUpdatableComponent {}
#endif
