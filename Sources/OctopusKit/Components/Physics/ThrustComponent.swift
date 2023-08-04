//
//  ThrustComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/11.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import SpriteKit
import GameplayKit

/// Applies a `thrustVector` to a `PhysicsComponent` every frame.
///
/// **Dependencies:** `PhysicsComponent`
public final class ThrustComponent: OKComponent, RequiresUpdatesPerFrame {

    // TODO: CHECK: Use deltaTime to determine thrust per update, instead of a fixed value?
    // CHECK: Should it be renamed to ForceComponent?
    
    public override var requiredComponents: [GKComponent.Type]? {
        [PhysicsComponent.self]
    }
    
    /// The scalar that `thrustVector` will be multiplied by.
    public var thrustBoostFactor: CGFloat = 1.0
    
    /// The scalar to clamp the `thrustVector` to, after applying the `thrustBoostFactor`.
    public var maximumThrust: CGFloat?
    
    public var thrustVector: CGVector?
    
    public init(thrustBoostFactor: CGFloat = 1.0,
                maximumThrust: CGFloat? = nil)
    {
        self.thrustBoostFactor = thrustBoostFactor
        self.maximumThrust = maximumThrust
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard
            var thrustVector = self.thrustVector,
            let physicsBody  = coComponent(PhysicsComponent.self)?.physicsBody
            else { return }
        
        // Multiply the thrust by the boost factor,
        thrustVector *= thrustBoostFactor
        
        // then multiply it by the time that has passed since the last update?
        // thrustVector *= CGFloat(seconds)
        
        if  let maximumThrust = self.maximumThrust {
            thrustVector.clampMagnitude(to: maximumThrust)
        }
        
        physicsBody.applyForce(thrustVector)
    }
}

