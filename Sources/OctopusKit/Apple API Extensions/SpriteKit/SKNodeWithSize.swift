//
//  SKNodeWithSize.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/18.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

public typealias SKNodeWithDimensions = SKNodeWithSize

/// A protocol for types that have `width` and `height` properties.
///
/// This allows different `SKNode` subclasses to be handled together when processing width or height.
public protocol SKNodeWithSize { // where Self: SKNode { // ⚠️ Crashes.
    // TODO: Change name to an adjective?
    var size: CGSize { get }
}

// NOTE: `public' modifier cannot be used with extensions that declare protocol conformances :)

extension SKCameraNode: SKNodeWithSize {
    
    /// Returns the `size` of the parent (scene.)
    public var size: CGSize {
        // TODO: Verify and check compatibility with scaling etc.
        if  let parent = self.parent as? SKNodeWithSize {
            return parent.size
        } else {
            return CGSize.zero
        }
    }
}

extension SKEffectNode: SKNodeWithSize { // Includes SKScene
    public var size: CGSize {
        // CHECK: PERFORMANCE: Is this efficient? Necessary?
        self.calculateAccumulatedFrame().size
    }
}

// extension SKScene:          SKNodeWithSize {} // Included in SKEffectNode

extension SKSpriteNode:     SKNodeWithSize {}

extension SKVideoNode:      SKNodeWithSize {}

extension SKTileMapNode:    SKNodeWithSize {
    public var size: CGSize { self.mapSize }
}

