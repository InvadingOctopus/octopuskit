//
//  OKCache.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-21
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Use NSCache – Not practical with Swift and String. 2017-11-16

import Foundation

public typealias OctopusCache = OKCache

/// Used to store any kind of resource. If the resource for a requested identifier is not available, it calls a user-provided closure to load the resource and cache it for future retrieval.
public final class OKCache <AssetKeyType: Hashable, AssetType> {
    /* USAGE EXAMPLE:

    var textureCache = AssetManager<String, SKTexture> () {
        return textureAtlas.textureNamed($0)
    }
    
    sprite.texture = textureCache["Goblin"]
    */
    
    // TODO: Implement deletion of oldest assets to conserve memory.
    
    public fileprivate(set) var assets = [AssetKeyType : AssetType]()
    
    /// The closure to call for loading an asset that is not present in the cache.
    public let assetLoader: (AssetKeyType) -> AssetType?
    
    public init(assetLoader: @escaping (AssetKeyType) -> AssetType?) {
        self.assetLoader = assetLoader
    }
    
    public subscript(key: AssetKeyType) -> AssetType? {
        get { // mutating
            // BUG: Mutating subscript getter may be bugged (but works in Playground.) Use getAsset(forKey:) instead.
            // FEEDBACK: https://devforums.apple.com/message/1062711#1062711
            return getAsset(forKey: key)
        }
        
        set {
            assets[key] = newValue
        }
    }
    
    public func getAsset(forKey key: AssetKeyType) -> AssetType? { // mutating
        // OctopusKit.logForResources.add("\(key)")
        
        if let asset = assets[key] {
            // OctopusKit.logForResources.add("Asset in cache")
            return asset
            
        } else if let asset = assetLoader(key) {
            // OctopusKit.logForResources.add("Asset loaded and cached")
            assets[key] = asset
            return asset
            
        } else {
            return nil
        }
    }
    
    public func removeAllAssets() { // mutating
        assets.removeAll(keepingCapacity: false)
    }
    
    /// MARK: - Debugging
    
    public func printAssets() {
        OctopusKit.logForResources.add("assets.count = \(assets.count)")
        for key in assets.keys {
            OctopusKit.logForResources.add("key = \(key), asset = \(assets[key])")
        }
    }
    
}

