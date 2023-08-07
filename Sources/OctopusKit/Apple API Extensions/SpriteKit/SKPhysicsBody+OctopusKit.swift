//
//  SKPhysicsBody+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/13.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import OctopusCore
import SpriteKit

public extension SKPhysicsBody {

    // https://developer.apple.com/documentation/spritekit/skphysicsbody/configuring_a_physics_body
    
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
            OKLog.logForWarnings.debug("\(sprite.name ?? String(describing: sprite)) already has a physicsBody – Replacing")
        }
        
        sprite.physicsBody = self
    }

    // MARK: - Modifiers
    // As in SwiftUI
    
    /// Sets whether this physics body is affected by the physics world’s gravity, then returns the body.
    @inlinable @discardableResult
    final func affectedByGravity(_ newValue: Bool) -> Self {
        self.affectedByGravity = newValue
        return self
    }
    
    /// Sets whether this physics body is affected by angular forces and impulses applied to it, then returns the body.
    @inlinable @discardableResult
    final func allowsRotation(_ newValue: Bool) -> Self {
        self.allowsRotation = newValue
        return self
    }
        
    /// Sets the reduction of the body’s rotational velocity, and returns the body. Range: `0.0` to `1.0`. Default: `0.1`.
    @inlinable @discardableResult
    final func angularDamping(_ newValue: CGFloat) -> Self {
        self.angularDamping = newValue.clamped(to: 0.0...1.0)
        return self
    }
    
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
    
    /// Sets the body's density, in kilograms per square meter, and returns the body. Causes `mass` to be recalculated. Default: `1.0`.
    @inlinable @discardableResult
    final func density(_ newValue: CGFloat) -> Self {
        self.density = newValue
        return self
    }
    
    /// Sets the roughness of the body’s surface and returns the body. Range: `0.0` to `1.0`. Default: `0.2`.
    @inlinable @discardableResult
    final func friction(_ newValue: CGFloat) -> Self {
        self.friction = newValue.clamped(to: 0.0...1.0)
        return self
    }
    
    /// Sets whether this physics body is moved by the physics simulation, then returns the body.
    @inlinable @discardableResult
    final func isDynamic(_ newValue: Bool) -> Self {
        self.isDynamic = newValue
        return self
    }
    
    /// Sets the reduction of the body’s linear velocity, and returns the body. Range: `0.0` to `1.0`. Default: `0.1`.
    @inlinable @discardableResult
    final func linearDamping(_ newValue: CGFloat) -> Self {
        self.linearDamping = newValue.clamped(to: 0.0...1.0)
        return self
    }
    
    /// Sets the body's mass in kilograms and returns the body. Causes `density` to be recalculated. Default: Based on `area` and the default `density`.
    @inlinable @discardableResult
    final func mass(_ newValue: CGFloat) -> Self {
        self.mass = newValue
        return self
    }
    
    /// Sets the bounciness of the body and returns the body. Range: `0.0` to `1.0`. Default: `0.2`.
    @inlinable @discardableResult
    final func restitution(_ newValue: CGFloat) -> Self {
        self.restitution = newValue.clamped(to: 0.0...1.0)
        return self
    }
    
}
