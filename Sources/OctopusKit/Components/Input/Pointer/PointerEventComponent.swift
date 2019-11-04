//
//  PointerEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/14, 2019/11/3.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// DECIDE: Will constantly copying over events between this component and touch/mouse components be better than simply accessing the touch or mouse event at the point of use in player-controlled components?

import SpriteKit
import GameplayKit

/// A device-agnostic component that provides abstraction for the entity's `TouchEventComponent` on iOS or `MouseEventComponent` on macOS, for relaying player input from pointer-like sources, such as touch or mouse, to other components which depend on player input.
///
/// Does not differentiate between number of touches (fingers) or type of mouse buttons.
///
/// **Dependencies:** `TouchEventComponent` on iOS, `MouseEventComponent` on macOS.
public final class PointerEventComponent: OctopusComponent, OctopusUpdatableComponent {
    
    // MARK: - Subtypes
    
    public final class PointerEvent: Equatable {
        
        // NOTE: `Equatable` conformance cannot be automatically synthesized by Swift 4.1 for classes.
        
        public let timestamp: TimeInterval
        public let node: SKNode
        public let locationInNode: CGPoint
            
        public fileprivate(set) var shouldClear: Bool = false
        
        public static func == (left: PointerEvent, right: PointerEvent) -> Bool {
            return (left.timestamp == right.timestamp
                &&  left.node      === right.node
                &&  left.locationInNode  == right.locationInNode)
        }
        
        #if canImport(AppKit)
        
        public init?(event: NSEvent? = nil,
                     node:  SKNode?  = nil)
        {
            guard
                let event = event,
                let node  = node
                else { return nil }
            
            self.timestamp = event.timestamp
            self.node = node
            self.locationInNode = event.location(in: node)
        }
        
        #endif
        
        #if canImport(UIKit)
        
        public init?(firstTouch: UITouch? = nil,
                     event:      UIEvent? = nil,
                     node:       SKNode?  = nil)
        {
            guard
                let firstTouch = firstTouch,
                let event      = event,
                let node       = node
                else { return nil }
            
            self.timestamp = event.timestamp
            self.node = node
            self.locationInNode = firstTouch.location(in: node)
        }
        
        #endif
        
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
    
    @LogInputEventChange public var pointerBegan: PointerEvent?
    @LogInputEventChange public var pointerMoved: PointerEvent?
    @LogInputEventChange public var pointerEnded: PointerEvent?
    
    
    public var latestEvent: PointerEvent? {
        [pointerBegan, pointerMoved, pointerEnded]
            .compactMap { $0 }
            .sorted { $0.timestamp > $1.timestamp }
            .first
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
        
        // #2: Mirror a `TouchEventComponent` on iOS or a `MouseEventComponent` on macOS.
        
        #if canImport(AppKit)
        
        if let mouseEventComponent = coComponent(MouseEventComponent.self) {
            
            if let mouseDown = mouseEventComponent.mouseDown {
                pointerBegan = PointerEvent(event: mouseDown.event, node: mouseDown.node)
            }
            
            if let mouseDragged = mouseEventComponent.mouseDragged {
                pointerMoved = PointerEvent(event: mouseDragged.event, node: mouseDragged.node)
            }
            
            if let mouseUp = mouseEventComponent.mouseUp {
                pointerEnded = PointerEvent(event: mouseUp.event, node: mouseUp.node)
            }
        }
        
        #elseif canImport(UIKit)
        
        if let touchEventComponent = coComponent(TouchEventComponent.self) {
            
            if let touchesBegan = touchEventComponent.touchesBegan {
                pointerBegan = PointerEvent(firstTouch: touchesBegan.touches.first,
                                            event: touchesBegan.event,
                                            node:  touchesBegan.node)
            }
            
            if let touchesMoved = touchEventComponent.touchesMoved {
                pointerMoved = PointerEvent(firstTouch: touchesMoved.touches.first,
                                            event: touchesMoved.event,
                                            node:  touchesMoved.node)
            }
            
            // ⚠️ TODO: CHECK: Safeguard against different touches being ended or cancelled, which may cause jumps in touch-dependent nodes when using multiple fingers.
            
            if let touchesEnded = touchEventComponent.touchesEnded ?? touchEventComponent.touchesCancelled {
                pointerEnded = PointerEvent(firstTouch: touchesEnded.touches.first,
                                            event: touchesEnded.event,
                                            node:  touchesEnded.node)
            }
        }
        
        #endif
        
        // #3: Clear stale events whose flags have been set.
        
        // ℹ️ We cannot use `if let` unwrapping as we need to modify the actual properties themselves, not their values.
        
        if pointerBegan?.shouldClear ?? false { pointerBegan = nil }
        if pointerMoved?.shouldClear ?? false { pointerMoved = nil }
        if pointerEnded?.shouldClear ?? false { pointerEnded = nil }
        
        // #4: Flag non-`nil` events to be cleared on the next frame, so that other components do not see any stale input data.
        
        pointerBegan?.shouldClear = true
        pointerMoved?.shouldClear = true
        pointerEnded?.shouldClear = true
    }
    
    /// Discards all events and touches.
    public func clearAllEvents() {
        
        // ℹ️ Since we have to set the properties themselves to `nil`, we cannot use an array etc. as that would only modify the array's members, not our properties. 2018-05-20
        
        pointerBegan = nil
        pointerMoved = nil
        pointerEnded = nil
    }
}

