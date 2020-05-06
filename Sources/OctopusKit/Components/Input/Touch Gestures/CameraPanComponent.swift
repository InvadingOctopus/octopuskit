//
//  CameraPanComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Subscene support.
// TODO: Improve inertial scrolling.

// CHECK: Should this component directly handle the gesture events itself (which may be many of during a single frame), or just poll the gesture recognizer in its `update(deltaTime:)` method for efficiency? (but that causes problems with missed states, such as `.ended`)

// CHECK: Uniform names across properties? "movement", "scrolling", "panning"

import SpriteKit
import GameplayKit

#if os(iOS) // TODO: Add macOS trackpad support.

/// Moves the `CameraComponent` node based on input from a `PanGestureRecognizerComponent`
///
/// - Important: The `CameraPanComponent` must be updated before `PanGestureRecognizerComponent` ??
///
/// **Dependencies:** `CameraComponent`, `PanGestureRecognizerComponent`, `SpriteKitSceneComponent`
public final class CameraPanComponent: OKComponent, OKUpdatableComponent {
    
    public static let inertialMovementKey = "OctopusKit.CameraPanComponent.Move"
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitSceneComponent.self,
         CameraComponent.self,
         PanGestureRecognizerComponent.self]
    }
    
    /// The minimum number of touches for a pan gesture to be processed.
    ///
    /// - NOTE: This value is distinct from the `minimumNumberOfTouches` property of the `UIPanGestureRecognizer` so that a `CameraPanComponent` may specify its own minimum.
    ///
    /// - IMPORTANT: The `UIPanGestureRecognizer` will only register gestures that meet its own `minimumNumberOfTouches` property.
    public var minimumNumberOfTouches: Int
    
    public var isPaused: Bool = false
    
    @LogInputEventChanges(propertyName: "CameraPanComponent.isPanning")
    public var isPanning: Bool = false
    
    /// If `true`, the camera will slide for a distance depending on the panning velocity at the end of the gesture.
    public var isInertialScrollingEnabled: Bool
    
    /// Inverts content movement on the X axis.
    ///
    /// By default this is `false`, when means panning right moves the camera to the *left*, but the scene's contents move to the right, which is the "natural" panning behavior and the OS default.
    public var invertXAxis: Bool
    
    /// Inverts content movement on the Y axis.
    ///
    /// By default this is `false`, when means panning up moves the camera *down*, but the scene's contents move up, which is the "natural" panning behavior and the OS default.
    public var invertYAxis: Bool
    
    @LogInputEventChanges(propertyName: "CameraPanComponent.initialCameraPosition")
    private var initialCameraPosition: CGPoint? = nil
    
    /// A flag that indicates whether there is a gesture to process for the `update(deltaTime:)` method.
    ///
    /// This prevents the component from responding to asynchronous events (such as player input) outside of the frame update cycle.
    @LogInputEventChanges(propertyName: "CameraPanComponent.haveGestureToProcess")
    private var haveGestureToProcess: Bool = false
    
    // MARK: - Life Cycle
    
    public init(minimumNumberOfTouches: Int = 2,
                isInertialScrollingEnabled: Bool = true,
                invertXAxis: Bool = false,
                invertYAxis: Bool = false)
    {
        self.minimumNumberOfTouches = minimumNumberOfTouches
        self.isInertialScrollingEnabled = isInertialScrollingEnabled
        self.invertXAxis = invertXAxis
        self.invertYAxis = invertYAxis
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let panGestureRecognizer = coComponent(PanGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        panGestureRecognizer.addTarget(self, action: #selector(gestureEvent))
    }
    
    @objc fileprivate func gestureEvent(panGestureRecognizer: UIPanGestureRecognizer) {
        
        // ℹ️ This component performs its function inside the `update(deltaTime:)` method, and just uses this event-handling action method to mark a flag to denote that an event was received. This prevents the component from being active outside the frame-update cycle, or when it's [temporarily] removed from the entity or the scene's systems.
        
        // ℹ️ DESIGN: Do not confirm if the `panGestureRecognizer` that sent this event is the same `PanGestureRecognizerComponent` that is associated with this entity, in case this component may have been explicitly made the target of some other gesture recognizer, and that is allowed in the name of flexible customizability.
    
        guard panGestureRecognizer.numberOfTouches >= self.minimumNumberOfTouches else { return }
        haveGestureToProcess = true
        
        if panGestureRecognizer.state == .ended {
            self.isPanning = false
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // Start by checking if we have a gesture to process, then clear the `haveGestureToProcess` flag regardless of any other conditions, so that the flag does not hold a stale state for future frames.
        
        guard haveGestureToProcess else { return }
        
        haveGestureToProcess = false
        
        guard
            !isPaused,
            let camera = coComponent(CameraComponent.self)?.camera,
            let scene = coComponent(SpriteKitSceneComponent.self)?.scene,
            !scene.didPresentSubsceneThisFrame || !scene.didDismissSubsceneThisFrame,
            let view = scene.view,
            let panGestureRecognizer = coComponent(PanGestureRecognizerComponent.self)?.gestureRecognizer
            else { return }
        
        // CHECK: Should we get the translation for the scene's view or the recognizer's view?
        
        // ℹ️ DESIGN: The "natural" panning behavior is for the content to move in the direction of the pan, as in the system Photos app for example.
        
        // ⚠️ NOTE: "The x and y values report the total translation over time. They are not delta values from the last time that the translation was reported. Apply the translation value to the state of the view when the gesture is first recognized—do not concatenate the value each time the handler is called." https://developer.apple.com/documentation/uikit/uipangesturerecognizer/1621207-translation
        // This is why we use `initialCameraPosition`
        
        // NOTE: A UIKit view's coordinate system (Y increases downward) is different from the SpriteKit coordinate system (Y increases upward). So we have to "fix" the Y axis.
        
        switch panGestureRecognizer.state {
            
        case .began:
            #if LOGINPUTEVENTS
            debugLog("state = began")
            #endif
            
            self.initialCameraPosition = camera.position
            self.isPanning = true
            
        case .changed:
            #if LOGINPUTEVENTS
            debugLog("state = changed")
            #endif
            
            if let initialCameraPosition = self.initialCameraPosition {
                
                // ℹ️ Do not convert the point from the view to the scene, since we just want to look at the touches in relation to the static view, and pan the scene "underneath" the view.
                
                var translation = panGestureRecognizer.translation(in: view)
                
                // See comment about coordinate systems and axis inversion above.
                if invertYAxis { translation.y = -translation.y }
                if !invertXAxis { translation.x = -translation.x }
                
                camera.position = initialCameraPosition + translation
            }
            
            self.isPanning = true
            
            // CHECK: Useful? // panGestureRecognizer.setTranslation(CGPoint.zero, in: sceneView)
            
        case .ended:
            #if LOGINPUTEVENTS
            debugLog("state = ended")
            #endif
            
            self.initialCameraPosition = nil // CHECK: Necessary?
            
            if isInertialScrollingEnabled {
                
                // ℹ️ Do not convert the point from the view to the scene, since we just want to look at the touches in relation to the static view, and pan the scene "underneath" the view.
                
                var velocity = panGestureRecognizer.velocity(in: view)
                
                // See comment about coordinate systems and axis inversion above.
                if invertYAxis { velocity.y = -velocity.y }
                if !invertXAxis { velocity.x = -velocity.x }
                
                // Calculate the inertial velocity and slide duration.
                // CREDIT: https://stackoverflow.com/a/6687064
                
                velocity = CGPoint(x: velocity.x * 0.2,
                                   y: velocity.y * 0.2)
                
                let inertialScrollDuration = (CGFloat.maximum(abs(velocity.x), abs(velocity.y)) * 0.0002) + 0.2
                
                let inertialSlide = SKAction.moveBy(x: velocity.x,
                                                    y: velocity.y,
                                                    duration: TimeInterval(inertialScrollDuration))
                
                camera.run(inertialSlide.timingMode(.easeOut),
                           withKey: CameraPanComponent.inertialMovementKey)
            }
            
        default: break
        }
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        // Remove this component from the gesture notification targets.
        
        guard let panGestureRecognizer = coComponent(PanGestureRecognizerComponent.self)?.gestureRecognizer else { return }
        
        panGestureRecognizer.removeTarget(self, action: #selector(gestureEvent)) // CHECK: Should `action` be `nil`?
        
        // Reset flags.
        
        self.haveGestureToProcess = false
        self.isPanning = false
    }
}

#endif

#if !os(iOS) // TODO: Add macOS trackpad support.
public final class CameraPanComponent: iOSExclusiveComponent {}
#endif
