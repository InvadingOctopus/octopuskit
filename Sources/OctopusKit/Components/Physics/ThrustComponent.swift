//
//  ThrustComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/11.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: CHECK: Use deltaTime to determine thrust per update, instead of a fixed value?
// CHECK: Should it be renamed to ForceComponent?
//

import SpriteKit
import GameplayKit

/// Applies a `thrustVector` to a `PhysicsComponent` every frame.
///
/// **Dependencies:** `PhysicsComponent`
public final class ThrustComponent: OctopusComponent, OctopusUpdatableComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        return [PhysicsComponent.self]
    }
    
    /// The scalar that `thrustVector` will be multiplied by.
    public var thrustBoostFactor: CGFloat = 1.0
    
    /// The scalar to clamp the `thrustVector` to, after applying the `thrustBoostFactor`.
    public var maxThrust: CGFloat?
    
    public var thrustVector: CGVector?
    
    public init(thrustBoostFactor: CGFloat = 1.0,
                maxThrust: CGFloat? = nil)
    {
        self.thrustBoostFactor = thrustBoostFactor
        self.maxThrust = maxThrust
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard
            var thrustVector = self.thrustVector,
            let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody
            else { return }
        
        // Multiply the thrust by the boost factor,
        thrustVector *= thrustBoostFactor
        
        // then multiply it by the time that has passed since the last update?
        // thrustVector *= CGFloat(seconds)
        
        if let maxThrust = self.maxThrust {
            thrustVector.clampMagnitude(to: maxThrust)
        }
        
        physicsBody.applyForce(thrustVector)
        
    }
}

