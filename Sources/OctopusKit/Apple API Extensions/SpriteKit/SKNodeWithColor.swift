//
//  SKNodeWithColor.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/05.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A protocol for nodes that have `color` and `colorBlendFactor` properties.
///
/// This allows different `SKNode` subclasses to be handled together when processing color and tint.
public protocol SKNodeWithColor: class { // where Self: SKNode { // ⚠️ Crashes.
    // TODO: Change name to an adjective?
    
    // Tinting a Sprite: https://developer.apple.com/documentation/spritekit/skspritenode/tinting_a_sprite
    
    var color:            SKColor { get set }
    var colorBlendFactor: CGFloat { get set }
}

extension SKSpriteNode: SKNodeWithColor {}

extension SKLabelNode:  SKNodeWithColor {
    public var color: SKColor {
        get { self.fontColor ?? .clear  }
        set { self.fontColor = newValue }
    }
}

extension SKShapeNode:  SKNodeWithColor {
    // CHECK: Should this just be removed from `SKShapeNode`?
    
    public var color: SKColor {
        get { self.fillColor }
        set { self.fillColor = newValue }
    }
    
    /// Ignored on `SKShapeNode`.
    public var colorBlendFactor: CGFloat {
        get { 1.0 } // The `color` property will always be applied 100%
        set {} // Nothing to set
    }
}

extension SKNodeWithColor {
    
    // MARK: - Modifiers
    // As in SwiftUI.
    
    /// Returns this node after setting its color.
    @inlinable
    public func color(_ color: SKColor) -> Self {
        self.color = color
        return self
    }
    
    /// Returns this node after setting its color blending factor.
    @inlinable
    public func colorBlendFactor(_ colorBlendFactor: CGFloat) -> Self {
        self.colorBlendFactor = colorBlendFactor
        return self
    }
}

