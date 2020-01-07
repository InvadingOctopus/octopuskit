//
//  TouchControlledPhysicsHoldingComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/07/07.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if canImport(UIkit)

/// Prevents the physics body of the entity's `SpriteKitComponent` node from moving while the node is touched by the player.
///
/// - Prevents the body from being affected by gravity while it is being held.
/// - Sets the body's velocity to `0` every frame while it is being held.
/// - Optionally sets the body's angular velocity to `0` while it is being held, but the body may still be rotated by other forces (such as contact with other bodies.)
/// - These properties are reapplied every frame.
///
/// **Dependencies:** `NodeTouchStateComponent`, `PhysicsComponent`
@available(iOS 13.0, *)
public final class TouchControlledPhysicsHoldingComponent: OKComponent, OKUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [PhysicsComponent.self,
         NodeTouchStateComponent.self]
    }
    
    /// If `true`, the body's angular velocity is set to `0` in every frame while the node is being held, but the body may still be rotated by other forces (such as contact with other bodies.)
    ///
    /// Defaults to `false`.
    public var stopAngularVelocity: Bool = false
    
    @LogInputEventChanges(propertyName: "TouchControlledPhysicsHoldingComponent.isHolding")
    public var isHolding: Bool = false
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // This component does not make sense on a scene, so...
        
        if node is SKScene {
            OctopusKit.logForWarnings.add("A TouchControlledPhysicsHoldingComponent cannot be added to the scene entity — Removing.")
            self.removeFromEntity()
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {

        let nodeTouchComponent = coComponent(ofType: NodeTouchStateComponent.self)
        
        let isBeingTouched = (nodeTouchComponent?.trackedTouch != nil)
        
        isBeingTouched ? holdBody() : releaseBody()
    }
    
    private func holdBody() {
        guard let physicsBody = coComponent(ofType: PhysicsComponent.self)?.physicsBody else { return }
        physicsBody.velocity = CGVector.zero
        physicsBody.affectedByGravity = false
        if stopAngularVelocity { physicsBody.angularVelocity = 0 }
        isHolding = true
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        releaseBody()
        isHolding = false
    }
    
    private func releaseBody() {
        guard let physicsBody = coComponent(ofType: PhysicsComponent.self)?.physicsBody else { return }
        physicsBody.affectedByGravity = true
        isHolding = false
    }
}

#endif

#if !canImport(UIKit)
@available(macOS, unavailable, message: "Use PointerControlledPhysicsHoldingComponent")
public final class TouchControlledPhysicsHoldingComponent: iOSExclusiveComponent {}
#endif
