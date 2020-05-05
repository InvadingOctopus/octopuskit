//
//  SKNodeWithBlendMode.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/05.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A protocol for nodes that have a `blendMode` property.
///
/// This allows different `SKNode` subclasses to be handled together when processing blending modes.
public protocol SKNodeWithBlendMode: class { // where Self: SKNode { // ⚠️ Crashes.
    // TODO: Change name to an adjective?
    
    // Blending a Sprite with Different Interpretations of Alpha: https://developer.apple.com/documentation/spritekit/skspritenode/blending_a_sprite_with_different_interpretations_of_alpha
    
    var blendMode: SKBlendMode { get set }
}

extension SKEffectNode:     SKNodeWithBlendMode {}
extension SKSpriteNode:     SKNodeWithBlendMode {}
extension SKLabelNode:      SKNodeWithBlendMode {}
extension SKShapeNode:      SKNodeWithBlendMode {}
extension SKTileMapNode:    SKNodeWithBlendMode {}

extension SKNodeWithBlendMode {
    
    // MARK: - Modifiers
    // As in SwiftUI.
    
    /// Returns this node after setting its blending mode.
    @inlinable
    public func blendMode(_ blendMode: SKBlendMode) -> Self {
        self.blendMode = blendMode
        return self
    }
}

