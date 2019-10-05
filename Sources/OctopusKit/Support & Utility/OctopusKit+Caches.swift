//
//  OctopusKit+Caches.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-30
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//
 
// TODO: CHECK: Use NSCache?

import SpriteKit

/// Predefined Caches and Loaders
public extension OctopusKit {

    // MARK: - Graphics
    
    static var textureAtlases: OctopusCache<String, SKTextureAtlas> = {
        
        let cache = OctopusCache<String, SKTextureAtlas> { key in
            
            OctopusKit.logForResources.add("SKTextureAtlas named = \"\(key)\"")
            // TODO: Error handling in case of invalid key
            return SKTextureAtlas(named: key)
        }
        
        return cache
    }()
    
    static var textures: OctopusCache<String, SKTexture> = {
        
        let cache = OctopusCache<String, SKTexture> { key in
            
            OctopusKit.logForResources.add("SKTexture imageNamed = \"\(key)\"")
            // TODO: Error handling in case of invalid key
            return SKTexture(imageNamed: key)
        }
        
        return cache
    }()
    
    static var shaders: OctopusCache<String, SKShader> = {
        
        let cache = OctopusCache<String, SKShader> { key in
            
            OctopusKit.logForResources.add("SKShader fileNamed = \"\(key)\"")
            // TODO: Error handling in case of invalid key
            return SKShader(fileNamed: key)
        }
        
        return cache
    }()
    
    // MARK: - Audio
    
    /*
     public static var audioFiles: OctopusCache<String, AVAudioFile> = {
     let manager = OctopusCache<String, AVAudioFile>() {
     
     let fileExtension = $0.pathExtension != "" ? $0.pathExtension : "m4a"
     if let path = NSBundle.mainBundle().pathForResource($0.stringByDeletingPathExtension, ofType: fileExtension) {
     let file = try? AVAudioFile(forReading: NSURL(fileURLWithPath: path))
     return file
     } else {
     return nil
     }
     }
     return manager
     }()
     
     public static var audioBuffers: OctopusCache<String, AVAudioPCMBuffer> = {
     let manager = OctopusCache<String, AVAudioPCMBuffer>() {
     
     let fileExtension = $0.pathExtension != "" ? $0.pathExtension : "caf"
     if let path = NSBundle.mainBundle().pathForResource($0.stringByDeletingPathExtension, ofType: fileExtension) {
     let file = try? AVAudioFile(forReading: NSURL(fileURLWithPath: path))
     let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
     do {
     try file.readIntoBuffer(buffer)
     } catch _ {
     }
     return buffer
     } else {
     return nil
     }
     }
     return manager
     }()
     */
    
    // MARK: - Management
    
    static func clearAllCaches() {
        textureAtlases.removeAllAssets()
        textures.removeAllAssets()
        shaders.removeAllAssets()
        //        audioFiles.removeAllAssets()
        //        audioBuffers.removeAllAssets()
    }

}
