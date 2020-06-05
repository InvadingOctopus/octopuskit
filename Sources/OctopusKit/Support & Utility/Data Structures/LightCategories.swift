//
//  LightCategories.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/06/05.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A convenient alternative to specifying the categories of a lighting-capable node (like `SKLightNode` or `SKSpriteNode`) with an `OptionSet` instead of a direct `UInt32` value.
///
/// To use this in your game, create an extension for this structure and add static instances of `LightCategories` to it, then call the `lightingBitMask(_:)` etc. modifiers on lighting-compatible nodes which accept a `LightCategories` argument.
///
/// **Example**
///
///     extension LightCategories {
///         static let droid    = LightCategories(1 << 0)
///         static let laser    = LightCategories(1 << 1)
///         static let terrain  = LightCategories(1 << 2)
///     }
///
///     laserLight.categoryBitMask(.laser)
///     tileMap.lightingBitMask([.terrain, .laser])
///
///     LightCategories(laserLight.categoryBitMask).contains(.laser)
public struct LightCategories: OptionSet {
    
    // CHECK: Should this be named `LightingCategories`?
    
    public let rawValue: UInt32
    
    /// Creates a lighting category with the specified bit mask.
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// A convenience initializer which reduces text clutter by omitting the argument name.
    public init(_ rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// Indicates that this node is not included in the lighting system.
    public static let none = LightingCategories([])
    
}
