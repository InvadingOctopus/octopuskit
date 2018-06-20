//
//  TouchEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/13.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: A way to associate each stored touch with the node that received it.
// CHECK: Use arrays of each event category?


import GameplayKit

#if os(iOS)

/// Stores the input events received by a scene or interactive node and tracks touches to be used by other components.
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
            return "\(String(optional: event))"
        }
        
        public init(touches: Set<UITouch>,
                    event: UIEvent?,
                    node: SKNode)
        {
            self.touches = touches
            self.event = event
            self.node = node
        }

        public static func == (left: TouchEvent, right: TouchEvent) -> Bool {
            return (left.touches == right.touches
                &&  left.event === right.event
                &&  left.node === right.node)
        }
        
    }

    // MARK: - Properties
    
    // MARK: Events
    
    public var touchesBegan: TouchEvent? {
        didSet {
            #if LOGINPUT
            if touchesBegan != oldValue { debugLog("\(String(optional: touchesBegan))") }
            #endif
        }
    }
    
    public var touchesMoved: TouchEvent? {
        didSet {
            #if LOGINPUT
            if touchesMoved != oldValue { debugLog("\(String(optional: touchesMoved))") }
            #endif
        }
    }
    
    public var touchesEnded: TouchEvent? {
        didSet {
            #if LOGINPUT
            if touchesEnded != oldValue { debugLog("\(String(optional: touchesEnded))") }
            #endif
        }
    }
    
    public var touchesCancelled: TouchEvent? {
        didSet {
            #if LOGINPUT
            if touchesCancelled != oldValue { debugLog("\(String(optional: touchesCancelled))") }
            #endif
        }
    }
    
    public var touchesEstimatedPropertiesUpdated: TouchEvent? {
        didSet {
            #if LOGINPUT
            if touchesEstimatedPropertiesUpdated != oldValue { debugLog("\(String(optional: touchesEstimatedPropertiesUpdated))") }
            #endif
        }
    }
    
    /// Returns an array of all the current events.
    ///
    /// - IMPORTANT: The array returned by this property is like a *snapshot* of the events *currently* stored by the component; it does *not* automatically point to new events when they are received. To ensure that you have the latest events, either query the individual `touches...` properties or recheck this property at the point of use.
    public var allEvents: [TouchEvent?] {
        return [touchesBegan,
                touchesMoved,
                touchesEnded,
                touchesCancelled,
                touchesEstimatedPropertiesUpdated]
    }
    
    // MARK: Touches
    
    /// A list of currently active touches.
    ///
    /// Stores touches that are reported in `touchesBegan` events, until they are reported in a `touchesEnded` or `touchesCancelled` event.
    public fileprivate(set) var touches: [UITouch] = []
    
    /// Stores the first touch that begins when the list of touches is empty.
    ///
    /// Components that only need to track a single touch may simply observe this property.
    public fileprivate(set) var firstTouch: UITouch? {
        didSet {
            #if LOGINPUT
            if firstTouch != oldValue { debugLog("\(String(optional: oldValue)) → \(String(optional: firstTouch))") }
            #endif
        }
    }
    
    
    /// Stores the latest touch, which may be the same as the `firstTouch` property.
    ///
    /// Components that only need to track a single touch may simply observe this property.
    public fileprivate(set) var latestTouch: UITouch? {
        didSet {
            #if LOGINPUT
            if latestTouch != oldValue { debugLog("\(String(optional: oldValue)) → \(String(optional: latestTouch))") }
            #endif
        }
    }
    
    // MARK: - Life Cycle
    
    public override func update(deltaTime seconds: TimeInterval) {
  
        // #1: Discard all events if we are part of a scene and the scene has displayed or dismissed a subscene this frame.
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
        if  touchesEstimatedPropertiesUpdated?.shouldClear ?? false { touchesEstimatedPropertiesUpdated = nil }
        
        // #3: Did any new touches begin during this frame?
        
        if let event = touchesBegan {
            
            // #2.1: Does the event have any touches we are not tracking? Add them to our list.
            // Make sure it's in order.
            
            // TODO: Use functional methods for array joining.
            
            for touch in event.touches {
                if !self.touches.contains(touch) {
                    self.touches.append(touch)
                }
            }
            
            // CHECK: Should we sort the array by timestamp?
        }
        
        // #4.1: Record the first touch to make it simpler to observe for components that follow a single touch.
        
        if self.firstTouch == nil {
            self.firstTouch = self.touches.first
        }
        
        // #4.1: Record the first touch to make it simpler to observe for components that follow a single touch.
        // This touch may be the same as the first touch.
        
        self.latestTouch = self.touches.last
        
        // #5: Did any touches end during this frame?
        
        let endingEvents = [touchesEnded, touchesCancelled]
        
        for case let endingEvent? in endingEvents {
            for touch in endingEvent.touches {
                
                // #5.1: If any of the touches we're tracking were reported in an `touchesEnded` or `touchesCancelled`, remove them from our list.
                
                if let indexToRemove = self.touches.index(of: touch) {
                    self.touches.remove(at: indexToRemove)
                }
                
                // #5.2: If the first touch we were tracking has ended, clear that property.
                
                if touch === self.firstTouch {
                    self.firstTouch = nil
                }
                
                // #5.2: If the latest touch we were tracking has ended, clear that property.
                
                if touch === self.latestTouch {
                    self.latestTouch = nil
                }
            }
        }
        
        // #6: Flag non-`nil` events to be cleared on the next frame, so that other components do not see any stale input data.
        
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
        
        touches.removeAll(keepingCapacity: true)
        firstTouch = nil
    }
}

/// A placeholder protocol whose default implementation channels touch events from a node to the `TouchEventComponent` of the node's entity. Currently cannot be elegantly implemented because of the limitations and issues with Default Implementations and inheritance. 2018-05-08
public protocol TouchEventComponentCompatible {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>)
}

#else
    
public final class TouchEventComponent: iOSExclusiveComponent {}
    
#endif
