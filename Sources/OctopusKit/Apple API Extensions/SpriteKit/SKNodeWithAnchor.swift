//
//  SKNodeWithAnchor.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/30.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A protocol for types that have an `anchorPoint` property.
///
/// This allows different `SKNode` subclasses to be handled together when processing their anchor points.
public protocol SKNodeWithAnchor { // where Self: SKNode { // ⚠️ Crashes.
    // TODO: Change name to an adjective?
    
    // https://developer.apple.com/documentation/spritekit/skspritenode/using_the_anchor_point_to_move_a_sprite
    
    var anchorPoint: CGPoint { get set }
}

extension SKScene:       SKNodeWithAnchor {}
extension SKSpriteNode:  SKNodeWithAnchor {}
extension SKVideoNode:   SKNodeWithAnchor {}
extension SKTileMapNode: SKNodeWithAnchor {}
