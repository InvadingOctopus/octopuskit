//
//  CameraZoomComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/09.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Set limits on scaling and maximum gestures.
// TODO: Double-tap to reset zoom to `1.0`.
// BUG: Fix wrap-around; after zooming in too much it starts to zoom out.

import SpriteKit
import GameplayKit

#if canImport(UIKit)

/// Scales the `CameraComponent` node based on input from a `PinchGestureRecognizerComponent`
///
/// **Dependencies:** `CameraComponent`, `PinchGestureRecognizerComponent`
public final class CameraZoomComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [CameraComponent.self,
                PinchGestureRecognizerComponent.self]
    }
    
    public var isPaused: Bool = false
    
    /// A flag that indicates whether there is a gesture to process in the `update(deltaTime:)` method.
    ///
    /// This prevents the component from responding to asynchronous events (such as player input) outside of the frame update cycle.
    @LogInputEventChanges(propertyName: "haveGestureToProcess")
    private var haveGestureToProcess: Bool = false
    
    private var initialCameraScale: CGFloat?
    private var initialGestureScale: CGFloat?
    
    // MARK: - Life Cycle
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let pinchGestureRecognizer = coComponent(PinchGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        pinchGestureRecognizer.addTarget(self, action: #selector(gestureEvent))
    }
    
    @objc fileprivate func gestureEvent(pinchGestureRecognizer: UIPinchGestureRecognizer) {
        
        // ℹ️ This component performs its function inside the `update(deltaTime:)` method, and just uses this event-handling action method to mark a flag to denote that an event was received. This prevents the component from being active outside the frame-update cycle, or when it's [temporarily] removed from the entity or the scene's systems.
        
        // ℹ️ DESIGN: Do not confirm if the `pinchGestureRecognizer` that sent this event is the same `PinchGestureRecognizerComponent` that is associated with this entity, in case this component may have been explicitly made the target of some other gesture recognizer, and that is allowed in the name of flexible customizability.
        
        haveGestureToProcess = true
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // Start by checking if we have a gesture to process, then clear the `haveGestureToProcess` flag regardless of any other conditions, so that the flag does not hold an stale state for future frames.
        
        guard haveGestureToProcess else { return }
        
        haveGestureToProcess = false
        
        guard
            !isPaused,
            let camera = coComponent(CameraComponent.self)?.camera,
            let pinchGestureRecognizer = coComponent(PinchGestureRecognizerComponent.self)?.gestureRecognizer
            else { return }
        
        switch pinchGestureRecognizer.state {
            
        case .began:
            self.initialCameraScale = CGFloat.maximum(camera.xScale, camera.yScale)
            self.initialGestureScale = pinchGestureRecognizer.scale
            
        case .changed:
            if
                let initialGestureScale = self.initialGestureScale,
                let initialCameraScale = self.initialCameraScale
            {
                let gestureScaleDelta = pinchGestureRecognizer.scale - initialGestureScale
                
                // ⚠️ NOTE: Have to invert `gestureScaleDelta` for correct/convential/expected behavior (moving fingers closer = zoom out, moving fingers apart = zoom in.)
                
                camera.setScale(initialCameraScale + (-gestureScaleDelta))
            }
            
        case .cancelled, .failed, .ended:
            coComponent(CameraComponent.self)?.resetBoundsConstraint()
            
        default: break
        }
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        // Remove this component from the gesture notification targets.
        
        guard let pinchGestureRecognizer = coComponent(PinchGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        pinchGestureRecognizer.removeTarget(self, action: #selector(gestureEvent)) // CHECK: Should `action` be `nil`?
    }
}

#endif

#if !canImport(UIKit)
public final class CameraZoomComponent: iOSExclusiveComponent {}
#endif
