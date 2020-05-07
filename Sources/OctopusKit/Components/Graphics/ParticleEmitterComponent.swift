//
//  ParticleEmitterComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Adds a `SKEmitterNode` to the entity's `NodeComponent` node.
///
/// **Dependencies:** `NodeComponent`
public final class ParticleEmitterComponent: NodeAttachmentComponent<SKEmitterNode> {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self]
    }
    
    public var emitterNode: SKEmitterNode
    
    public init(emitterNode: SKEmitterNode) {
        self.emitterNode = emitterNode
        super.init()
        self.attachment = self.emitterNode
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // ℹ️ If the emitter's parent node has a parent, set the grandparent as the emitter's target node (but don't let the target node be set to `nil` in case it was already set to something). This ensures that this component will function correctly even if it's added to an `SKScene`, which has no parent.
        
        if let parent = node.parent {
            emitterNode.targetNode = parent
        }
    }
}
