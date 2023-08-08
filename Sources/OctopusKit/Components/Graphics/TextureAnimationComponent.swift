//
//  TextureAnimationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/29.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: When a setting changes, update the animation without reseting it to the first frame?

import OctopusCore
import SpriteKit
import GameplayKit

/// Animates the entity's `NodeComponent` node with the specified frames, provided as an array of textures or by a `TextureDictionaryComponent`.
///
/// **Dependencies:** `NodeComponent`, `TextureDictionaryComponent`
public final class TextureAnimationComponent: OKComponent {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         TextureDictionaryComponent.self] // ℹ️ Even though a `TextureDictionaryComponent` is not REQUIRED, it is how this `TextureAnimationComponent` is usually used with.
    }
 
    // MARK: - Properties
    
    public static let animationKey = "OctopusKit.TextureAnimationComponent.Animate" // CHECK: Should this be static?
    
    /// Stores the texture of the entity's `NodeComponent` sprite when this component is added to the entity, and restores this texture to the sprite when this component is removed from the entity.
    public fileprivate(set) var initialTexture: SKTexture?
    
    // MARK: Animation Settings
    
    public var frames: [SKTexture] {
        didSet {
            if frames != oldValue {
                // Cannot use ?: because "Result values in expression have mismatching types '()' and 'Bool'"
                if !frames.isEmpty { updateAnimation() }
                else { stopAnimation() }
            }
        }
    }
    
    public var textureDictionaryPrefix: String? {
        didSet {
            
            // ℹ️ DESIGN: Update our frames only for a valid prefix. If this component is supposed to have an empty framelist, then that should be explicitly stated by setting the `frames` property to an empty array `[]`, but an invalid prefix may not be intentional, so keep our framelist as-is if the prefix is invalid.
            
            if  textureDictionaryPrefix != oldValue,
                let textureDictionaryPrefix = self.textureDictionaryPrefix,
                let frames = loadFramesFromTextureDictionary(matchingPrefix: textureDictionaryPrefix)
            {
                self.frames = frames
            }
        }
    }
    
    public var secondsPerFrame: TimeInterval {
        didSet {
            if secondsPerFrame != oldValue { updateAnimation() }
        }
    }
    
    public var repeatForever: Bool {
        didSet {
            if repeatForever != oldValue { updateAnimation() }
        }
    }
    
    public var resizeSpriteToMatchEachTexture: Bool {
        didSet {
            if resizeSpriteToMatchEachTexture != oldValue { updateAnimation() }
        }
    }
    
    // MARK: - Life Cycle
    
    /// Creates a `TextureAnimationComponent` that animates the entity's `NodeComponent` sprite with the specified textures when added to an entity.
    public init(
        initialAnimationFrames: [SKTexture],
        secondsPerFrame: TimeInterval = 1.0,
        repeatForever: Bool = true,
        resizeSpriteToMatchEachTexture: Bool = false)
    {
        self.frames = initialAnimationFrames
        self.secondsPerFrame = secondsPerFrame
        self.repeatForever = repeatForever
        self.resizeSpriteToMatchEachTexture = resizeSpriteToMatchEachTexture
        super.init()
    }
    
    /// Creates a `TextureAnimationComponent` that animates the entity's `NodeComponent` sprite with the specified textures from a `TextureDictionaryComponent` when added to an entity.
    public convenience init(
        initialAnimationTexturePrefix: String? = nil,
        secondsPerFrame: TimeInterval = 1.0,
        repeatForever: Bool = true,
        resizeSpriteToMatchEachTexture: Bool = false)
    {
        self.init(initialAnimationFrames: [],
                  secondsPerFrame: secondsPerFrame,
                  repeatForever: repeatForever,
                  resizeSpriteToMatchEachTexture: resizeSpriteToMatchEachTexture)
        self.textureDictionaryPrefix = initialAnimationTexturePrefix
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // #1: Store the current texture of the sprite to restore it when this component is removed from the entity.
        
        self.initialTexture = (node as? SKSpriteNode)?.texture
        
        // #2.1 Were we specified any initial animation? Play it now.
        
        // #2.2a: See if we have been specified a texture dictionary prefix.
        
        if  let textureDictionaryPrefix = self.textureDictionaryPrefix,
            let frames = loadFramesFromTextureDictionary(matchingPrefix: textureDictionaryPrefix)
        {
            self.frames = frames // Let the property observer start the animation.
        }
        // #2.2b: or have an array of frames.
        else if !self.frames.isEmpty {
            updateAnimation()
        }
        
    }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        
        // #1: Stop our animation.
        node.removeAction(forKey: TextureAnimationComponent.animationKey)
        
        // #2: If we saved the texture of the sprite from before this component was added to the entity, restore that texture now.
        
        if let initialTexture = self.initialTexture {
            (entityNode as? SKSpriteNode)?.texture = initialTexture
        }
        
        // #3: Let the superclass handle rest of the cleanup.
        super.willRemoveFromEntity(withNode: node)
    }
    
    // MARK: - Animation
    
    public func loadFramesFromTextureDictionary(matchingPrefix prefix: String) -> [SKTexture]?  {
    
        guard let entity = self.entity else {
            OKLog.warnings.debug("\(📜("\(self) is not part of any entity."))")
            return nil
        }
        
        guard let textureDictionaryComponent = coComponent(TextureDictionaryComponent.self) else {
            OKLog.warnings.debug("\(📜("\(entity) missing TextureDictionaryComponent."))")
            return nil
        }
        
        let frames = textureDictionaryComponent.getFramesAndSaveDictionary(forTexturePrefix: prefix)
        
        // Warn if less than 1 frame in the dictionary but let the animation methods decide what to do about that.
        
        if frames.count < 1 {
            OKLog.warnings.debug("\(📜("\(textureDictionaryComponent) does not have any frames beginning with \"\(prefix)\""))")
        }
        
        return frames
    }
    
    /// Plays the animation as specified by the current properties of this component.
    @discardableResult public func updateAnimation() -> Bool
    {
        // ℹ️ Since this method will be called automatically by property observers, exit quietly without issuing any warnings if any conditions are not met (as may be the case if properties are modified before this component is added to any entity.)
        
        guard
            !self.frames.isEmpty,
            let sprite = self.entityNode as? SKSpriteNode
            else { return false }
    
        // #1: Remove any previous animation.
        
        sprite.removeAction(forKey: TextureAnimationComponent.animationKey)
        sprite.texture = frames[0] // TODO: CHECK: BUG? It appears this is needed otherwise sprite flickers afterwards.
        
        if repeatForever {
            
            // #2a: If repeating forever, restore the original frame when this animation is stopped.
            
            let animate = SKAction.animate(with: frames,
                                           timePerFrame: secondsPerFrame,
                                           resize: resizeSpriteToMatchEachTexture,
                                           restore: true)
            
            sprite.run(SKAction.repeatForever(animate),
                       withKey: TextureAnimationComponent.animationKey)
            
        } else {
            
            // #2b: If not repeating forever, keep the most recent frame after this animation finishes.
            
            let animate = SKAction.animate(with: frames,
                                           timePerFrame: secondsPerFrame,
                                           resize: resizeSpriteToMatchEachTexture,
                                           restore: false)
            
            sprite.run(animate,
                       withKey: TextureAnimationComponent.animationKey)
            
        }
        
        return true
    }
    
    /// Animates using the specified textures, without changing this component's properties.
    ///
    /// - NOTE: If this method is repeatedly called with the same arguments as a currently playing animation, e.g. the same textures, the animation will only display the first frame, if any.
    @discardableResult public func animate(
        with textures: [SKTexture],
        secondsPerFrame: TimeInterval = 1.0,
        repeatForever: Bool = true,
        resizeSpriteToMatchEachTexture shouldResize: Bool = false)
        -> Bool
    {
        
        guard let entity = self.entity else {
            OKLog.warnings.debug("\(📜("\(self) is not part of any entity."))")
            return false
        }
        
        guard let nodeComponent = coComponent(NodeComponent.self) else {
            OKLog.warnings.debug("\(📜("\(entity) is missing a NodeComponent."))")
            return false
        }
        
        guard let sprite = nodeComponent.node as? SKSpriteNode else {
            OKLog.warnings.debug("\(📜("\(entity) does not have a SKSpriteNode associated with its NodeComponent."))")
            return false
        }
        
        if textures.count < 1 {
            OKLog.warnings.debug("\(📜("textures.count < 1"))")
        }
        
        // Remove any previous animation.
        sprite.removeAction(forKey: TextureAnimationComponent.animationKey)
        sprite.texture = textures[0] // TODO: CHECK: BUG? It appears this is needed otherwise sprite flickers afterwards.
        
        if repeatForever {
            
            // If repeating forever, restore the original frame when this animation is stopped.
            
            let animate = SKAction.animate(with: textures, timePerFrame: secondsPerFrame, resize: shouldResize, restore: true)
            
            sprite.run(SKAction.repeatForever(animate), withKey: TextureAnimationComponent.animationKey)
            
        } else {
            
            // If not repeating forever, keep the most recent frame after this animation finishes.
            
            let animate = SKAction.animate(with: textures, timePerFrame: secondsPerFrame, resize: shouldResize, restore: false)
            
            sprite.run(animate, withKey: TextureAnimationComponent.animationKey)
            
        }
        
        return true
    }
    
    /// Animates with frames from a `TextureDictionaryComponent`, whose names match the specified suffix, without changing this component's properties.
    ///
    /// - NOTE: If this method is repeatedly called with the same arguments as a currently playing animation, e.g. the same prefix, the animation will only display the first frame, if any.
    @discardableResult public func animateUsingTextureDictionary(
        withTexturePrefix prefix: String,
        secondsPerFrame: TimeInterval = 1.0,
        repeatForever: Bool = true,
        resizeSpriteToMatchEachTexture shouldResize: Bool = false)
        -> Bool
    {
        return animate(
            with: loadFramesFromTextureDictionary(matchingPrefix: prefix) ?? [],
            secondsPerFrame: secondsPerFrame,
            repeatForever: repeatForever,
            resizeSpriteToMatchEachTexture: shouldResize)
    }
    
    public func stopAnimation() {
        entityNode?.removeAction(forKey: TextureAnimationComponent.animationKey)
    }
    
}
