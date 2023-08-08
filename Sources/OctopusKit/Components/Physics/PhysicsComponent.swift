//
//  PhysicsComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import GameplayKit
import OSLog

/// Encapsulates an `SKPhysicsBody` and maintains its properties to the specified values, if any.
///
/// Replaces the `physicsBody` of its entity's `NodeComponent`'s node with the `physicsBody` supplied to this component. If this component's `physicsBody` is `nil`, then this component adopts the `physicsBody` of the `NodeComponent`'s node.
///
/// **Dependencies:** `NodeComponent`
public final class PhysicsComponent: OKComponent, RequiresUpdatesPerFrame {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self]
    }
    
    // MARK: Properties
    
    /// Sets the body of the entity's `NodeComponent` node, and represents the node's current body.
    public var physicsBody: SKPhysicsBody? {
        // CHECK: Should this be weak?
        
        didSet {
            /// If we're part of an entity that has a `NodeComponent` node,
            if  let node = entityNode {
                
                //  And this component was supplied with a new physics body,
                if  self.physicsBody != nil {

                    // Then use existing logic (which makes sure to avoid conflicts such as the body already being associated with a different node) to try to assign our body to the node.
                    assignBody(to: node)
                }
                    
                /// Otherwise, if our body was set to `nil`, then set the node's body to `nil` as well, as this would be the expected behavior of modifying the `PhysicsComponent` of an entity with an existing node.
                else if self.physicsBody == nil {
                    node.physicsBody = nil
                }
            }
        }
    }
    
    /// The scalar to limit the velocity of the `physicsBody` to, on every frame update.
    public var maximumVelocity: CGFloat?
    
    /// The angular velocity in Newton-meters to limit the `physicsBody` to, on every frame update.
    public var maximumAngularVelocity: CGFloat?
    
    /// Overrides this component's `physicsBody` property and creates a new rectangular `SKPhysicsBody` from the frame of the entity's `NodeComponent` node.
    ///
    /// As creating physics bodies may be a costly runtime operation, this setting defaults to `false`.
    public var createBodyFromNodeFrame: Bool = false
    
    /// If `true`, this component will allow settings its `physicsBody` property to the body of a node which is not the entity's `NodeComponent` node. Useful for specifying the body of a child node of the entity's node.
    public var allowBodyFromDifferentNode: Bool = false
    
    // MARK: Initialization
    
    /// Creates a component that either adds a new physics body to the entity's `NodeComponent` node, or represents the node's current body.
    /// - Parameters:
    ///   - physicsBody:                Specifies the body to assign to the entity's `NodeComponent` node. If `nil`, then this component will represent the node's current body, if any. Default: `nil`
    ///   - createBodyFromNodeFrame:    If `true` and if neither this component nor the entity's `NodeComponent` node have a `physicsBody`, a rectangular body is created from the node's `frame` property. Default: `false`
    ///   - maximumVelocity:            Clamps the body's `velocity` to the specified limit, if any, on `update(deltaTime:)` every frame. Default: `nil`
    ///   - maximumAngularVelocity:     Clamps the body's `angularVelocity` to the specified limit, if any, on `update(deltaTime:)` every frame. Default: `nil`
    ///   - allowBodyFromDifferentNode: If `true`, there will be no error raised by setting this component's `physicsBody` property to the body of a node which is not the entity's `NodeComponent` node. This may be useful in cases where this component must represent the body of a child node of the entity's node.
    ///
    ///     **Example:** If the entity's node is a `SKNode` containing a sprite and its shadow, then the `physicsBody` represented by this component must be on the sprite and not include the shadow.
    public init(physicsBody:             SKPhysicsBody? = nil,
                createBodyFromNodeFrame: Bool           = false,
                maximumVelocity:         CGFloat?       = nil,
                maximumAngularVelocity:  CGFloat?       = nil,
                allowBodyFromDifferentNode: Bool        = false)
    {
        self.physicsBody             = physicsBody
        self.createBodyFromNodeFrame = createBodyFromNodeFrame
        self.maximumVelocity         = maximumVelocity
        self.maximumAngularVelocity  = maximumAngularVelocity
        self.allowBodyFromDifferentNode = allowBodyFromDifferentNode
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        /// If `createBodyFromNodeFrame` is set and neither this component nor the entity's node have a physics body, then create a new rectangular body from the node's frame.
        
        if  createBodyFromNodeFrame
            && (self.physicsBody == nil && node.physicsBody == nil)
        {
            /// NOTE: CHECK: PERFORMANCE: Is this a costly operation? Should `createBodyFromNodeFrame` be `true` or `false` by default?
            
            OctopusKit.logForDebug("\(self) creating new physicsBody from the frame of \(String(describing: node))") // Not a warning because this would be the expected behavior of adding a `PhysicsComponent` with no arguments to a fresh entity/node.
            
            /// CHECK: Should this be `calculateAccumulatedFrame()`?
            
            /// WARNING: ⚠️ Some nodes like `SKNode` have a zero-sized `frame`!
            
            self.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
            
            /// ℹ️ Setting our `physicsBody` should call `assignBody(to: node)` via the property observer now.
            
        } else {
            assignBody(to: node)
        }
    }
    
    // MARK: Sync
    
    /// Syncs the `physicsBody` that this component represents, with the `physicsBody` of the entity's `NodeComponent`, and performs validation checks.
    @inlinable
    public func assignBody(to node: SKNode) {
        
        // TODO: Test all scenarios! (component's body, node's body, body's node, etc.)
        
        // This is a separate method so that the `physicsBody` `didSet` can call it without superfluously logging a `didAddToEntity(withNode:)` call.
        
        // First off, are we already in sync? Then there's nothing to do here!
        
        guard self.physicsBody !== node.physicsBody else { return }
        
        // Next check: Does the node already have a body and this component doesn't?
            
        if  self.physicsBody == nil && node.physicsBody != nil {
            
            // Then adopt the node's body as this component's body.
            
            OKLog.logForDebug.debug("\(📜("\(self) missing physicsBody — Adopting from \(node.name ?? String(describing: node))"))")
            
            self.physicsBody = node.physicsBody
        }
            
        // Otherwise, if we have a body and the node doesn't, try to assign our body to the node.
            
        else if let physicsBody = self.physicsBody, node.physicsBody == nil {
            
            // NOTE: ONLY IF our body is not already associated with a different node in the scene!
            
            if  physicsBody.node == nil {
                node.physicsBody = self.physicsBody
            
            } else if physicsBody.node! != node {
                
                /// If our body's node is not the entity's `NodeComponent` node, log an error and detach from the entity, as an `PhysicsComponent` with a body that belongs to another node, *may* be invalid/undesired behavior in most cases.
                
                if !allowBodyFromDifferentNode {
                    OKLog.logForErrors.debug("\(📜("\(physicsBody) already associated with \(physicsBody.node!) — Detaching from entity. If this is intentional, set the `allowBodyFromDifferentNode` flag."))")
                    self.removeFromEntity()
                    return
                    
                } else {
                    
                    /// **However,** if the `allowBodyFromDifferentNode` flag is set, then this may be a case where this `PhysicsComponent` represents a body which belongs to a *child* node of the entity's node tree.
                    /// In that case, just warn if the body is not part of the entity's hierarchy.
                    
                    if !physicsBody.node!.inParentHierarchy(node) {
                        OKLog.logForWarnings.debug("\(📜("\(physicsBody) already associated with \(physicsBody.node!) which is not in the hierarchy of \(node) — This may not be the desired behavior."))")
                        return
                    }
                }
            }
        }
            
        // If this component has a body and the node also has a body, and they're different, log a warning, then replace the node's body with this component's body, as that would be the expected behavior of adding a `PhysicsComponent` to an entity with an existing node.
            
        else if self.physicsBody != nil && node.physicsBody != nil && self.physicsBody !== node.physicsBody {
            
            OKLog.logForWarnings.debug("\(📜("Mismatching bodies: \(self) has \(self.physicsBody), \(node.name ?? String(describing: node)) has \(node.physicsBody) — Replacing node's body"))")
            
            node.physicsBody = self.physicsBody
        }
    }
    
    // MARK: Update
    
    public override func update(deltaTime seconds: TimeInterval) {

        guard let physicsBody = self.physicsBody else { return }
        
        if  let maximumVelocity = self.maximumVelocity {
            physicsBody.velocity.clampMagnitude(to: maximumVelocity)
        }

        if  let maximumAngularVelocity = self.maximumAngularVelocity,
            abs(physicsBody.angularVelocity) > maximumAngularVelocity
        {
            // CHECK: Find a better way?
            physicsBody.angularVelocity = maximumAngularVelocity * CGFloat(sign(Float(physicsBody.angularVelocity)))
        }
    }
    
    // MARK: Removal
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        
        if  let nodePhysicsBody = node.physicsBody,
            nodePhysicsBody !== self.physicsBody
        {
            OKLog.logForWarnings.debug("\(📜("\(node.name ?? String(describing: node)) had a different physicsBody than this component – Removing"))")
        }
        
        // Remove the physicsBody even if the node had a different one, to keep the expected behavior of removing physics from the node when a PhysicsComponent is removed.
        
        node.physicsBody = nil
    }
    
}
