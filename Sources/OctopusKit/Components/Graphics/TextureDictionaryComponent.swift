//
//  TextureDictionaryComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/03.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests
// TODO: Error-handling

import SpriteKit
import GameplayKit

/// Loads a sprite atlas (`SKTextureAtlas`) and stores a dictionary of textures grouped by their names and suffixes.
///
/// Use this component to store multiple groups of animation frames from a single sprite atlas, where each group of images may have names like "PlayerWalking0", "PlayerWalking1", "PlayerJumping0", and so on.
///
/// - Important: When accessing textures by name, note that the atlas name may be appended to the beginning of textures names, e.g. any folder paths specified when creating this component.
public final class TextureDictionaryComponent: OKComponent {
    
    public let atlasName: String
    public let atlas: SKTextureAtlas
    
    /// Stores frame textures grouped by the prefix of their filenames. This dictionary is populated by `saveDictionary(forTexturePrefix:addingAtlasNameBeforePrefix:)` or  `getFramesAndSaveDictionary(forTexturePrefix:addingAtlasNameBeforePrefix:)`.
    public fileprivate(set) var framesByPrefix: [String : [SKTexture]] = [:]
    
    /// Returns the group of frames whose filenames begin with the specified prefix in the `framesByPrefix` dictionary.
    ///
    /// Call `saveDictionary(forTexturePrefix:addingAtlasNameBeforePrefix:)` or  `getFramesAndSaveDictionary(forTexturePrefix:addingAtlasNameBeforePrefix:)` to populate the dictionary.
    public subscript(prefix: String) -> [SKTexture]? {
        return framesByPrefix[prefix]
    }
    
    public var shouldApplyFirstTextureWhenAddedToEntity: Bool = true
    
    // MARK: - Life Cycle
    
    public init(
        atlasName: String,
        shouldApplyFirstTextureWhenAddedToEntity: Bool = true)
    {
        OKLog.logForResources.debug("atlasName = \"\(atlasName)\"")
     
        self.atlasName = atlasName
        
        // Ensure that the atlas resource exists.
        
        guard let atlas = OctopusKit.textureAtlases[atlasName] else {
            fatalError("Cannot load SKTextureAtlas \"\(atlasName)\"")
        }
        
        self.atlas = atlas
        
        // And has at least 1 texture.
        
        if atlas.textureNames.count < 1  {
            OKLog.logForErrors.debug("Atlas \"\(atlasName)\" has no textures")
        }
        
        self.shouldApplyFirstTextureWhenAddedToEntity = shouldApplyFirstTextureWhenAddedToEntity
        
        super.init()
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        // TODO: Implement init(coder:)
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didAddToEntity(withNode node: SKNode) {
        guard let sprite = node as? SKSpriteNode else {
            OKLog.logForWarnings.debug("\(entity) does not have a SKSpriteNode as its NodeComponent's node")
            return
        }
        
        if shouldApplyFirstTextureWhenAddedToEntity {
            sprite.texture = atlas.textureNamed(atlas.textureNames.first ?? "")
        }
    }
    
    deinit {
        OKLog.logForDeinits.debug("atlasName = \"\(atlasName)\"")
    }
    
    // MARK - Dictionary Management
    
    /// Returns an array of textures with names matching the specified prefix.
    ///
    /// This allows you to name your image sets with a different prefix for each animation, each name ending in a number representing the frame of that animation. e.g., "Walking0", "Walking1", "Jumping0" and so on.
    ///
    /// If no matching names are found, a single-frame array of the first texture from the atlas is returned.
    public func getFrames(withPrefix prefix: String,
                          addingAtlasNameBeforePrefix: Bool = false)
        -> [SKTexture]
    {
        
        var frameList: [SKTexture] = []
        var unsortedNames: [String] = []
        var prefix = prefix

        if addingAtlasNameBeforePrefix {
            prefix = atlasName + prefix
        }
        
        // Build an unsorted array first.
        
        for case let name in atlas.textureNames where name.hasPrefix(prefix) {
            unsortedNames.append(name)
        }
        
        // Store the textures sorted by their names.
        
        for name in unsortedNames.sorted() {
            let texture = atlas.textureNamed(name)
            frameList += [texture]
        }
        
        // If we didn't find any textures with the specified prefix, just return the default one.
        
        if frameList.count < 1 {
            OKLog.logForErrors.debug("\(atlas) has no textures beginning with \"\(prefix)\" — Returning the first texture from the atlas")
            frameList.append(atlas.textureNamed(atlas.textureNames.first ?? ""))
        }
        
        return frameList
    }
    
    /// Checks the frames dictionary for the the specified prefix and returns an array of textures from it, otherwise updates the dictionary with the textures matching that prefix, if any.
    public func getFramesAndSaveDictionary(forTexturePrefix prefix: String,
                                           addingAtlasNameBeforePrefix: Bool = false)
        -> [SKTexture]
    {
        var prefix = prefix
        
        if addingAtlasNameBeforePrefix {
            prefix = atlasName + prefix
        }
        
        if let framesFromDictionary = framesByPrefix[prefix] {
            return framesFromDictionary
        }
        else {
            return saveDictionary(forTexturePrefix: prefix)
        }
    }
    
    /// Adds the group of textures matching the specified prefix, if any, to the dictionary. Afterwards, the textures group may be accessed with `framesByPrefix[prefix]` or the `TextureDictionaryComponent`'s subscript property.
    @discardableResult public func saveDictionary(forTexturePrefix prefix: String,
                                                  addingAtlasNameBeforePrefix: Bool = false)
        -> [SKTexture]
    {
        var prefix = prefix
        
        if addingAtlasNameBeforePrefix {
            prefix = atlasName + prefix
        }
        
        if framesByPrefix[prefix] != nil {
            OKLog.logForWarnings.debug("\(self) already has frames with prefix \(prefix) — Replacing")
        }
        
        framesByPrefix[prefix] = getFrames(withPrefix: prefix)
        return framesByPrefix[prefix] ?? []
    }
    
}
