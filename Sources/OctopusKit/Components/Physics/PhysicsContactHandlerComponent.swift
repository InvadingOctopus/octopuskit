//
//  PhysicsContactHandlerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/28.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components that act upon a physics contact event if it involves this component's entity. A subclass can simply override `didBegin(_:, in:)` and `didEnd(_:, in:)` to implement behavior specific to the game and each entity.
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
        
        for event in contactEventComponent.contactBeginnings {
            if event.contact.bodyA == physicsComponent.physicsBody
                || event.contact.bodyB == physicsComponent.physicsBody {
                didBegin(event.contact, in: event.scene)
            }
        }
        
        for event in contactEventComponent.contactEndings {
            if event.contact.bodyA == physicsComponent.physicsBody
                || event.contact.bodyB == physicsComponent.physicsBody {
                didEnd(event.contact, in: event.scene)
            }
        }
    }
    
    /// Abstract; to be implemented by subclass.
    public func didBegin(_ contact: SKPhysicsContact, in scene: OctopusScene?) {}
    
    /// Abstract; to be implemented by subclass.
    public func didEnd(_ contact: SKPhysicsContact, in scene: OctopusScene?) {}
    
}
