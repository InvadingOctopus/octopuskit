//
//  PhysicsCategories.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/26.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A convenient alternative to specifying the categories of an `SKPhysicsBody` with an `OptionSet` instead of a direct `UInt32` value. T
///
/// To use this in your game, create an extension for this structure and add static properties to it, then use with the `categoryBitMask(_:)` etc. extension methods on `SKPhysicsBody` which accept a `PhysicsCategories` argument.
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
    
}
