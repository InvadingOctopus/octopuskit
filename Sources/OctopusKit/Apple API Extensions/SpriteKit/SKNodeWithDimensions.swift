//
//  SKNodeWithDimensions.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/18.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A protocol for types that have `width` and `height` properties.
///
/// This allows different `SKNode` subclasses to be handled together when processing width or height.
public protocol SKNodeWithDimensions { // where Self: SKNode { // ⚠️ Crashes.
    // TODO: Change name to an adjective?
    var size: CGSize { get }
}

// NOTE: `public' modifier cannot be used with extensions that declare protocol conformances :)

extension SKCameraNode: SKNodeWithDimensions {
    
    /// Returns the `size` of the parent (scene.)
    public var size: CGSize {
        // TODO: Verify and check compatibility with scaling etc.
        if  let parent = self.parent as? SKNodeWithDimensions {
            return parent.size
        } else {
            return CGSize.zero
        }
    }
}

extension SKEffectNode:     SKNodeWithDimensions { // Includes SKScene
    public var size: CGSize {
        // CHECK: PERFORMANCE: Is this efficient? Necessary?
        self.calculateAccumulatedFrame().size
    }
}

// extension SKScene:          SKNodeWithDimensions {} // Included in SKEffectNode

extension SKSpriteNode:     SKNodeWithDimensions {}

extension SKTileMapNode:    SKNodeWithDimensions {
    public var size: CGSize { self.mapSize }
}

extension SKVideoNode:      SKNodeWithDimensions {}
