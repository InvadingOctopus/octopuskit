//
//  PhysicsContactComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components that act upon a physics contact event if it involves the entity's `SpriteKitComponent` node. A subclass can simply override `didBegin(_:, in:)` and `didEnd(_:, in:)` to implement behavior specific to the game and each entity.
///
/// **Dependencies:** `PhysicsComponent`, `PhysicsEventComponent`
open class PhysicsContactComponent: OKComponent, OKUpdatableComponent {
    
    open override var requiredComponents: [GKComponent.Type]? {
        [PhysicsComponent.self,
         PhysicsEventComponent.self]
    }
    
    open override func didAddToEntity() {
        super.didAddToEntity()
        
        // Log a warning if the entity's body does not have a `contactTestBitMask`
        
        if  let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody,
            physicsBody.contactTestBitMask == 0
        {
            OctopusKit.logForWarnings.add("\(physicsBody) of \(entity) has contactTestBitMask == 0 so contact events may not be generated!")
        }
    }
    
    open override func update(deltaTime seconds: TimeInterval) {
        guard
        let physicsComponent = coComponent(PhysicsComponent.self),
        let contactEventComponent = coComponent(PhysicsEventComponent.self)
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
    open func didBegin(_ contact: SKPhysicsContact, in scene: OKScene?) {}
    
    /// Abstract; to be implemented by a subclass.
    open func didEnd(_ contact: SKPhysicsContact, in scene: OKScene?) {}
    
}
