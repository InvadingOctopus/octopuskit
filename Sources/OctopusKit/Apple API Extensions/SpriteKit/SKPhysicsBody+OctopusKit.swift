//
//  SKPhysicsBody+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/13.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit

extension SKPhysicsBody {

    /// Creates a physics body from the texture of the specified sprite, capturing only the texels that exceed a specified transparency value.
    ///
    /// The size of the physics body will be the same as the sprite's size.
    public convenience init(sprite: SKSpriteNode, alphaThreshold: Float? = nil) {
        // BUG: Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '+[PKPhysicsBody bodyWithTexture:alphaThreshold:size:]: unrecognized selector sent to class.
        
        guard let texture = sprite.texture else {
            fatalError("\(sprite.name ?? String(describing: sprite)) does not have a texture")
        }
        
        if let alphaThreshold = alphaThreshold {
            self.init(texture: texture, alphaThreshold: alphaThreshold, size: sprite.size)
        }
        else {
            self.init(texture: texture, size: sprite.size)
        }
        
        if sprite.physicsBody != nil {
            OctopusKit.logForWarnings.add("\(sprite.name ?? String(describing: sprite)) already has a physicsBody – Replacing")
        }
        
        sprite.physicsBody = self
    }

}
