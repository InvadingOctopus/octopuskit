//
//  SKNodeWithShader.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/10/24.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A protocol for SpriteKit node types that have a `shader` property.
///
/// Useful for passing around `SKNode`-based classes to functions that need to work with shaders.
public protocol SKNodeWithShader: SKNode { // where Self: SKNode { // ⚠️ Crashes.
    // TODO: CHECK: Change protocol name to an adjective?
    
    var  shader: SKShader? { get set }
    var  attributeValues: [String : SKAttributeValue] { get set }
    
    func setValue(_: SKAttributeValue, forAttribute: String)
    func value(forAttributeNamed: String) -> SKAttributeValue?
}

// NOTE: `public' modifier cannot be used with extensions that declare protocol conformances :)

extension SKEffectNode:  SKNodeWithShader {}
extension SKSpriteNode:  SKNodeWithShader {}
extension SKTileMapNode: SKNodeWithShader {}

// extension SKScene:    SKNodeWithShader {} // Unnecessary because SKScene inherits from SKEffectNode
