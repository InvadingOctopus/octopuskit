//
//  PhysicsContactComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components that act upon a physics contact event if it involves the entity's `NodeComponent` node. A subclass can simply override `didBegin(_:, in:)` and `didEnd(_:, in:)` to implement behavior specific to the game and each entity.
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
        
        // Handle the beginning of new contacts.
        
        for event in contactEventComponent.contactBeginnings {
            
            let contact = event.contact
            
            if contact.bodyA == physicsBody
            || contact.bodyB == physicsBody {
                
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
            
            if contact.bodyA == physicsBody
            || contact.bodyB == physicsBody {
                
                didEnd(contact, in: event.scene)
            }
        }
    }
    
    // MARK: Subclass Customization
    
    /// Abstract; to be implemented by a subclass.
    open func didBegin  (_ contact: SKPhysicsContact, in scene: OKScene?) {}
    
    /// Abstract; to be implemented by a subclass.
    open func didEnd    (_ contact: SKPhysicsContact, in scene: OKScene?) {}
    
}
