//
//  EntityEmitterComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/06/05.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Signals the entity of this component to spawn a new entity, in the direction of the the node associated with this component, and applies the specified initial velocity to the new entity's physics body if there is one.
///
/// Useful for launching projectiles (such as bullets or missiles) from a character.
///
/// **Dependencies:** `SpriteKitComponent`
public final class EntityEmitterComponent: OKComponent {

    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self]
    }
    
    // TODO: Add settings and change function parameters to overrides.
    
//    var initialImpulse: CGFloat? = nil
//    var recoilImpulse: CGFloat? = nil
//    var distanceFromSpawnerNode: CGFloat = 0
//    var angleOffsetFromSpawnerNode: CGFloat = 0
    
    @discardableResult public func emitEntity(
        _ entityToSpawn: OKEntity,
        initialImpulse: CGFloat? = nil,
        recoilImpulse: CGFloat? = nil,
        distanceFromSpawnerNode distance: CGFloat = 0,
        angleOffsetFromSpawnerNode angleOffset: CGFloat = 0,
        parentOverride: SKNode? = nil,
        actionToRunOnLaunch: SKAction? = nil)
        -> Bool
    {
        
        // TODO: Option for parent override.
        
        guard let entity = self.entity else {
            OctopusKit.logForWarnings("\(self) is not part of an entity.")
            return false
        }
        
        guard let spawnerDelegate = (entity as? OKEntity)?.delegate else {
            OctopusKit.logForWarnings("\(entity) is missing a delegate.")
            return false
        }
        
        guard let spawnerNode = self.entityNode else {
            OctopusKit.logForWarnings("\(entity) is missing a SpriteKit node.")
            return false
        }
        
        guard let spawnerNodeParent = spawnerNode.parent else {
            OctopusKit.logForWarnings("\(spawnerNode) is missing a parent.")
            return false
        }
        
        guard let nodeToSpawn = entityToSpawn.node else {
            OctopusKit.logForWarnings("\(entityToSpawn) is missing a SpriteKit node.")
            return false
        }
        
        var didSpawnEntity = false
        
        let spawnAngle = spawnerNode.zRotation + angleOffset
        let spawnPosition = spawnerNode.position.point(atAngle: spawnAngle,
                                                       distance: distance)
        
        let parent = parentOverride ?? spawnerNodeParent
        
        nodeToSpawn.position = parent.convert(spawnPosition, from: spawnerNodeParent)
        nodeToSpawn.zRotation = spawnAngle

        debugLog("spawner = \(spawnerNode), parent = \(parent), nodeToSpawn = \(nodeToSpawn)")
        
        didSpawnEntity = spawnerDelegate.entity(entity, didSpawn: entityToSpawn)
        
        // Action
        
        if let actionToRunOnLaunch = actionToRunOnLaunch {
            nodeToSpawn.run(actionToRunOnLaunch)
        }
        
        // Impulse
        
        if let initialImpulse = initialImpulse {
            
            guard let physicsBody = entityToSpawn.componentOrRelay(ofType: PhysicsComponent.self)?.physicsBody else {
                OctopusKit.logForWarnings("\(entityToSpawn) is missing a PhysicsComponent with a physicsBody — Cannot apply impulse.")
                return didSpawnEntity
            }
            
            let spawnAngle = Float(spawnAngle)
            
            let impulse = CGVector(
                dx: initialImpulse * CGFloat(cosf(spawnAngle)),
                dy: initialImpulse * CGFloat(sinf(spawnAngle)))
            
            physicsBody.applyImpulse(impulse)
        }
        
        // Recoil
        
        if  let recoilImpulse = recoilImpulse,
            didSpawnEntity
        {
            
            guard let spawnerPhysicsBody = coComponent(PhysicsComponent.self)?.physicsBody else {
                OctopusKit.logForWarnings("\(entity) is missing a PhysicsComponent with a physicsBody — Cannot apply recoil.")
                return didSpawnEntity
            }
            
            let spawnAngle = Float(spawnAngle)
            
            let recoil = CGVector(
                dx: (-recoilImpulse) * CGFloat(cosf(spawnAngle)),
                dy: (-recoilImpulse) * CGFloat(sinf(spawnAngle)))
            
            spawnerPhysicsBody.applyImpulse(recoil)
        }
        
        return didSpawnEntity
    }
}
