//
//  CameraComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/27.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Manages the camera for the scene represented by the entity's `SceneComponent`, optionally tracking an specified node and limiting the camera position within the specified bounds.
///
/// To allow the player to move the camera, use `CameraPanComponent` and `CameraZoomComponent`.
///
/// **Dependencies:** `SceneComponent`
public final class CameraComponent: NodeAttachmentComponent <SKCameraNode> {

    // TODO: Tests
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SceneComponent.self]
    }
    
    public var camera: SKCameraNode {
        didSet {
            if  camera != oldValue { // Avoid redundancy.
                super.recreateAttachmentForCurrentParent()
            }
        }
    }
    
    /// The node that the camera should follow. Sets the `cameraNode`'s position to the node's position on every `update(deltaTime:)`.
    public var nodeToTrack: SKNode? {
        didSet {
            if  nodeToTrack != oldValue { // Avoid redundant processing.
                resetTrackingConstraint()
            }
        }
    }
    
    /// Limits the camera node's position within this rectangle, if specified (in the parent (scene) coordinate space.)
    public var bounds: CGRect? {
        didSet {
            if  bounds != oldValue { // Avoid redundant processing.
                resetBoundsConstraint()
            }
        }
    }
    
    /// If `true`, the `bounds` rectangle is inset by half of the scene's width and height on each edge, to ensure that the camera does not move the viewport to the blank area outside the scene's contents.
    ///
    /// - To properly ensure that the constraints are correctly updated after the camera's scale is changed, call `resetBoundsConstraint()`.
    public var insetBoundsByScreenSize: Bool {
        didSet {
            if  insetBoundsByScreenSize != oldValue { // Avoid redundant processing.
                resetBoundsConstraint()
            }
        }
    }
    
    public fileprivate(set) var trackingConstraint: SKConstraint?
    public fileprivate(set) var boundsConstraint:   SKConstraint?
    
    // MARK: - Life Cycle
    
    public init(cameraNode:                 SKCameraNode? = nil,
                nodeToTrack:                SKNode?       = nil,
                constrainToBounds bounds:   CGRect?       = nil,
                insetBoundsByScreenSize:    Bool          = false)
    {
        self.camera      = cameraNode ?? SKCameraNode()
        self.nodeToTrack = nodeToTrack
        self.bounds      = bounds
        self.insetBoundsByScreenSize = insetBoundsByScreenSize
        
        super.init()
        
        // NOTE: Property observers are not notified in init
        // Set constraints now even before the component is added to an entity, in case the specified `camera` node is already in a scene.
        
        resetConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
 
    public override func createAttachment(for parent: SKNode) -> SKCameraNode? {
        return self.camera
    }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        guard let scene = coComponent(SceneComponent.self)?.scene else {
            OKLog.logForErrors.debug("\(📜("\(entity) missing SceneComponent – Cannot assign camera"))")
            return
        }
        
        // Issue warning if we're replacing another camera.
        // CHECK: Necessary?
        
        if  scene.camera != nil
        &&  scene.camera != self.camera
        {
            OKLog.logForWarnings.debug("\(📜("\(scene) already has \(scene.camera) — Replacing with \(self.camera)"))")
        }
        
        scene.camera = self.camera
        resetConstraints()
    }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        super.willRemoveFromEntity(withNode: node)
        guard let scene = coComponent(SceneComponent.self)?.scene else { return }
        
        // ℹ️ DESIGN: If the scene has a different camera by now, remove it anyway, since that would be the expected behavior when removing this component.
        
        if  scene.camera !== self.camera {
            OKLog.logForWarnings.debug("\(📜("\(scene) has a different camera that is not associated with this component: \(scene.camera) — Removing"))")
        }
        
        scene.camera = nil
    }
    
    // MARK: - Constraints
    
    /// Recreates the tracking and bounds constraints and reapplies them to the camera.
    public func resetConstraints() {
        // NOTE: Apply the bounds constraint last (to override tracking), because constraints are processed in array order.
        
        if  self.nodeToTrack != nil {
            resetTrackingConstraint()
        }
        
        if  self.bounds != nil {
            resetBoundsConstraint()
        }
    }
    
    // MARK: Tracking
    
    public func resetTrackingConstraint() {
        
        // Remove existing tracking constraint, if any.
        
        if  let existingTrackingConstraint = self.trackingConstraint,
            var constraints = camera.constraints,
            let indexToRemove = constraints.firstIndex(of: existingTrackingConstraint)
        {
            existingTrackingConstraint.enabled = false // CHECK: Necessary?
            constraints.remove(at: indexToRemove)
        }
        
        self.trackingConstraint = nil
        
        // Apply new tracking constraint, if applicable.
        
        if  let nodeToTrack = self.nodeToTrack {
            // Constrain the camera to stay a constant distance of 0 points from the player node.
            self.trackingConstraint = SKConstraint.distance(.zero, to: nodeToTrack)
        }
        
        if  let trackingConstraint = self.trackingConstraint {
            
            // Create a new constraints array if the node has none.
            if camera.constraints == nil { camera.constraints = [] }
            
            camera.constraints?.append(trackingConstraint)
        }
    }
    
    // MARK: Bounds
    
    /// - Important: If `bounds` are specified, this method must be called again if the camera's scale is later changed.
    public func resetBoundsConstraint() {
        
        // Remove existing bounds constraint, if any.
        
        if  let existingBoundsConstraint = self.boundsConstraint,
            var constraints   = camera.constraints,
            let indexToRemove = constraints.firstIndex(of: existingBoundsConstraint)
        {
            existingBoundsConstraint.enabled = false // CHECK: Necessary?
            constraints.remove(at: indexToRemove)
        }
        
        self.boundsConstraint = nil
        
        // Apply new bounds constraint, if applicable.
        
        if  let bounds = self.bounds {
            self.boundsConstraint = createBoundsConstraint(to: bounds)
        }
        
        if  let boundsConstraint = self.boundsConstraint {
            
            // Create a new constraints array if the node has none.
            if camera.constraints == nil { camera.constraints = [] }
            
            camera.constraints?.append(boundsConstraint)
        }
    }
    
    public func createBoundsConstraint(to bounds: CGRect) -> SKConstraint {
        
        // TODO: Test and confirm various configurations.
        // TODO: Test `frame` vs. `size` etc.
        // DECIDE: Implement automatic recalculation when camera's scale changes?
        
        // CREDIT: Apple DemoBots Sample
        
        let xRange, yRange: SKRange
        
        if  self.insetBoundsByScreenSize,
            let scene = camera.scene
        {
            let screenSize = scene.size
            
            // Constrain the camera to avoid it moving to the very edges of the scene.
            // First, work out the scaled size of the screen and camera.
            let scaledScreenSize = CGSize(width:  screenSize.width  * camera.xScale,
                                          height: screenSize.height * camera.yScale)
            
            let xInset = min(scaledScreenSize.width  / 2, bounds.width / 2)
            let yInset = min(scaledScreenSize.height / 2, bounds.height / 2)
            
            // Use these insets to create a smaller inset rectangle within which the camera must stay.
            let insetBounds = bounds.insetBy(dx: xInset, dy: yInset)
            
            // Define an `SKRange` for each of the x and y axes to stay within the inset rectangle.
            xRange = SKRange(lowerLimit: insetBounds.minX, upperLimit: insetBounds.maxX)
            yRange = SKRange(lowerLimit: insetBounds.minY, upperLimit: insetBounds.maxY)
    
        } else {
            xRange = SKRange(lowerLimit: bounds.minX, upperLimit: bounds.maxX)
            yRange = SKRange(lowerLimit: bounds.minY, upperLimit: bounds.maxY)
        }
        
        // Constrain the camera within the inset rectangle.
        let boundsConstraint = SKConstraint.positionX(xRange, y: yRange)
        boundsConstraint.referenceNode = camera.parent
        
        return boundsConstraint
    }
    
}
