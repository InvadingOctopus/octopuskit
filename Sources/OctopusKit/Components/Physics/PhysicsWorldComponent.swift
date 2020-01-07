//
//  PhysicsWorldComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/27.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Retains a reference to the `physicsWorld` of an `SKScene` to be used by other components. Must be assigned to an entity with an `SpriteKitSceneComponent`. If the `physicsWorld` has no `contactDelegate` then it's set to the scene, if the scene conforms to `SKPhysicsContactDelegate` (as `OKScene` always does.)
///
/// **Dependencies:** `SpriteKitSceneComponent`
public final class PhysicsWorldComponent: OKComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitSceneComponent.self]
    }
    
    public weak var physicsWorld: SKPhysicsWorld? // CHECK: Should this be weak?
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        
        guard let scene = coComponent(SpriteKitSceneComponent.self)?.scene  else {
            OctopusKit.logForWarnings.add("\(entity) missing SpriteKitSceneComponent – Cannot assign physicsWorld")
            return
        }
        
        self.physicsWorld = scene.physicsWorld
        
        if  scene.physicsWorld.contactDelegate == nil {
            scene.physicsWorld.contactDelegate = scene // as? SKPhysicsContactDelegate
        }
        else if scene.physicsWorld.contactDelegate !== scene {
            OctopusKit.logForWarnings.add("\(scene.physicsWorld) has a contactDelegate that is not \(scene)")
        }
        
        // If the physics simulation is paused, start it, as this would be the expected behavior upon adding a `PhysicsWorld` component.
        // NOTE: If the world is NOT paused, then leave the speed as is, in case it was directly slowed down or sped up before this component was added.
        
        if  let physicsWorld = self.physicsWorld, physicsWorld.speed <= 0 {
            physicsWorld.speed = 1
        }
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        // Stop the physics simulation as this would be the expected behavior upon removing a `PhysicsWorld` component.
        self.physicsWorld?.speed = 0
        self.physicsWorld = nil
    }

}

