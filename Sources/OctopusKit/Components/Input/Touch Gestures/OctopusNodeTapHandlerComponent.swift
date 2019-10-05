//
//  OctopusNodeTapHandlerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/20.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Base class for components which handle tap gestures on the entity's `SpriteKitComponent` node.
///
/// **Dependencies:** `SpriteKitComponent`, `TapGestureRecognizerComponent`
open class OctopusNodeTapHandlerComponent: OctopusComponent, OctopusUpdatableComponent {
    
    open override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                TapGestureRecognizerComponent.self]
    }
    
    // MARK: - Properties
    
    public var minimumNumberOfTouches: Int
    
    public var isPaused: Bool = false
    
    private var haveGestureToProcess: Bool = false {
        didSet {
            #if LOGINPUT
            if haveGestureToProcess != oldValue { debugLog("= \(oldValue) → \(haveGestureToProcess)") }
            #endif
        }
    }
    
    // MARK: - Life Cycle
    
    public init(minimumNumberOfTouches: Int = 1)
    {
        self.minimumNumberOfTouches = minimumNumberOfTouches
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let tapGestureRecognizer = coComponent(TapGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        tapGestureRecognizer.addTarget(self, action: #selector(gestureEvent))
    }
    
    @objc fileprivate func gestureEvent(tapGestureRecognizer: UITapGestureRecognizer) {
        
        // ℹ️ This component performs its function inside the `update(deltaTime:)` method, and just uses this event-handling action method to mark a flag to denote that an event was received. This prevents the component from being active outside the frame-update cycle, or when it's [temporarily] removed from the entity or the scene's systems.
        
        // ℹ️ DESIGN: Do not confirm if the `tapGestureRecognizer` that sent this event is the same `TapGestureRecognizerComponent` that is associated with this entity, in case this component may have been explicitly made the target of some other gesture recognizer, and that is allowed in the name of flexible customizability.
        
        guard
            !self.isPaused,
            tapGestureRecognizer.numberOfTouches >= minimumNumberOfTouches,
            let node = self.entityNode,
            let scene = node.scene,
            let view = scene.view
            else { return }
        
        let gestureLocation = scene.convertPoint(fromView: tapGestureRecognizer.location(in: view))
        
        if node.contains(gestureLocation) { // TODO: Verify with nested nodes and camera pans etc.
            haveGestureToProcess = true
        }
    }
    
    open override func update(deltaTime seconds: TimeInterval) {
        
        // Clear the `haveGestureToProcess` when exiting this method.
        
        defer {
            // CHECK: Make sure this is called AFTER `handleTap(deltaTime)` returns.
            haveGestureToProcess = false
        }
        
        // Pass control to the subclass if there is a tap to be handled.
        
        guard
            !self.isPaused,
            self.haveGestureToProcess,
            self.entityNode != nil
            else { return }
        
        handleTap(deltaTime: seconds)
    }
    
    /// Abstract method for subclasses to override where they can handle a tap on the entity's `SpriteKitComponent` node.
    open func handleTap(deltaTime seconds: TimeInterval) {}
    
    open override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        // Remove this component from the gesture notification targets.
        
        guard let tapGestureRecognizer = coComponent(TapGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        tapGestureRecognizer.removeTarget(self, action: #selector(gestureEvent)) // CHECK: Should `action` be `nil`?
    }
}

