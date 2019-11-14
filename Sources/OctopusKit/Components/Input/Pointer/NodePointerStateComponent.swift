//
//  NodePointerStateComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/4.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: An option for only tracking a pointer if the node has the highest `zPosition`, and maybe only nodes with an entity that has a `NodePointerStateComponent` should count.

// PERFORMANCE: May need optimization?

import SpriteKit
import GameplayKit

/// An intermediary component which tracks a pointer (touch or mouse) if it begins in the entity's `SpriteKitComponent` node, and updates its state depending on the position of the pointer in relation to the node's bounds.
///
/// Other components can simply query this component's `state`, `lastEvent` and other properties to implement pointer-controlled behavior, such as moving a node while it's being touched or updating a sprite's visual state when it's clicked, without having to directly track touches or the mouse pointer.
///
/// - IMPORTANT: To ensure that the state reported by this component remains valid even if the node is modified during the frame, other components should call the `updateState(...)` method after modifying the node or before using this component's state.
///
/// - NOTE: Whereas a `PointerEventComponent` should generally be added to a scene and then linked to other entities via `RelayComponent`s, a `NodePointerStateComponent` should be added to every entity whose nodes represent a visually interactive area in the scene, such as buttons.
///
/// - NOTE: This component only tracks a single pointer by design; e.g. the first touch that begins inside the entity's `SpriteKitComponent` node. For multi-touch gestures, use components based on gesture-recognizers.
///
/// **Dependencies:** `SpriteKitComponent`, `PointerEventComponent`
public final class NodePointerStateComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         PointerEventComponent.self]
    }
    
    // MARK: - Properties
    
    // MARK: State
    
    /// The current state of player interaction with the entity's `SpriteKitComponent` node. See the descriptions for each case of `NodePointerState`.
    ///
    /// Changing this property copies the old value to `previousState.`
    @LogInputEventChanges(propertyName: "NodePointerStateComponent.state")
    public fileprivate(set) var state: NodePointerState = .ready {
        didSet {
            // CHECK: PERFORMANCE: Will this observer degrade performance compared to just setting `previousState` in `update(deltaTime:)` etc.?
            if  state != oldValue { // Update only when changed.
                
                previousState = oldValue
                stateChangedThisFrame = true
                
                // Discard the last stored event if the state changed to `ready` or `disabled`, because we are no longer tracking a pointer event sequence.
                
                if  state == .ready || state == .disabled {
                    self.lastEvent = nil
                }
            }
        }
    }
    
    // ℹ️ `previousState` should initially be the same as `state` so that other components that animate state transitions do not think there has been a transition.
    
    /// Stores the previous value of `state` when it changes.
    public fileprivate(set) var previousState: NodePointerState = .ready
    
    /// Set to `true` for a single frame after the `state` changes.
    @LogInputEventChanges(propertyName: "NodePointerStateComponent.stateChangedThisFrame")
    public fileprivate(set) var stateChangedThisFrame: Bool = false
    
    // MARK: Pointer
    
    /// Stores the last received event of the event sequence which began inside the entity's `SpriteKitComponent` node.
    ///
    /// This property is set to `nil` whenever the `state` changes to `ready` and when there are no more pointer events related to the node.
    ///
    /// Changing this property resets the following properties: `previousTimestamp`, `timestampDelta`, `initialPointerLocationInScene` and `initialPointerLocationInParent`.
    @LogInputEventChanges(propertyName: "NodePointerStateComponent.lastEvent")
    public fileprivate(set) var lastEvent: PointerEventComponent.PointerEvent? = nil {
        didSet {
            if  lastEvent != oldValue { // Reset the timestamps only if we received a different event or no events.
                
                previousTimestamp = 0
                timestampDelta = 0

                if  lastEvent == nil {
                    initialPointerLocationInScene = nil
                    initialPointerLocationInParent = nil
                }
            }
        }
    }
    
    // CHECK: Keep `initialPointerLocationInScene`, or just `initialPointerLocationInParent`?
    
    /// The first observed location of the currently-tracked pointer, in scene coordinates.
    ///
    /// Other components can compare the current location of the pointer with this value to obtain the total translation over time.
    @LogInputEventChanges(propertyName: "NodePointerStateComponent.initialPointerLocationInScene")
    public fileprivate(set) var initialPointerLocationInScene: CGPoint? = nil
    
    // CHECK: Keep `pointerTranslationInScene`, or just `pointerTranslationInParent`?
    
    /// Returns the total translation over time of the currently-tracked pointer's location, in scene coordinates.
    ///
    /// - NOTE: This is *not* a delta value from the last time that the translation was reported.
    public var pointerTranslationInScene: CGPoint? {
        if  let lastEvent = self.lastEvent,
            let initialPointerLocationInScene = self.initialPointerLocationInScene,
            let node = self.entityNode,
            let scene = node.scene
        {
            return lastEvent.location(in: scene) - initialPointerLocationInScene
        } else {
            return nil
        }
    }
    
    /// The first observed location of the currently-tracked pointer, in the coordinate system of the parent node containing the entity's `SpriteKitComponent` node.
    ///
    /// Other components can compare the current location of the pointer with this value to obtain the total translation over time.
    @LogInputEventChanges(propertyName: "NodePointerStateComponent.initialPointerLocationInParent")
    public fileprivate(set) var initialPointerLocationInParent: CGPoint? = nil
    
    /// Returns the total translation over time of the currently-tracked pointer's location, in the coordinate system of the parent node containing the entity's `SpriteKitComponent` node.
    ///
    /// - NOTE: This is *not* a delta value from the last time that the translation was reported.
    public  var pointerTranslationInParent: CGPoint? {
        if  let lastEvent = self.lastEvent,
            let initialPointerLocationInParent = self.initialPointerLocationInParent,
            let node = self.entityNode,
            let parent = node.parent
        {
            return lastEvent.location(in: parent) - initialPointerLocationInParent
        } else {
            return nil
        }
    }
    
    // PERFORMANCE: Initializing `previousTimestamp` to `0` instead of making it optional is probably better for performance. (and `-1` may cause conflicts in case of overflows or something :P)
    
    // PERFORMANCE: Comparing timestamps would be more performance-efficient than storing an optional `previousLocation` and comparing `CGPoint`s.
    
    // ℹ️ It's pointless to make `previousTimestamp` `public` for use by other components, because `previousTimestamp = lastEvent.timeStamp` at the end of our `update(deltaTime:)`. Better to have a delta property for other components to observe.
    
    /// Stores the previous value of the `timestamp` for the most recent event.
    @LogInputEventChanges(propertyName: "NodePointerStateComponent.previousTimestamp")
    private var previousTimestamp: TimeInterval = 0
    
    /// Stores the change in the timestamp of the most recent event between the previous frame and the current frame.
    ///
    /// Useful for other components to see if the pointer has moved.
    @LogInputEventChanges(propertyName: "NodePointerStateComponent.timestampDelta")
    public fileprivate(set) var timestampDelta: TimeInterval = 0
    
    // MARK: Settings
    
    /// ⚠️ TODO: Not implemented. Will only check nodes associated with entities that have a `PointerStateComponent`.
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
            let pointerEventComponent = coComponent(PointerEventComponent.self)
            else {
                
                // Forget any previously active interaction if we no longer have the required co-components.
                // CHECK: Is this necessary?
                
                // ℹ️ The state should not be automatically set to `disabled` here; that case is meant to be set explicitly, and may affect visual effects from other components.
                
                if  state != .ready && state != .disabled {
                    state  = .ready // Resets `lastEvent` and timestamps via the property observer.
                }
                return
        }
        
        // If the state was `tapped` or `endedOutside` in the last frame, reset it to `ready` and forget related properties before processing inputs for this frame.
        
        if  state == .tapped || state == .endedOutside {
            // CHECK: Should this be updated regardless of any guard conditions?
            state = .ready // Resets timestamps via the property observer.
        }
        
        // MARK: Event Processing
        
        // If there has been a pointer event this frame, update the difference in our timestamp between the last frame and this frame. This lets other components quickly check if the pointer was updated.
        
        if  let latestEvent = pointerEventComponent.latestEvent {
            // CHECK: Should this be updated regardless of any guard conditions?
            timestampDelta = latestEvent.timestamp - previousTimestamp
        }
        
        // ℹ️ We do not use a `switch` statement here, because a pointer may begin AND move in the same frame, generating both a `pointerBegan` event and `pointerMoved` event, so we check all cases every frame, instead of just the first matching case.
        
        // #1: Did the player begin touching or clicking the node?
        
        if  state == .ready,
            let pointerBegan = pointerEventComponent.pointerBegan
        {
            // Set the state to `pointing` if the pointer is inside our node.
            
            if  node.contains(pointerBegan.location(in: parent)) { // TODO: Verify, i.e. with nested nodes.
                self.lastEvent = pointerBegan
                self.previousTimestamp = pointerBegan.timestamp
                self.timestampDelta = 0
                self.initialPointerLocationInScene  = pointerBegan.location(in: scene)
                self.initialPointerLocationInParent = pointerBegan.location(in: parent)
                state = .pointing
            }
        }
        
        // #2: Are we tracking a pointer? See if it has moved or ended.
        // NOTE: A pointer may begin and move in the same frame.
        
        if  state == .pointing || state == .pointingOutside {
            
            // #2.1: Did the player move the pointer across the node's bounds?
            
            if  let pointerMoved = pointerEventComponent.pointerMoved {
                // Avoid redundant state changes in case the property is being observed.
                if   node.contains(pointerMoved.location(in: parent)) { // TODO: Verify, i.e. with nested nodes.
                     if state != .pointing { state = .pointing }
                }
                else if state != .pointingOutside {
                     state = .pointingOutside
                }
            }
            
            // #2.2: Did the player end the pointer inside or outside the node?
            
            // ℹ️ If an `else if` is used, then `pointerEnded` events would NOT be acted on if there was also an `pointerBegan`/`pointerMoved` event in the same update.
                        
            if  let pointerEnded = pointerEventComponent.pointerEnded
            {
                // Avoid redundant state changes in case the property is being observed.
                if   node.contains(pointerEnded.location(in: parent)) { // TODO: Verify, i.e. with nested nodes.
                     if state != .tapped { state = .tapped }
                }
                else if state != .endedOutside {
                     state = .endedOutside
                }
                
                // ℹ️ `lastEvent` should not become `nil` here, because other components may need its final position etc. when processing a `tapped` or `endedOutside` state.
                
                // `lastEvent` will be set to `nil` on the next frame after a `tapped` or `endedOutside` state.
                
            }
            
            // Record the timestamp of the event to compare if it changes later.
            
            // CHECK: PERFORMANCE: Should `previousPointerTimestamp` always be recorded, which would require unwrapping an optional, instead of only during `pointing` and `pointingOutside`?
            
            if  let lastEvent = self.lastEvent {
                self.previousTimestamp = lastEvent.timestamp
            }
        }
        
    }
    
    // MARK: - Control
    
    /// Rechecks the last event, if any, against the node's current position and updates the state, and/or optionally suppresses any specified states.
    ///
    /// Other components should call this method after they have moved the entity's node, or if other components want to modify the interaction in some way, so that this component can reflect the correct state for other observers.
    @discardableResult public func updateState(
        suppressStateChangedFlag:   Bool = false,
        suppressTappedState:        Bool = false,
        suppressCancelledState:     Bool = false)
        -> NodePointerState
    {
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        // If there's no pointer being tracked, or no node or scene, just set the state to `ready`.
        
        guard
            let lastEvent = self.lastEvent,
            let node = self.entityNode,
            let parent = node.parent
            else {
                
                // ℹ️ The state should not be automatically set to `disabled` here; that case is meant to be set explicitly, and may affect visual effects from other components.
                
                if  state != .ready || state != .disabled {
                    state  = .ready // Resets `lastEvent` and timestamps via the property observer.
                }
                return state
        }
        
        switch state {
            
        case .pointing, .pointingOutside:

            // If a pointer is still being tracked, check it against the current position of the node.
            
            // Avoid redundant state changes in case the property is being observed.
            if node.contains(lastEvent.location(in: parent)) { // TODO: Verify, i.e. with nested nodes.
                if state != .pointing { state = .pointing }
            }
            else if state != .pointingOutside {
                state = .pointingOutside
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
    
    /// Sets the `lastEvent` to `nil` and if `state` is not `disabled`, sets it to `ready`.
    public func stopTracking() {
        lastEvent = nil
        
        if  state != .disabled {
            state = .ready
        }
    }
}
