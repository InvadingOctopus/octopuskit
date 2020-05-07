//
//  SceneComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Should this component be just replaced with `NodeComponent`?

import GameplayKit

public typealias SpriteKitSceneComponent = SceneComponent

/// An abstraction layer for accessing SpriteKit scene features via a component. This component should only be added to an `SKScene.entity` or `OKScene.entity` and is used to identify the entity as a scene to other components.
public final class SceneComponent: OKComponent {
    
    public let scene: OKScene
    
    public init(scene: OKScene) {
        self.scene = scene
        super.init()
    }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // Remove ourselves if our node is not a scene
        // ⚠️ NOTE: This does not prevent this component from being added to entities WITHOUT an `NodeComponent`/`GKSKNodeComponent`
        
        guard node is SKScene || node is OKScene // CHECK: Is checking for subclass redundant?
            else {
                OctopusKit.logForErrors("\(node) is not a scene — Detaching from entity")
                self.removeFromEntity()
                return
        }
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

