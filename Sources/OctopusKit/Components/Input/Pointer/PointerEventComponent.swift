//
//  PointerEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/14, 2019/11/3.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// DECIDE: Will constantly copying over events between this component and touch/mouse components be better than simply accessing the touch or mouse event at the point of use in player-controlled components?

import OctopusCore
import SpriteKit
import GameplayKit

/// A device-agnostic component that provides abstraction for the entity's `TouchEventComponent` on iOS or `MouseEventComponent` on macOS, for relaying player input from pointer-like sources, such as touch or mouse, to other components which depend on player input.
///
/// Only stores the location of a single pointer; does not differentiate between number of pointers (fingers), type of mouse buttons (left/right), or modifier keys (Shift/Control/etc.)
///
/// **Dependencies:** `TouchEventComponent` on iOS, `MouseEventComponent` on macOS.
public final class PointerEventComponent: OKComponent, RequiresUpdatesPerFrame {
    
    // MARK: - Subtypes
    
    public enum PointerEventCategory {
        
        /// A `pointerBegan` event, when a touch or click has occurred.
        case began
        
        /// A `pointerMoved` event, when a touch has moved or the mouse pointer has been dragged.
        case moved
        
        /// A `pointerEnded` event, when a touch or mouse button has been lifted.
        case ended
    }
    
    public final class PointerEvent: Equatable, CustomStringConvertible {
        
        // NOTE: `Equatable` conformance cannot be automatically synthesized by Swift 4.1 for classes.
        
        public let category:  PointerEventCategory
        public let timestamp: TimeInterval
        
        public let node: SKNode
        public let locationInNode: CGPoint
        
        public var shouldClear: Bool = false // Not private(set) so we can make update(deltaTime:) @inlinable
        
        public static func == (left: PointerEvent, right: PointerEvent) -> Bool {
            return (left.category       ==  right.category
                &&  left.timestamp      ==  right.timestamp
                &&  left.node           === right.node
                &&  left.locationInNode ==  right.locationInNode)
        }
        
        public var description: String { "\(category) \(locationInNode)" }
        
        #if canImport(AppKit)
        
        public init?(category: PointerEventCategory? = nil,
                     event:    NSEvent? = nil,
                     node:     SKNode?  = nil)
        {
            guard
                let category = category,
                let event    = event,
                let node     = node
                else { return nil }
            
            self.category       = category
            self.timestamp      = event.timestamp
            self.node           = node
            self.locationInNode = event.location(in: node)
        }
        
        #endif
        
        #if canImport(UIKit)
        
        public init?(category:   PointerEventCategory? = nil,
                     firstTouch: UITouch? = nil,
                     event:      UIEvent? = nil,
                     node:       SKNode?  = nil)
        {
            guard
                let category    = category,
                let firstTouch  = firstTouch,
                let event       = event,
                let node        = node
                else { return nil }
            
            self.category       = category
            self.timestamp      = event.timestamp
            self.node           = node
            self.locationInNode = firstTouch.location(in: node)
        }
        
        #endif
        
        @inlinable
        public func location(in anotherNode: SKNode) -> CGPoint {
            self.node.convert(locationInNode, to: anotherNode)
        }
    }
    
    // MARK: - Properties
    
    #if os(iOS)
    
    public override var requiredComponents: [GKComponent.Type]? {
        [TouchEventComponent.self]
    }
    
    #elseif os(macOS)
    
    public override var requiredComponents: [GKComponent.Type]? {
        [MouseEventComponent.self]
    }
    
    #endif
    
    @LogInputEventChanges(propertyName: "PointerEventComponent.pointerBegan")
    public var pointerBegan: PointerEvent? = nil { // Not private(set) so we can make update(deltaTime:) @inlinable
        didSet {
            if  let pointerBegan = pointerBegan {
                
                if  lastEvent == nil || lastEvent!.timestamp < pointerBegan.timestamp {
                    lastEvent = pointerBegan
                }
                
                if  latestEventForCurrentFrame == nil || latestEventForCurrentFrame!.timestamp < pointerBegan.timestamp {
                    latestEventForCurrentFrame = pointerBegan
                }
            }
        }
    }
    
    @LogInputEventChanges(propertyName: "PointerEventComponent.pointerMoved")
    public var pointerMoved: PointerEvent? = nil { // Not private(set) so we can make update(deltaTime:) @inlinable
        didSet {
            if  let pointerMoved = pointerMoved {
                
                if  lastEvent == nil || lastEvent!.timestamp < pointerMoved.timestamp {
                    lastEvent = pointerMoved
                }
                
                if  latestEventForCurrentFrame == nil || latestEventForCurrentFrame!.timestamp < pointerMoved.timestamp {
                    latestEventForCurrentFrame = pointerMoved
                }
            }
        }
    }
    
    @LogInputEventChanges(propertyName: "PointerEventComponent.pointerEnded")
    public var pointerEnded: PointerEvent? = nil { // Not private(set) so we can make update(deltaTime:) @inlinable
        didSet {
            if  let pointerEnded = pointerEnded {
                
                if  lastEvent == nil || lastEvent!.timestamp < pointerEnded.timestamp {
                    lastEvent = pointerEnded
                }
                
                if  latestEventForCurrentFrame == nil || latestEventForCurrentFrame!.timestamp < pointerEnded.timestamp {
                    latestEventForCurrentFrame = pointerEnded
                }
                
            }
        }
    }
    
    /// Returns the event which was received during this frame. To check the last event received in previous frames, use `lastEvent`
//    @inlinable
    @LogInputEventChanges(propertyName: "PointerEventComponent.latestEventForCurrentFrame")
    public var latestEventForCurrentFrame: PointerEvent? = nil // Not private(set) so update(deltaTime:) can be @inlinable
//    {
//        [pointerBegan, pointerMoved, pointerEnded]
//            .compactMap { $0 }
//            .sorted     { $0.timestamp > $1.timestamp }
//            .first
//    }
    
    /// Returns the last event received during this *or any previous* frames. To check the *latest* event received during the current frame, use `latestEventForCurrentFrame`.
    @LogInputEventChanges(propertyName: "PointerEventComponent.lastEvent")
    public private(set) var lastEvent: PointerEvent? = nil {
        didSet {
            if  lastEvent != oldValue {
                secondLastEvent = oldValue
            }
        }
    }
    
    /// Returns the second last event received in previous updates. Use this for comparing pointer movement and state between events.
    @LogInputEventChanges(propertyName: "PointerEventComponent.secondLastEvent")
    public private(set) var secondLastEvent: PointerEvent? = nil
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        // Issue a warning for a common mistake: Adding an input event component to a child entity instead of the scene's entity.
        if  !(self.entity?.node is SKScene) {
            OKLog.warnings.debug("\(📜("\(self) added to a child entity instead of the OKScene.entity: \(entity) — Events may not be received!"))")
            OKLog.tips.debug("\(📜("Use RelayComponent(for:) to add a relay to the scene's sharedPointerEventComponent, or override the scene's input handling methods."))")
        }
    }
    
    // MARK: - Frame Cycle
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        // #1: Discard all events if we are part of a scene that has displayed or dismissed a subscene in this frame.
        // CHECK: Necessary? Useful?
        
        if  let scene = coComponent(SceneComponent.self)?.scene,
            scene.didPresentSubsceneThisFrame || scene.didDismissSubsceneThisFrame
        {
            clearAllEvents()
            return
        }
        
        // #2: Clear latestEventForCurrentFrame until we have an event.
        
        latestEventForCurrentFrame = nil
        
        // #3: Mirror a `TouchEventComponent` on iOS or a `MouseEventComponent` on macOS.
        
        #if canImport(AppKit)
        
        if  let mouseEventComponent = coComponent(MouseEventComponent.self) {
            
            if  let mouseDown = mouseEventComponent.mouseDown {
                pointerBegan = PointerEvent(category:  .began,
                                            event:      mouseDown.event,
                                            node:       mouseDown.node)
            }
            
            if  let mouseDragged = mouseEventComponent.mouseDragged {
                pointerMoved = PointerEvent(category:  .moved,
                                            event:      mouseDragged.event,
                                            node:       mouseDragged.node)
            }
            
            if  let mouseUp = mouseEventComponent.mouseUp {
                pointerEnded = PointerEvent(category:  .ended,
                                            event:      mouseUp.event,
                                            node:       mouseUp.node)
            }
        }
        
        #elseif canImport(UIKit)
        
        if  let touchEventComponent = coComponent(TouchEventComponent.self) {
            
            if  let touchesBegan = touchEventComponent.touchesBegan {
                pointerBegan = PointerEvent(category:  .began,
                                            firstTouch: touchesBegan.touches.first,
                                            event:      touchesBegan.event,
                                            node:       touchesBegan.node)
            }
            
            if  let touchesMoved = touchEventComponent.touchesMoved {
                pointerMoved = PointerEvent(category:  .moved,
                                            firstTouch: touchesMoved.touches.first,
                                            event:      touchesMoved.event,
                                            node:       touchesMoved.node)
            }
            
            // ⚠️ TODO: CHECK: Safeguard against different touches being ended or cancelled, which may cause jumps in touch-dependent nodes when using multiple fingers.
            
            if  let touchesEnded = touchEventComponent.touchesEnded ?? touchEventComponent.touchesCancelled {
                pointerEnded = PointerEvent(category:  .ended,
                                            firstTouch: touchesEnded.touches.first,
                                            event:      touchesEnded.event,
                                            node:       touchesEnded.node)
            }
        }
        
        #endif
        
        // #4: Clear stale events whose flags have been set.
        
        // ℹ️ We cannot use `if let` unwrapping as we need to modify the actual properties themselves, not their values.
        
        if pointerBegan?.shouldClear ?? false { pointerBegan = nil }
        if pointerMoved?.shouldClear ?? false { pointerMoved = nil }
        if pointerEnded?.shouldClear ?? false { pointerEnded = nil }
        
        // #5: Flag non-`nil` events to be cleared on the next frame, so that other components do not see any stale input data.
        
        pointerBegan?.shouldClear = true
        pointerMoved?.shouldClear = true
        pointerEnded?.shouldClear = true
    }
    
    /// Discards all events and touches.
    @inlinable
    public func clearAllEvents() {
        
        // ℹ️ Since we have to set the properties themselves to `nil`, we cannot use an array etc. as that would only modify the array's members, not our properties. 2018-05-20
        
        pointerBegan = nil
        pointerMoved = nil
        pointerEnded = nil
    }
    
    @inlinable
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        clearAllEvents()
    }
}

