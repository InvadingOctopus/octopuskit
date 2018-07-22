//
//  PhysicsContactHandlerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components that act upon a physics contact event if it involves the entity's `SpriteKitComponent` node. A subclass can simply override `didBegin(_:, in:)` and `didEnd(_:, in:)` to implement behavior specific to the game and each entity.
///
/// **Dependencies:** `PhysicsComponent`, `PhysicsContactEventComponent`
public class PhysicsContactHandlerComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [PhysicsComponent.self,
                PhysicsContactEventComponent.self]
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        guard
        let physicsComponent = coComponent(PhysicsComponent.self),
        let contactEventComponent = coComponent(PhysicsContactEventComponent.self)
        else { return }
        
        // Handle the beginning of new contacts.
        
        for event in contactEventComponent.contactBeginnings {
            
            let contact = event.contact // PERFORMANCE? Does this help? CHECK: Better way to write this?
            
            if contact.bodyA == physicsComponent.physicsBody
            || contact.bodyB == physicsComponent.physicsBody {
                
                #if LOGPHYSICS
                debugLog("💢 \(contact) BEGAN. A: \"\(contact.bodyA.node?.name ?? "")\", B: \"\(contact.bodyB.node?.name ?? "")\", point: \(contact.contactPoint), impulse: \(contact.collisionImpulse), normal: \(contact.contactNormal)")
                #endif
                
                didBegin(contact, in: event.scene)
            }
        }
        
        // Handle contacts that have just ended.
        
        for event in contactEventComponent.contactEndings {
            
            let contact = event.contact // PERFORMANCE? Does this help? CHECK: Better way to write this?
            
            #if LOGPHYSICS
            debugLog("💢 \(contact) ENDED. A: \"\(contact.bodyA.node?.name ?? "")\", B: \"\(contact.bodyB.node?.name ?? "")\", point: \(contact.contactPoint), impulse: \(contact.collisionImpulse), normal: \(contact.contactNormal)")
            #endif
            
            if contact.bodyA == physicsComponent.physicsBody
            || contact.bodyB == physicsComponent.physicsBody {
                
                didEnd(contact, in: event.scene)
            }
        }
    }
    
    /// Abstract; to be implemented by a subclass.
    public func didBegin(_ contact: SKPhysicsContact, in scene: OctopusScene?) {}
    
    /// Abstract; to be implemented by a subclass.
    public func didEnd(_ contact: SKPhysicsContact, in scene: OctopusScene?) {}
    
}
