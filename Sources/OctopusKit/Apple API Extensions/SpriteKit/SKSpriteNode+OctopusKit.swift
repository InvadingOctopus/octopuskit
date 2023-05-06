//
//  SKSpriteNode+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit
import GameplayKit

extension SKSpriteNode {
    
    // MARK: - Initializers
    
    /// Creates an `SKSpriteNode` from a `UIImage` or image literal.
    public convenience init(image: OSImage) {
        self.init(texture: SKTexture(image: image))
    }
    
    /// Creates an `SKSpriteNode` of the specified size from a `UIImage` or image literal.
    public convenience init(image: OSImage, size: CGSize) {
        self.init(texture: SKTexture(image: image), size: size)
    }
    
    // MARK: - Properties
    
    /// Returns the center point of the sprite's frame.
    @inlinable
    public var center: CGPoint {
        CGPoint(x: frame.midX, y: frame.midY)
    }
    
    // MARK: - Common Tasks
    
    /// Creates a rectangular `SKPhysicsBody` equal to the sprite's size, ignoring its children if any.
    ///
    /// Does not assign the new physics body to the sprite.
    @inlinable
    @discardableResult public func makePhysicsBodyFromRect() -> SKPhysicsBody? {
        
        // ⚠️ This functionality cannot be added as an `SKPhysicsBody` extension, because of the usage of an inaccessible `PKPhysicsBody` superclass, as of 2017-10.
        
        // TODO: Confirm that self.size ignores children.
        
        guard
            self.size.width > 0
         && self.size.height > 0
            else {
                OctopusKit.logForWarnings("\(self.name ?? String(describing: self)) has a width or height of 0")
                return nil
        }
        
        return SKPhysicsBody(rectangleOf: self.size)
    }
    
    /// Creates a rectangular `SKPhysicsBody` equal to the sprite's size, ignoring its children if any, and assigns it to the sprite.
    @inlinable
    @discardableResult public func setPhysicsBodyToRect() -> SKPhysicsBody? {
        
        guard let newPhysicsBody = self.makePhysicsBodyFromRect() else {
            // Let `makePhysicsBodyFromRect()` output any errors or warnings.
            return nil
        }
        
        if  let currentPhysicsBody = self.physicsBody {
            OctopusKit.logForWarnings("\(self) already has \(currentPhysicsBody)")
        }
        
        self.physicsBody = newPhysicsBody
        return newPhysicsBody
    }
    
    /// Creates a `SKPhysicsBody` from the sprite's texture.
    ///
    /// Does not assign the new physics body to the sprite.
    @inlinable
    public func makePhysicsBodyFromTexture(withAlphaThreshold alphaThreshold: Float? = nil) -> SKPhysicsBody? {
        
        // ⚠️ This functionality cannot be added as an `SKPhysicsBody` extension, because of the usage of an inaccessible `PKPhysicsBody` superclass, as of 2017-10.
        
        guard let texture = self.texture else {
            OctopusKit.logForErrors("\(self.name ?? String(describing: self)) does not have a texture")
            return nil
        }
        
        let newPhysicsBody: SKPhysicsBody
        
        if  let alphaThreshold = alphaThreshold {
            newPhysicsBody = SKPhysicsBody(texture: texture, alphaThreshold: alphaThreshold, size: self.size)
        } else {
            newPhysicsBody = SKPhysicsBody(texture: texture, size: self.size)
        }
        
        return newPhysicsBody
    }
    
    /// Creates a `SKPhysicsBody` from the sprite's texture and assigns it to the sprite.
    @discardableResult public func setPhysicsBodyToTexture(withAlphaThreshold alphaThreshold: Float? = nil) -> SKPhysicsBody? {
        
        guard let newPhysicsBody = self.makePhysicsBodyFromTexture(withAlphaThreshold: alphaThreshold) else {
            // Let `makePhysicsBodyFromTexture(withAlphaThreshold:)` output any errors or warnings.
            return nil
        }
        
        if let currentPhysicsBody = self.physicsBody {
            OctopusKit.logForWarnings("\(self) already has \(currentPhysicsBody)")
        }
        
        self.physicsBody = newPhysicsBody
        return newPhysicsBody
    }
    
    /// Makes this sprite take on the dimensions and other characteristics of an `SKSpriteNode` matching the specified name, optionally removing that node and taking its place in the placeholder node's former parent.
    ///
    /// Useful for replacing placeholder sprites created in the Xcode Scene Editor, with programmatically-created sprites.
    ///
    /// The following properties are copied: `alpha, anchorPoint, blendMode, color, colorBlendFactor, constraints, entity, isHidden, isPaused, lightingBitMask, physicsBody, position, reachConstraints, shadowedBitMask, shadowCastBitMask, size, speed, xScale, yScale, zPosition, zRotation`
    ///
    /// - Returns: `true` if a sprite matching `name` was found and replaced.
    @inlinable
    @discardableResult public func copyPropertiesFromNode(
        named name: String,
        in placeholderParent: SKNode,
        replacingPlaceholder: Bool = false)
        -> Bool
    {

        // CHECK: Is this necessary? Can we just adopt Xcode Scene Editor support for a custom subclass, perhaps using NSCoding/NSCoder?
        
        // TODO: Add more properties, like the custom shader and its attributes
        
        // First check if the placeholder with the supplied name is found under the parent, and is an `SKSpriteNode`, because we need the `SKSpriteNode`'s rectangular dimensions to be visible in the Scene Editor to be able to accurately preview the replacement node's visual properties.
        
        guard let placeholder = placeholderParent.childNode(withName: name) as? SKSpriteNode else {
            return false
        }
        
        self.alpha                  = placeholder.alpha
        self.anchorPoint            = placeholder.anchorPoint
        self.blendMode              = placeholder.blendMode
        self.color                  = placeholder.color
        self.colorBlendFactor       = placeholder.colorBlendFactor
        self.constraints            = placeholder.constraints
        self.entity                 = placeholder.entity
        self.isHidden               = placeholder.isHidden
        self.isPaused               = placeholder.isPaused
        self.lightingBitMask        = placeholder.lightingBitMask
        self.physicsBody            = placeholder.physicsBody
        self.position               = placeholder.position
        self.reachConstraints       = placeholder.reachConstraints
        self.shadowedBitMask        = placeholder.shadowedBitMask
        self.shadowCastBitMask      = placeholder.shadowCastBitMask
        self.size                   = placeholder.size
        self.speed                  = placeholder.speed
        self.xScale                 = placeholder.xScale
        self.yScale                 = placeholder.yScale
        self.zPosition              = placeholder.zPosition
        self.zRotation              = placeholder.zRotation
        
        // self.focusBehavior = placeholder.focusBehavior
        
        // Remove the placeholder from the parent?
        
        if  replacingPlaceholder {
            self.replaceNode(placeholder)
        }
        
        return true
    }
    
}
