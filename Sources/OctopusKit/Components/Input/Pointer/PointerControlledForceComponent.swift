//
//  PointerControlledForceComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/14.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Enforce `isUserInteractionEnabled`?

// CHECKED: This component works whether the `PointerEventComponent` is added to a sprite entity or the scene entity. :)

// TODO: Fix physics and grabbing behavior etc.

import SpriteKit
import GameplayKit

///
/// **Dependencies:** `PhysicsComponent`, `SpriteKitComponent`, `PointerEventComponent`
public final class PointerControlledForceComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self,
         PhysicsComponent.self,
         PointerEventComponent.self]
    }
    
    public var boost: CGFloat
    
    public private(set) var pointing: Bool = false
    
    public init(boost: CGFloat = 10) {
        self.boost = boost
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let pointerEventComponent = coComponent(PointerEventComponent.self),
            let node        = entityNode,
            let parent      = node.scene,
            let physicsBody = node.physicsBody
            else { return }
        
        // Did player touch/click us?
        
        if  let pointerEvent = pointerEventComponent.pointerBegan,
            node.contains(pointerEvent.location(in: parent)) // TODO: Verify
        {
            self.pointing = true
        }
        
        // Move the node if the pointer we're tracking has moved.
        
        if  self.pointing,
            let currentEvent = pointerEventComponent.pointerMoved,
            let lastEvent    = pointerEventComponent.lastEvent
        {
            let currentPointerLocation  = currentEvent.location(in: parent)
            let previousPointerLocation = lastEvent.location(in: parent)
            let vector = CGVector(dx: (currentPointerLocation.x - previousPointerLocation.x) * boost,
                                  dy: (currentPointerLocation.y - previousPointerLocation.y) * boost)
            physicsBody.applyForce(vector)
        }
        
        // Stop tracking a pointer if the player cancelled it.
        
        if  self.pointing,
            pointerEventComponent.pointerEnded != nil
        {
            self.pointing = false
        }
    }
}
