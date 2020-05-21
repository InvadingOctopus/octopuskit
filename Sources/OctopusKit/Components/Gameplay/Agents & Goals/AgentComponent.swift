//
//  AgentComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/13.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

public typealias OKAgent2D      = AgentComponent
public typealias OctopusAgent2D = AgentComponent

/// Adds a 2D agent to an entity, which may then be controlled via goal components.
///
/// When added to an entity, automatically sets the agent's `delegate` to the entity's `NodeComponent` node, and matches its initial `position` and `rotation` to the node.
public final class AgentComponent: GKAgent2D, RequiresUpdatesPerFrame {
    
    public init(radius: Float? = nil,
                mass: Float? = nil,
                maxSpeed: Float? = nil,
                maxAcceleration: Float? = nil)
    {
        super.init()
        if let radius = radius { self.radius = radius }
        if let mass = mass { self.mass = mass }
        if let maxSpeed = maxSpeed { self.maxSpeed = maxSpeed }
        if let maxAcceleration = maxAcceleration { self.maxAcceleration = maxAcceleration }
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        if self.delegate == nil {
            
            if let spriteKitComponent = coComponent(NodeComponent.self) {
                // NOTE: If you use the `GKSKNodeComponent` class to manage the relationship between an entity and a SpriteKit node, set your `GKSKNodeComponent` instance as the delegate for that entity's agent, and GameplayKit will automatically synchronize the agent and its SpriteKit representation. — https://developer.apple.com/documentation/gameplaykit/gkagentdelegate
                // `NodeComponent` is a subclass of `GKSKNodeComponent`
                self.delegate = spriteKitComponent
            }
            else {
                OctopusKit.logForWarnings("\(entity) missing NodeComponent — Cannot set delegate")
            }
            
        }
        
        // Match initial position and rotation to the node's.
        // CHECK: Is this necessary if we have set the delegate?
        
        if let node = super.entityNode {
            self.position = SIMD2<Float>(node.position)
            self.rotation = Float(node.zRotation)
        }
        else {
            OctopusKit.logForWarnings("\(entity) does not have a NodeComponent with a valid node – Cannot set initial position/rotation")
        }
    }
    
    /// Copies properties such as `radius` and `mass` from the entity's `NodeComponent` node.
    ///
    /// The `radius` is set to the greater value among the node's width or height.
    private func copyPropertiesFromNode() {
        guard let node = entityNode else { return }
        
        self.radius = Float(CGFloat.maximum(node.frame.size.width, node.frame.size.height))
        
        if let physicsBody = node.physicsBody {
            self.mass = Float(physicsBody.mass)
        }
    }
        
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        self.delegate = nil
        // self.behavior = nil // CHECK: Should we clear behavior, or keep it in case this component is re-added?
    }
    
    deinit {
        OctopusKit.logForDeinits("\(self)")
    }
}
