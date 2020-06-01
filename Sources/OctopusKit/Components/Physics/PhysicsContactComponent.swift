//
//  PhysicsContactComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components which act upon a physics contact event if it involves the entity's `NodeComponent` node. A subclass can simply override `didBegin(_:, in:)` and `didEnd(_:, in:)` to implement behavior specific to the game and each entity.
///
/// - NOTE: ❕ Multiple subclasses of this component may receive the same event, such as a `MonsterContactComponent` and a `BulletContactComponent`, to handle the collision between a monster and a bullet. A contact-processing component should only be concerned with the properties which involve its own entity, and not modify the opposing body or any other entity.
///
/// **Dependencies:** `PhysicsComponent`, `PhysicsEventComponent`
open class PhysicsContactComponent: OKComponent, RequiresUpdatesPerFrame {
    
    // ℹ️ https://developer.apple.com/documentation/spritekit/skphysicscontactdelegate
    // ℹ️ https://developer.apple.com/documentation/spritekit/skphysicscontact
    
    /// ⚠️ The physics contact delegate methods are called during the physics simulation step. During that time, the physics world can't be modified and the behavior of any changes to the physics bodies in the simulation is undefined. If you need to make such changes, set a flag inside `didBegin(_:)` or `didEnd(_:)` and make changes in response to that flag in the `update(_:for:)` method in a `SKSceneDelegate`.
    
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
            OctopusKit.logForWarnings("\(physicsBody) of \(entity) has contactTestBitMask == 0 so contact events may not be generated!")
        }
    }
    
    open override func update(deltaTime seconds: TimeInterval) {
        
        /// ❕ NOTE: It's very important that we check the `PhysicsComponent.physicsBody`, **not** the entity's `NodeComponent` `node.physicsBody`, because an entity may have multiple child nodes (e.g. a sprite and its shadow), and the `PhysicsComponent` may represent the body of a key child node (e.g. the sprite) instead of the entity's top-level container node.
        
        guard
            let physicsBody             = coComponent(PhysicsComponent.self)?.physicsBody,
            let contactEventComponent   = coComponent(PhysicsEventComponent.self)
            else { return }
        
        // CHECK: Find a way to reduce code duplication?
        
        // MARK: Contact Beginnings
        // Handle the beginning of new contacts.
        
        for event in contactEventComponent.contactBeginnings {
            
            let contact = event.contact // Reduces clutter and may improve performance.
            var opposingBody: SKPhysicsBody?
            
            if  contact.bodyA == physicsBody {
                opposingBody = contact.bodyB
            } else if contact.bodyB == physicsBody {
                opposingBody = contact.bodyA
            }
            
            if  let opposingBody = opposingBody {
                
                #if LOGPHYSICS
                debugLog("💢 \(contact) BEGAN. 🅰: \"\(contact.bodyA.node?.name ?? "")\", 🅱: \"\(contact.bodyB.node?.name ?? "")\", @\(contact.contactPoint), impulse: \(contact.collisionImpulse), normal: \(contact.contactNormal)",
                    topic: "\(self)")
                #endif
                
                didBegin(contact, entityBody: physicsBody, opposingBody: opposingBody, scene: event.scene)
            }
        }
        
        // MARK: Contact Endings
        // Handle contacts that have just ended.
        
        for event in contactEventComponent.contactEndings {
            
            let contact = event.contact // Reduces clutter and may improve performance.
            var opposingBody: SKPhysicsBody?
            
            if  contact.bodyA == physicsBody {
                opposingBody = contact.bodyB
            } else if contact.bodyB == physicsBody {
                opposingBody = contact.bodyA
            }
            
            if  let opposingBody = opposingBody {
                
                #if LOGPHYSICS
                debugLog("💢 \(contact) ENDED. 🅐: \"\(contact.bodyA.node?.name ?? "")\", 🅑: \"\(contact.bodyB.node?.name ?? "")\", @\(contact.contactPoint), impulse: \(contact.collisionImpulse), normal: \(contact.contactNormal)",
                    topic: "\(self)")
                #endif
                
                didEnd(contact, entityBody: physicsBody, opposingBody: opposingBody, scene: event.scene)
            }
        }
    }
    
    // MARK: Abstract
    
    /// Abstract; to be handled by a subclass. The beginning of a contact between the `PhysicsComponent` body of this component's entity and another body.
    open func didBegin  (_ contact:     SKPhysicsContact,
                         entityBody:    SKPhysicsBody,
                         opposingBody:  SKPhysicsBody,
                         scene:         OKScene?) {}
    
    /// Abstract; to be handled by a subclass. The end of a contact between the `PhysicsComponent` body of this component's entity and another body.
    open func didEnd    (_ contact:     SKPhysicsContact,
                         entityBody:    SKPhysicsBody,
                         opposingBody:  SKPhysicsBody,
                         scene:         OKScene?) {}
    
}
