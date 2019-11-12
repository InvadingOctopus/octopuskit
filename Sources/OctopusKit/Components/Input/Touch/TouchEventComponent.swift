//
//  TouchEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/13.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: A way to associate each stored touch with the node that received it.
// CHECK: Use arrays of each event category?
// CHECK: Confirm that the first and latest touches are indeed tracked properly and update in order as arbitrary touches end.

import GameplayKit

#if os(iOS)

/// Stores the input events received by a scene or interactive node and tracks touches to be used by other components on the next frame update.
///
/// Stores each event category for a single frame for other components to process, and clears it on the next frame unless new events of the same category are received.
///
/// - NOTE: Touch events are delivered by the system to a scene or a node with the `isUserInteractionEnabled` property set to `true`. The scene or node must forward the event data from its `touchesBegan(_,with:)` and related methods, to this component for it to function.
public final class TouchEventComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // MARK: - Subtypes
    
    /// Not currently used.
    public enum TouchEventCategory {
        
        /// A `touchesBegan` event, when one or more new touches have occurred in a view or window.
        case began
        
        /// A `touchesMoved` event, when one or more touches associated with an event have changed.
        case moved
        
        /// A `touchesEnded` event, when one or more fingers are raised from a view or window.
        case ended
        
        /// A `touchesCancelled` event, when a system event (such as a system alert) cancels a touch sequence.
        case cancelled
        
        /// A `touchesEstimatedPropertiesUpdated` event, when updated values were received for previously estimated properties or an update is no longer expected.
        case estimatedPropertiesUpdated
    }
    
    /// Holds the data for a touch event as received by a scene or node.
    public final class TouchEvent: Equatable, CustomStringConvertible {
        
        // NOTE: `Equatable` conformance cannot be automatically synthesized by Swift 4.1 for classes.
        
        public let touches: Set<UITouch>
        public let event: UIEvent?
        public let node: SKNode // CHECK: Should this be optional?
        
        public fileprivate(set) var shouldClear: Bool = false
        
        public var description: String {
            return "\(event)"
        }
        
        public static func == (left: TouchEvent, right: TouchEvent) -> Bool {
            return (left.touches == right.touches
                &&  left.event   === right.event
                &&  left.node    === right.node)
        }
        
        public init(touches: Set<UITouch>,
                    event:   UIEvent?,
                    node:    SKNode)
        {
            self.touches = touches
            self.event   = event
            self.node    = node
        }
        
    }

    // MARK: - Properties
    
    // MARK: Events
    
    // ℹ️ NOTE: The system may send the same type of event (began, ended, etc.) multiple times during a single frame, each reporting different touches, so the `touches` array must be updated inside the event property observers, NOT inside the `update` method, because that could miss the beginning or end of some touches (if they are not reported in the latest event to be received during a frame.) 2018-07-17
    
    @LogInputEventChanges(omitOldValue: true)
    public var touchesBegan: TouchEvent? = nil {
        didSet {
            
            // Add new touches to our array.
            
            if let touchesBegan = self.touchesBegan {
                for newTouch in touchesBegan.touches {
                    if !self.touches.contains(newTouch) {
                        self.touches.append(newTouch)
                    }
                }
            }
            
            // CHECK: Should the array be sorted by touch timestamps?
            // TODO: Confirm that the `firstTouch` property correctly points to the next oldest touch after the first touch ends.
        }
    }
    
    @LogInputEventChanges(omitOldValue: true)
    public var touchesMoved: TouchEvent? = nil
    
    @LogInputEventChanges(omitOldValue: true) public var touchesEnded: TouchEvent? = nil {
        didSet {
            
            // Remove finished touches from our array.
            
            if let touchesEnded = self.touchesEnded {
                for touch in touchesEnded.touches {
                    if let indexToRemove = self.touches.firstIndex(of: touch) {
                        self.touches.remove(at: indexToRemove)
                    }
                }
            }
            
            // TODO: Confirm that the `latestTouch` property correctly points to the next latest touch after the latest touch end.
        }
    }
    
    @LogInputEventChanges(omitOldValue: true)
    public var touchesCancelled: TouchEvent? = nil  {
        didSet {
            
            // Remove finished touches from our array.
            
            if let touchesEnded = self.touchesEnded {
                for touch in touchesEnded.touches {
                    if let indexToRemove = self.touches.firstIndex(of: touch) {
                        self.touches.remove(at: indexToRemove)
                    }
                }
            }
            
            // TODO: Confirm that the `latestTouch` property correctly points to the next latest touch after the latest touch ends.
        }
    }
    
    @LogInputEventChanges(omitOldValue: true)
    public var touchesEstimatedPropertiesUpdated: TouchEvent? = nil
    
    /// Returns an array of all events for the current frame.
    ///
    /// - IMPORTANT: The array returned by this property is a *snapshot* of the events that are *currently* stored by this component; it does *not* automatically point to new events when they are received. To ensure that you have the latest events, either query the individual `touches...` properties or recheck this property at the point of use.
    public var allEvents: [TouchEvent?] {
        [touchesBegan,
         touchesMoved,
         touchesEnded,
         touchesCancelled,
         touchesEstimatedPropertiesUpdated]
    }
    
    // MARK: Touches
    
    // ℹ️ DECIDE: If `touches` is an `Array` then they may be sorted and enumerated by their timestamp, but if `touches` is a `Set` then that will strongly prevent duplicate touches, right?
    
    /// A list of currently active touches.
    ///
    /// Stores touches that are reported in `touchesBegan` events, until they are reported in a `touchesEnded` or `touchesCancelled` event.
    public fileprivate(set) var touches: [UITouch] = []
    
    /// Stores the first touch that begins when the list of touches is empty.
    ///
    /// Components that only need to track a single touch may simply observe this property.
    public var firstTouch: UITouch? {
        return touches.first
        // TODO: Confirm that this property correctly points to the next oldest touch after the first touch ends.
    }
    
    /// Stores the latest touch, which may be the same as the `firstTouch` property.
    ///
    /// Components that only need to track a single touch may simply observe this property.
    public var latestTouch: UITouch? {
        return touches.last
        // TODO: Confirm that this property correctly points to the next latest touch after the latest touch ends.
    }
    
    // MARK: - Frame Cycle
    
    public override func update(deltaTime seconds: TimeInterval) {
  
        // #1: Discard all events if we are part of a scene that has displayed or dismissed a subscene in this frame.
        // CHECK: Necessary? Useful?
        
        if  let scene = coComponent(SpriteKitSceneComponent.self)?.scene,
            scene.didPresentSubsceneThisFrame || scene.didDismissSubsceneThisFrame
        {
            clearAllEvents()
            return
        }
        
        // #2: Clear stale events whose flags have been set.
        
        // ℹ️ We cannot use `if let` unwrapping as we need to modify the actual properties themselves, not their values.
        
        if touchesBegan?.shouldClear ?? false { touchesBegan = nil }
        if touchesMoved?.shouldClear ?? false { touchesMoved = nil }
        if touchesEnded?.shouldClear ?? false { touchesEnded = nil }
        if touchesCancelled?.shouldClear ?? false { touchesCancelled = nil }
        if touchesEstimatedPropertiesUpdated?.shouldClear ?? false { touchesEstimatedPropertiesUpdated = nil }
        
        // #3: Flag non-`nil` events to be cleared on the next frame, so that other components do not see any stale input data.
        
        touchesBegan?.shouldClear = true
        touchesMoved?.shouldClear = true
        touchesEnded?.shouldClear = true
        touchesCancelled?.shouldClear = true
        touchesEstimatedPropertiesUpdated?.shouldClear = true
    }
    
    /// Discards all events and touches.
    public func clearAllEvents() {
        
        // ℹ️ Since we have to set the properties themselves to `nil`, we cannot use an array etc. as that would only modify the array's members, not our properties. 2018-05-20
        
        touchesBegan = nil
        touchesMoved = nil
        touchesEnded = nil
        touchesCancelled = nil
        touchesEstimatedPropertiesUpdated = nil
        
        touches.removeAll(keepingCapacity: true) // CHECK: Should the `touches` array be emptied in `clearAllEvents()`?
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        clearAllEvents()
    }
}

/// A placeholder protocol whose default implementation channels touch events from a SpriteKit node to the `TouchEventComponent` of the node's entity. Currently cannot be elegantly implemented because of the limitations and issues with Default Implementations and inheritance. 2018-05-08
public protocol TouchEventProvider {
    func touchesBegan       (_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved       (_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesCancelled   (_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded       (_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>)
}

#endif

#if !canImport(UIKit)
public final class TouchEventComponent: iOSExclusiveComponent {}
public protocol TouchEventProvider {}
#endif
