//
//  ShaderComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/24.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Full ShaderToy conversion.

import SpriteKit
import GameplayKit

/// Applies a custom shader to a shader-capable node.
public final class ShaderComponent: OKComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self]
    }
    
    public var shader: SKShader? {
        // CHECK: Should this be weak?
        
        didSet {
            //  If we're part of an entity that has a SpriteKit node,
            if  let node = entityNode as? SKNodeWithShader {
                
                //  And this component was supplied with a new shader,
                if  self.shader != nil {
                    
                    // Then use existing logic to assign our shader to the node.
                    assignShader(to: node)
                }
                    
                // Otherwise, if our shader was set to `nil`, then set the node's shader to `nil` as well, as this would be the expected behavior of modifying the `ShaderComponent` of an entity with an existing node.
                else if self.shader == nil {
                     node.shader = nil
                }
            }
        }
    }
    
    public init(shader: SKShader? = nil) {
        self.shader = shader
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        guard let shaderCapableNode = node as? SKNodeWithShader else {
            OctopusKit.logForWarnings.add("\(node) does not have a `shader` property — This component should only be added to entities with a SKSpriteNode, SKEffectNode or SKScene.")
            return
        }
        
        assignShader(to: shaderCapableNode)
        
        addCommonAttributes()
    }
    
    public func assignShader(to node: SKNodeWithShader) {
        
        // This is a separate method so that the `shader` `didSet` can call it without superfluously logging a `didAddToEntity(withNode:)` call.
        
        // TODO: Test all scenarios! (component's shader, node's shader)
        
        // Sync the `shader` that this component represents, with the `shader` of the SpriteKit node associated with this component's entity.
        
        // First off, are we already in sync? Then there's nothing to do here!
        
        guard self.shader !== node.shader else { return }
        
        // Next check: Does the node already have a shader and this component doesn't?
        
        if  self.shader == nil,
            node.shader != nil
        {
            
            // Then adopt the node's shader as this component's shader.
            
            OctopusKit.logForDebug.add("\(self) missing shader — Adopting from \(node.name ?? String(describing: node))")
            
            self.shader = node.shader
        }
            
        // Otherwise, if we have a shader and the node doesn't, try to assign our shader to the node.
            
        else if let shader = self.shader,
                node.shader == nil
        {
            node.shader = shader
        }
            
        // If this component has a shader and the node also has a shader, and they're different, log a warning, then replace the node's shader with this component's shader, as that would be the expected behavior of adding a `ShaderComponent` to an entity with an existing node.
            
        else if self.shader != nil && node.shader != nil && self.shader !== node.shader {
            
            OctopusKit.logForWarnings.add("Mismatching shaders: \(self) has \(self.shader), \(node.name ?? String(describing: node)) has \(node.shader) — Replacing node's shader")
            
            node.shader = self.shader
        }
    }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        
        guard let node = node as? SKNodeWithShader else { return }
        
        if  let nodeShader = node.shader,
            nodeShader !== self.shader
        {
            OctopusKit.logForWarnings.add("\(node.name ?? String(describing: node)) had a different shader than this component – Removing")
        }
        
        // Remove the shader even if the node had a different one, to keep the expected behavior of removing shader effects from the node when a ShaderComponent is removed.
        node.shader = nil
    }
 
    /// Add some missing attributes that are commonly used.
    func addCommonAttributes() {
        
        // APPLE DOCUMENTATION: Using attributes rather than uniforms allows a single SKShader to be shared between nodes, each one defining their own value for a shader variable. The following code demonstrates attributes by passing the size of a sprite to a shader as an attribute.
        // https://developer.apple.com/documentation/spritekit/skshader/creating_a_custom_fragment_shader
        
        guard
            let shader = self.shader,
            let node = entityNode as? SKNodeWithShader,
            let nodeSize = (entityNode as? SKNodeWithDimensions)?.size
            else { return }
        
        shader.attributes = [
            SKAttribute(name: "iResolution", type: .vectorFloat2)
        ]
         
        let nodeSizeAttribute = vector_float2(Float(nodeSize.width),
                                              Float(nodeSize.height))
        
        // SWIFT LIMITATION: Casting to concrete types here is not necessary,
        // but we do it to avoid the deprecation warning:
        // "setValue(_:forAttribute:) was deprecated in iOS 10.0"
        
        if  let node = node as? SKEffectNode { // Includes SKScene
            node.setValue(SKAttributeValue(vectorFloat2: nodeSizeAttribute),
            forAttribute: "a_sprite_size")
        
        }   else if let node = node as? SKSpriteNode {
            
            node.setValue(SKAttributeValue(vectorFloat2: nodeSizeAttribute),
            forAttribute: "a_sprite_size")
        }
        
    }
}
