//
//  SKShapeNode+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/06.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

public extension SKShapeNode {
    
    // MARK: - Modifiers
    // As in SwiftUI.
    // DESIGN: No `@discardableResult` because they *should* raise a warning when used in place of more-efficient direct properties (i.e. most modifiers should only be used when creating an object as an argument for another initializer).
    
    /// Returns this shape after setting the color of its fill.
    @inlinable
    final func fillColor(_ color: SKColor) -> Self {
        self.fillColor = color
        return self
    }
    
    /// Returns this shape after setting the width of its glow.
    @inlinable
    final func glowWidth(_ width: CGFloat) -> Self {
        self.glowWidth = width
        return self
    }
    
    /// Returns this shape after setting the width of its stroke. A width larger than `2.0` may cause rendering artifacts. Default: `1.0`
    @inlinable
    final func lineWidth(_ width: CGFloat) -> Self {
        self.lineWidth = width
        return self
    }
    
    /// Returns this shape after setting the color of its stroke.
    @inlinable
    final func strokeColor(_ color: SKColor) -> Self {
        self.strokeColor = color
        return self
    }
    
}
