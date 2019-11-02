//
//  MouseEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/2.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: A way to associate each stored input with the node that received it.
// CHECK: Use arrays of each event category?

import GameplayKit

#if os(macOS)

/// Stores the mouse input events received by a scene or interactive node to be used by other components on the next frame update.
///
/// Stores each event category for a single frame for other components to process, and clears it on the next frame unless new events of the same category are received.
///
/// - NOTE: The scene or node must forward the event data from its `mouseEntered(with:)` and related methods, to this component for it to function.
public final class MouseEventComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // MARK: - Subtypes
    
    /// Not currently used.
    public enum MouseEventCategory {
        
        /// A `mouseEntered` event.
        case entered
        
        /// A `mouseMoved` event.
        case moved
        
        /// A `mouseDown` event.
        case down
        
        /// A `mouseDragged` event.
        case dragged
        
        /// A `mouseUp` event.
        case up
        
        /// A `mouseExited` event.
        case exited
    }
    
    /// Holds the data for a mouse event as received by a scene or node.
    public final class MouseEvent: Equatable, CustomStringConvertible {
        
        // NOTE: `Equatable` conformance cannot be automatically synthesized by Swift 4.1 for classes.
        
        public let event: NSEvent
        public let node: SKNode // CHECK: Should this be optional?
        
        public fileprivate(set) var shouldClear: Bool = false
        
        public var description: String {
            return "\(String(optional: event))"
        }
        
        public init(event: NSEvent, node: SKNode) {
            self.event = event
            self.node = node
        }
        
        public static func == (left: MouseEvent, right: MouseEvent) -> Bool {
            return (left.event === right.event
                &&  left.node  === right.node)
        }
        
    }

    // MARK: - Properties
    
    // MARK: Events
        
    @LogInputEvent public var mouseEntered: MouseEvent?
    
    public var mouseMoved: MouseEvent?
    
    public var mouseDown: MouseEvent? {
        didSet {
            #if LOGINPUTEVENTS
            if mouseDown != oldValue { debugLog("= \(String(optional: mouseDown))") }
            #endif
        }
    }
    
    public var mouseDragged: MouseEvent? {
        didSet {
            #if LOGINPUTEVENTS
            if mouseDragged != oldValue { debugLog("= \(String(optional: mouseDragged))") }
            #endif
        }
    }
    
    public var mouseUp: MouseEvent? {
        didSet {
            #if LOGINPUTEVENTS
            if mouseUp != oldValue { debugLog("= \(String(optional: mouseUp))") }
            #endif
        }
    }
    
    public var mouseExited: MouseEvent? {
        didSet {
            #if LOGINPUTEVENTS
            if mouseExited != oldValue { debugLog("= \(String(optional: mouseExited))") }
            #endif
        }
    }
        
    /// Returns an array of all events for the current frame.
    ///
    /// - IMPORTANT: The array returned by this property is a *snapshot* of the events that are *currently* stored by this component; it does *not* automatically point to new events when they are received. To ensure that you have the latest events, either query the individual `mouse...` properties or recheck this property at the point of use.
    public var allEvents: [MouseEvent?] {
        [mouseEntered,
         mouseMoved,
         mouseDown,
         mouseDragged,
         mouseUp,
         mouseExited]
    }
    
    // MARK: - Life Cycle
    
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
        
        if mouseEntered?.shouldClear    ?? false { mouseEntered = nil }
        if mouseMoved?.shouldClear      ?? false { mouseMoved = nil }
        if mouseDown?.shouldClear       ?? false { mouseDown = nil }
        if mouseDragged?.shouldClear    ?? false { mouseDragged = nil }
        if mouseUp?.shouldClear         ?? false { mouseUp = nil }
        if mouseExited?.shouldClear     ?? false { mouseExited = nil }
        
        // #3: Flag non-`nil` events to be cleared on the next frame, so that other components do not see any stale input data.
    
        mouseEntered?.shouldClear = true
        mouseMoved?.shouldClear   = true
        mouseDown?.shouldClear    = true
        mouseDragged?.shouldClear = true
        mouseUp?.shouldClear      = true
        mouseExited?.shouldClear  = true
    }
    
    /// Discards all events.
    public func clearAllEvents() {
        
        // ℹ️ Since we have to set the properties themselves to `nil`, we cannot use an array etc. as that would only modify the array's members, not our properties. 2018-05-20
        
        mouseEntered    = nil
        mouseMoved      = nil
        mouseDown       = nil
        mouseDragged    = nil
        mouseUp         = nil
        mouseExited     = nil
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        clearAllEvents()
    }
}

/// A placeholder protocol whose default implementation channels mouse events from a SpriteKit node to the `MouseEventComponent` of the node's entity. Currently cannot be elegantly implemented because of the limitations and issues with Default Implementations and inheritance. 2018-05-08
public protocol MouseEventProvider {
    func mouseEntered   (with event: NSEvent)
    func mouseMoved     (with event: NSEvent)
    func mouseDown      (with event: NSEvent)
    func mouseDragged   (with event: NSEvent)
    func mouseUp        (with event: NSEvent)
    func mouseExited    (with event: NSEvent)
}

#else
    
public final class MouseEventComponent: macOSExclusiveComponent {}
    
#endif
