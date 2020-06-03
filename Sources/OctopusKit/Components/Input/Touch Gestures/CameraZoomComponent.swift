//
//  CameraZoomComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Set limits on scaling and maximum gestures.
// TODO: Double-tap to reset zoom to `1.0`.
// BUG: Fix wrap-around; after zooming in too much it starts to zoom out.

import SpriteKit
import GameplayKit

#if os(iOS) // TODO: Add macOS trackpad support.

/// Scales the `CameraComponent` node based on input from a `PinchGestureRecognizerComponent`.
///
/// **Dependencies:** `CameraComponent`, `PinchGestureRecognizerComponent`
public final class CameraZoomComponent: OKComponent, RequiresUpdatesPerFrame {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [CameraComponent.self,
         PinchGestureRecognizerComponent.self]
    }
    
    public var isPaused: Bool = false
    
    /// The most recent state of the gesture recognizer as received by this component.
    ///
    /// This prevents the component from responding to asynchronous events (such as player input) outside of the frame update cycle, and also lets the component react to the ending of a gesture, because without storing it in a property, the state would revert back to `possible` by the time this component receives a frame update.
    @LogInputEventChanges(propertyName: "CameraZoomComponent.haveGestureToProcess")
    private var pinchGestureState:      UIGestureRecognizer.State = .possible
    
    private var initialCameraScale:     CGFloat?
    private var initialGestureScale:    CGFloat?
    
    /// If `true`, then the `boundsConstraint` of the `CameraComponent` is recalculated every time the zoom scale changes, ensuring that the camera remains within bounds throughout the zoom.
    ///
    /// - WARNING: May reduce performance.
    public var resetBoundsConstraintOnEveryChange = true
    
    // MARK: - Life Cycle
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let pinchGestureRecognizer = coComponent(PinchGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        pinchGestureRecognizer.addTarget(self, action: #selector(gestureEvent))
    }
    
    @objc fileprivate func gestureEvent(pinchGestureRecognizer: UIPinchGestureRecognizer) {
        
        // ℹ️ This component performs its function inside the `update(deltaTime:)` method, and just uses this event-handling action method to mark a flag to denote that an event was received. This prevents the component from being active outside the frame-update cycle, or when it's [temporarily] removed from the entity or the scene's systems.
        
        // ℹ️ DESIGN: Do not confirm if the `pinchGestureRecognizer` that sent this event is the same `PinchGestureRecognizerComponent` that is associated with this entity, in case this component may have been explicitly made the target of some other gesture recognizer, and that is allowed in the name of flexible customizability.
        
        pinchGestureState = pinchGestureRecognizer.state
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // Start by checking if we have a gesture to process, then clear the `haveGestureToProcess` flag regardless of any other conditions, so that the flag does not hold an stale state for future frames.
        
        guard
            !isPaused,
            pinchGestureState  != .possible,
            let cameraComponent = coComponent(CameraComponent.self),
            let pinchGestureRecognizer = coComponent(PinchGestureRecognizerComponent.self)?.gestureRecognizer
            else { return }
        
        let camera              = cameraComponent.camera
        
        /// ❕ NOTE: LESSON: BUG FIXED: Use the stored `pinchGestureState`, because when a gesture ends, the delay between the `gestureEvent(pinchGestureRecognizer:)` callback above and this `update(deltaTime:)` method, will cause the gesture state to return `possible` instead of `ended`.
        
        switch pinchGestureState {
            
        case .began:
            self.initialCameraScale  = CGFloat.maximum(camera.xScale, camera.yScale)
            self.initialGestureScale = pinchGestureRecognizer.scale
            
        case .changed:
            if  let initialGestureScale = self.initialGestureScale,
                let initialCameraScale  = self.initialCameraScale
            {
                let gestureScaleDelta   = pinchGestureRecognizer.scale - initialGestureScale
                
                /// ⚠️ NOTE: Have to invert `gestureScaleDelta` for correct/conventional/expected behavior (moving fingers closer = zoom out, moving fingers apart = zoom in.)
                
                camera.setScale(initialCameraScale + (-gestureScaleDelta))
                
                if  resetBoundsConstraintOnEveryChange {
                    // PERFORMANCE: may be reduced.
                    cameraComponent.resetBoundsConstraint()
                }
            }
            
        case .cancelled, .failed, .ended:
            if !resetBoundsConstraintOnEveryChange {
                cameraComponent.resetBoundsConstraint()
            }
            
        default: break
        }
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        // Remove this component from the gesture notification targets.
        
        guard let pinchGestureRecognizer = coComponent(PinchGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        pinchGestureRecognizer.removeTarget(self, action: #selector(gestureEvent)) /// CHECK: Should `action` be `nil`?
    }
}

#endif

#if !os(iOS) // TODO: Add macOS trackpad support.
public final class CameraZoomComponent: iOSExclusiveComponent {}
#endif
