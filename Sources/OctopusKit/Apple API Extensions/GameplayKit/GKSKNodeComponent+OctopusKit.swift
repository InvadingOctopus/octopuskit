//
//  GKSKNodeComponent+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/11.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import GameplayKit

public extension GKSKNodeComponent {
    
    // ⚠️ NOTE: Some core OctopusKit functionality (such as accessing the onscreen node of an entity at runtime) specifically requires `GKSKNodeComponent` or `SpriteKitComponent` and may NOT work with their subclasses! See `SpriteKitComponent` documentation.
    
    /// Creates a `GKSKNodeComponent` or `SpriteKitComponent` to represent the specified node, and optionally adds the node to a parent node if specified.
    convenience init(node: SKNode,
                     addToNode newParent: SKNode?)
    {
        // Warn if the node is already a part of another entity.
        
        if  let existingNodeEntity = node.entity {
            OctopusKit.logForWarnings("\(node) is already associated with \(existingNodeEntity)")
        }
        
        self.init(node: node)
        
        // CHECK: Should it be !== or !=
        
        // If `newParent` is specified and our node isn't already its child, try adding our node to that parent.
        
        if  let newParent = newParent,
            node.parent !== newParent
        {
            
            // If the node already has a different parent, remove it from there, because that would be the expected behavior of explicitly associating it with this component and specifying a new parent.
            
            if  let existingParent = node.parent {
                
                OctopusKit.logForWarnings("\(node.name ?? String(describing: node)) already has a parent: \(existingParent) — Moving to \(newParent.name ?? String(optional: newParent))")
                
                node.removeFromParent()
            }
            
            newParent.addChild(node)
        }
        
    }
    
    /// Creates a `GKSKNodeComponent` or `SpriteKitComponent` to represent a new `SKNode` and adds it to the specified parent node at the specified position and z axis.
    convenience init(createNewNodeIn parent: SKNode,
                     position:               CGPoint = .zero,
                     zPosition:              CGFloat = 0)
    {
        let newNode       = SKNode()
        newNode.position  = position
        newNode.zPosition = zPosition
        
        self.init(node: newNode, addToNode: parent)
    }
}
