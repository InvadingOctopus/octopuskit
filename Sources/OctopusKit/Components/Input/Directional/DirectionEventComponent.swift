//
//  DirectionEventComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/25.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A `CGVector` that represents a directional input from a keyboard, gamepad, joystick or similar controllers.
public typealias OKInputDirection = CGVector

public typealias OctopusInputDirection = OKInputDirection

/// Provides an abstraction layer for directional input from a keyboard, gamepad, joystick, or similar controllers.
public final class DirectionEventComponent: OKComponent, OKUpdatableComponent {
    
    // MARK: - Subtypes

    /// A controller with directional inputs.
    public enum DirectionEventSource {
        case keyboard
        // TODO: case gamepad
        // TODO: case joystick
        // TODO: case onscreen
    }
    
    // MARK: - Properties
    
    public var eventSource: DirectionEventSource
    
    // MARK: Keyboard Codes
    
    /// Change this to a different code to customize the keys.
    public var arrowUp:     UInt16 = .arrowUp
    /// Change this to a different code to customize the keys.
    public var arrowRight:  UInt16 = .arrowRight
    /// Change this to a different code to customize the keys.
    public var arrowDown:   UInt16 = .arrowDown
    /// Change this to a different code to customize the keys.
    public var arrowLeft:   UInt16 = .arrowLeft

    // MARK: Events
                
    // DESIGN: These properties are not private(set) so update(deltaTime:) can be @inlinable
    
    /// A set of the directions that were included in the `directionBegan` events received in the current frame.
    public var directionsBeganForCurrentFrame: Set<OKInputDirection> = [] {
        didSet {
            // Add any new directions to the list of directions that are active.
            self.directionsActive.formUnion(directionsBeganForCurrentFrame)
        }
    }
    
    /// A set of the directions that were included in the `directionEnded` events received in the current frame.
    public var directionsEndedForCurrentFrame: Set<OKInputDirection> = [] {
        didSet {
            // Remove the ending directions from the list of directions that are active.
            self.directionsActive.subtract(directionsEndedForCurrentFrame)
        }
    }
    
    /// A set of the directions that were included in all `directionBegan` events received so far but not in any `directionEnded` events yet.
    public var directionsActive: Set<OKInputDirection> = []
    
    /// The final vector after adding all the active directions, i.e. cancelling out opposing inputs.
    @inlinable
    public var combinedDirection: OKInputDirection {
        directionsActive.reduce(.zero, +)
    }
    
    public init(source: DirectionEventSource) {
        self.eventSource = source
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Frame Cycle

    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
  
        // #1: Discard all events if we are part of a scene that has displayed or dismissed a subscene in this frame.
        // CHECK: Necessary? Useful?
        
        if  let scene = coComponent(SceneComponent.self)?.scene,
            scene.didPresentSubsceneThisFrame || scene.didDismissSubsceneThisFrame
        {
            clearLists()
            return
        }
        
        // #2: Clear any leftover events from previous frames.
        
        clearLists()
        
        // #3: Copy events from the specified source.
        
        switch self.eventSource {
        case .keyboard: copyKeyboardEvents()
        }
    }
    
    #if canImport(AppKit)
    @inlinable
    public func copyKeyboardEvents() {
        // Not private(set) so update(deltaTime:) can be @inlinable
        guard let keyboardEventComponent = coComponent(KeyboardEventComponent.self) else { return }
        
        // TODO: Reduce code duplication
        
        keyboardEventComponent.codesDownForCurrentFrame.forEach { code in
            switch code {
            case .arrowUp:      directionsBeganForCurrentFrame.insert(.up)
            case .arrowRight:   directionsBeganForCurrentFrame.insert(.right)
            case .arrowDown:    directionsBeganForCurrentFrame.insert(.down)
            case .arrowLeft:    directionsBeganForCurrentFrame.insert(.left)
            default:            break
            }
        }
        
        keyboardEventComponent.codesUpForCurrentFrame.forEach { code in
            switch code {
            case .arrowUp:      directionsEndedForCurrentFrame.insert(.up)
            case .arrowRight:   directionsEndedForCurrentFrame.insert(.right)
            case .arrowDown:    directionsEndedForCurrentFrame.insert(.down)
            case .arrowLeft:    directionsEndedForCurrentFrame.insert(.left)
            default:            break
            }
        }
    }
    #endif

    #if !canImport(AppKit)
    /// An empty, dummy function if not running on macOS.
    @inlinable public func copyKeyboardEvents() {}
    #endif
    
    /// Clears all events.
    @inlinable
    public func clearLists() {
        // CHECK: PERFORMANCE: Should we be `keepingCapacity`?
        directionsBeganForCurrentFrame  .removeAll(keepingCapacity: true)
        directionsEndedForCurrentFrame  .removeAll(keepingCapacity: true)
    }
    
    @inlinable
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        directionsBeganForCurrentFrame  .removeAll(keepingCapacity: false)
        directionsEndedForCurrentFrame  .removeAll(keepingCapacity: false)
        directionsActive                .removeAll(keepingCapacity: false)
    }
}

