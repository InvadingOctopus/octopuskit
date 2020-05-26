//
//  SKPhysicsBody+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/13.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit

public extension SKPhysicsBody {

    /// Creates a physics body from the texture of the specified sprite, capturing only the texels that exceed a specified transparency value.
    ///
    /// The size of the physics body will be the same as the sprite's size.
    convenience init(sprite: SKSpriteNode, alphaThreshold: Float? = nil) {
        
        // BUG: Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '+[PKPhysicsBody bodyWithTexture:alphaThreshold:size:]: unrecognized selector sent to class.
        
        guard let texture = sprite.texture else {
            fatalError("\(sprite.name ?? String(describing: sprite)) does not have a texture")
        }
        
        if  let alphaThreshold = alphaThreshold {
            self.init(texture: texture, alphaThreshold: alphaThreshold, size: sprite.size)
        } else {
            self.init(texture: texture, size: sprite.size)
        }
        
        if  sprite.physicsBody != nil {
            OctopusKit.logForWarnings("\(sprite.name ?? String(describing: sprite)) already has a physicsBody – Replacing")
        }
        
        sprite.physicsBody = self
    }

    // MARK: - Common Tasks
    
    /// Sets the categories that this physics body belongs to, then returns the body.
    ///
    /// A convenient alternative to setting the `categoryBitMask` property, using an `OptionSet` instead of a `UInt32` value. See the documentation for `PhysicsCategories`.
    @inlinable @discardableResult
    final func categoryBitMask(_ mask: PhysicsCategories) -> Self {
        // https://developer.apple.com/documentation/spritekit/skphysicsbody/1519869-categorybitmask
        self.categoryBitMask = mask.rawValue
        return self
    }
    
    /// Specifies the categories of physics bodies which can collide with this physics body, then returns the body.
    ///
    /// A convenient alternative to setting the `collisionBitMask` property, using an `OptionSet` instead of a `UInt32` value. See the documentation for `PhysicsCategories`.
    @inlinable @discardableResult
    final func collisionBitMask(_ mask: PhysicsCategories) -> Self {
        // https://developer.apple.com/documentation/spritekit/skphysicsbody/1520003-collisionbitmask
        self.collisionBitMask = mask.rawValue
        return self
    }
    
    /// Specifies the categories of physics bodies which may cause intersection notifications with this physics body, then returns the body.
    ///
    /// A convenient alternative to setting the `contactTestBitMask` property, using an `OptionSet` instead of a `UInt32` value. See the documentation for `PhysicsCategories` and `PhysicsContactComponent`.
    @inlinable @discardableResult
    final func contactTestBitMask(_ mask: PhysicsCategories) -> Self {
        // https://developer.apple.com/documentation/spritekit/skphysicsbody/1519781-contacttestbitmask
        self.contactTestBitMask = mask.rawValue
        return self
    }
    
}
