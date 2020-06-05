//
//  SKLightNode+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/06/05.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

public extension SKLightNode {
    
    // MARK: Modifiers
    // As in SwiftUI.
    
    /// Sets the ambient color and returns this node. The alpha component is ignored. Not affected by `falloff` or any normal map (`normalTexture`) on sprite nodes. Default: `black` (no ambient light).
    @inlinable @discardableResult
    func ambientColor(_ newValue: SKColor) -> Self {
        self.ambientColor = newValue
        return self
    }
    
    /// Sets the categories that this light source belongs to, then returns the node. Default: `default (0x00000001)`
    ///
    /// A convenient alternative to setting the `categoryBitMask` property, using an `OptionSet` instead of a `UInt32` value. See the documentation for `LightCategories`.
    @inlinable @discardableResult
    func categoryBitMask(_ mask: LightCategories) -> Self {
        // https://developer.apple.com/documentation/spritekit/sklightnode/1519940-categorybitmask
        self.categoryBitMask = mask.rawValue
        return self
    }
    
    /// Sets the exponent for the rate of decay of this light source and returns the node. Range: `0.0` to `1.0`. Default: `1.0`.
    @inlinable @discardableResult
    func falloff(_ newValue: CGFloat) -> Self {
        self.falloff = newValue.clamped(to: 0.0...1.0)
        return self
    }
    
    /// Sets whether this node is casting light then returns the node. Default: `true`
    @inlinable // DESIGN: Not `@discardableResult` because the direct property is more efficient if only setting this.
    func isEnabled(_ newValue: Bool) -> Self {
        self.isEnabled = newValue
        return self
    }
    
    /// Sets the diffuse and specular color of the light source, then returns this node. Default: `white`
    @inlinable @discardableResult
    func lightColor(_ newValue: SKColor) -> Self {
        self.lightColor = newValue
        return self
    }
    
    /// Sets the color of shadows cast by sprites which are affected by this light source, then returns this node. Default: `black` with alpha: `0.5`
    @inlinable @discardableResult
    func shadowColor(_ newValue: SKColor) -> Self {
        // https://developer.apple.com/documentation/spritekit/sklightnode/1519844-shadowcolor
        self.shadowColor = newValue
        return self
    }

}
