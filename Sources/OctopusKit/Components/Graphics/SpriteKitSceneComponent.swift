//
//  SpriteKitSceneComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Should this component be just replaced with `SpriteKitComponent`?

import GameplayKit

/// An abstraction layer for accessing SpriteKit scene features via a component. This component should only be added to an `SKScene.entity` or `OctopusScene.entity` and is used to identify the entity as a scene to other components.
public class SpriteKitSceneComponent: OctopusComponent {
    
    public let scene: OctopusScene
    
    public init(scene: OctopusScene) {
        self.scene = scene
        super.init()
    }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // Remove ourselves if our node is not a scene
        // ⚠️ NOTE: This does not prevent this component from being added to entities WITHOUT an `SpriteKitComponent`/`GKSKNodeComponent`
        
        guard node is SKScene || node is OctopusScene // CHECK: Is checking for subclass redundant?
            else {
                OctopusKit.logForErrors.add("\(node) is not a scene — Detaching from entity")
                self.removeFromEntity()
                return
        }
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

