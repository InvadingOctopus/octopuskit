//
//  PhysicsComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Encapsulates an `SKPhysicsBody` and maintains its properties to the specified values, if any.
///
/// Replaces the `physicsBody` of its entity's `NodeComponent`'s node with the `physicsBody` supplied to this component. If this component's `physicsBody` is `nil`, then this component adopts the `physicsBody` of the `NodeComponent`'s node.
///
/// **Dependencies:** `NodeComponent`
public final class PhysicsComponent: OKComponent, RequiresUpdatesPerFrame {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self]
    }
    
    public var physicsBody: SKPhysicsBody? {
        // CHECK: Should this be weak?
        
        didSet {
            //  If we're part of an entity that has a SpriteKit node,
            if  let node = entityNode {
                
                //  And this component was supplied with a new physics body,
                if  self.physicsBody != nil {

                    // Then use existing logic (which makes sure to avoid conflicts such as the body already being associated with a different node) to try to assign our body to the node.
                    assignBody(to: node)
                }
                    
                // Otherwise, if our body was set to `nil`, then set the node's body to `nil` as well, as this would be the expected behavior of modifying the `PhysicsComponent` of an entity with an existing node.
                else if self.physicsBody == nil {
                    node.physicsBody = nil
                }
            }
        }
    }
    
    /// The scalar to limit the velocity of the `physicsBody` to.
    public var maximumVelocity: CGFloat?
    
    /// The angular velocity in Newton-meters to limit the `physicsBody` to.
    public var maximumAngularVelocity: CGFloat?
    
    /// Overrides this component's `physicsBody` property and creates a new rectangular `SKPhysicsBody` from the frame of the entity's `NodeComponent` node.
    ///
    /// As creating physics bodies may be a costly runtime operation, this setting defaults to `false`.
    public var createBodyFromNodeFrame: Bool = false
    
    public init(physicsBody:             SKPhysicsBody? = nil,
                createBodyFromNodeFrame: Bool           = false,
                maximumVelocity:         CGFloat?       = nil,
                maximumAngularVelocity:  CGFloat?       = nil)
    {
        self.physicsBody             = physicsBody
        self.createBodyFromNodeFrame = createBodyFromNodeFrame
        self.maximumVelocity         = maximumVelocity
        self.maximumAngularVelocity  = maximumAngularVelocity
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // If `createBodyFromNodeFrame` is set and neither this component nor the entity's node have a physics body, then create a new rectangular body from the node's frame.
        
        if  createBodyFromNodeFrame
            && (self.physicsBody == nil && node.physicsBody == nil)
        {
            // NOTE: CHECK: Is this a costly operation? Should `createBodyFromNodeFrame` be `true` or `false` by default?
            
            OctopusKit.logForDebug("\(self) creating new physicsBody from the frame of \(String(describing: node))") // Not a warning because this would be the expected behavior of adding a `PhysicsComponent` with no arguments to a fresh entity/node.
            
            self.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
            
            // Setting our `physicsBody` should call `assignBody(to: node)` via the property observer now.
            
        } else {
            assignBody(to: node)
        }
    }
    
    public func assignBody(to node: SKNode) {
        // This is a separate method so that the `physicsBody` `didSet` can call it without superfluously logging a `didAddToEntity(withNode:)` call.
        
        // TODO: Test all scenarios! (component's body, node's body, body's node, etc.)
        
        // Sync the `physicsBody` that this component represents, with the `physicsBody` of the SpriteKit node associated with this component's entity.
        
        // First off, are we already in sync? Then there's nothing to do here!
        
        guard self.physicsBody !== node.physicsBody else { return }
        
        // Next check: Does the node already have a body and this component doesn't?
            
        if  self.physicsBody == nil && node.physicsBody != nil {
            
            // Then adopt the node's body as this component's body.
            
            OctopusKit.logForDebug("\(self) missing physicsBody — Adopting from \(node.name ?? String(describing: node))")
            
            self.physicsBody = node.physicsBody
        }
            
        // Otherwise, if we have a body and the node doesn't, try to assign our body to the node.
            
        else if let physicsBody = self.physicsBody, node.physicsBody == nil {
            
            // NOTE: ONLY IF our body is not already associated with a different node in the scene!
            
            if  physicsBody.node == nil {
                node.physicsBody = self.physicsBody
            
            } else if physicsBody.node! != node {
                // ℹ️ DESIGN: Log an error and detach from the entity, as an `PhysicsComponent` with a body that belongs to another node, has no valid behavior.
                OctopusKit.logForErrors("\(physicsBody) already associated with \(physicsBody.node!) — Detaching from entity")
                self.removeFromEntity()
                return
            }
        }
            
        // If this component has a body and the node also has a body, and they're different, log a warning, then replace the node's body with this component's body, as that would be the expected behavior of adding a `PhysicsComponent` to an entity with an existing node.
            
        else if self.physicsBody != nil && node.physicsBody != nil && self.physicsBody !== node.physicsBody {
            
            OctopusKit.logForWarnings("Mismatching bodies: \(self) has \(self.physicsBody), \(node.name ?? String(describing: node)) has \(node.physicsBody) — Replacing node's body")
            
            node.physicsBody = self.physicsBody
        }
    }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        
        if  let nodePhysicsBody = node.physicsBody,
            nodePhysicsBody !== self.physicsBody
        {
            OctopusKit.logForWarnings("\(node.name ?? String(describing: node)) had a different physicsBody than this component – Removing")
        }
        
        // Remove the physicsBody even if the node had a different one, to keep the expected behavior of removing physics from the node when a PhysicsComponent is removed.
        
        node.physicsBody = nil
    }
    
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
}
