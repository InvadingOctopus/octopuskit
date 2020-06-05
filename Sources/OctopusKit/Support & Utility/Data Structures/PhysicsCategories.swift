//
//  PhysicsCategories.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/26.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A convenient alternative to specifying the categories of an `SKPhysicsBody` with an `OptionSet` instead of a direct `UInt32` value.
///
///
/// To use this in your game, create an extension for this structure and add static instances of `PhysicsCategories` to it, then call the `categoryBitMask(_:)` etc. modifiers on `SKPhysicsBody` which accept a `PhysicsCategories` argument.
///
/// **Example**
///
///     extension PhysicsCategories {
///         static let player       = PhysicsCategories(1 << 0)
///         static let enemy        = PhysicsCategories(1 << 1)
///         static let projectile   = PhysicsCategories(1 << 2)
///     }
///
///     projectileBody
///         .categoryBitMask    (.projectile)
///         .collisionBitMask   ([.player, .enemy])
///         .contactTestBitMask ([.player, .enemy])
///
///     PhysicsCategories(projectileBody.categoryBitMask).contains(.projectile)
public struct PhysicsCategories: OptionSet {
    
    public let rawValue: UInt32
    
    /// Creates a physics category with the specified bit mask.
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// A convenience initializer which reduces text clutter by omitting the argument name.
    public init(_ rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// Indicates that this physics body will not interact with any other bodies for the particular property.
    public static let none = PhysicsCategories([])
    
}
