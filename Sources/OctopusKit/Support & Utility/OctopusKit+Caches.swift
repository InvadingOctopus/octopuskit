//
//  OctopusKit+Caches.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-30
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//
 
// TODO: CHECK: Use NSCache?

import OctopusCore
import SpriteKit

/// Predefined Caches and Loaders
public extension OctopusKit {

    // MARK: - Graphics
    
    static var textureAtlases: OKCache<String, SKTextureAtlas> = {
        
        let cache = OKCache<String, SKTextureAtlas> { key in
            
            OKLog.resources.debug("\(📜("SKTextureAtlas named = \"\(key)\""))")
            // TODO: Error handling in case of invalid key
            return SKTextureAtlas(named: key)
        }
        
        return cache
    }()
    
    static var textures: OKCache<String, SKTexture> = {
        
        let cache = OKCache<String, SKTexture> { key in
            
            OKLog.resources.debug("\(📜("SKTexture imageNamed = \"\(key)\""))")
            // TODO: Error handling in case of invalid key
            return SKTexture(imageNamed: key)
        }
        
        return cache
    }()
    
    static var shaders: OKCache<String, SKShader> = {
        
        let cache = OKCache<String, SKShader> { key in
            
            OKLog.resources.debug("\(📜("SKShader fileNamed = \"\(key)\""))")
            // TODO: Error handling in case of invalid key
            return SKShader(fileNamed: key)
        }
        
        return cache
    }()
    
    // MARK: - Audio
    
    /*
     public static var audioFiles: OKCache<String, AVAudioFile> = {
     let manager = OKCache<String, AVAudioFile>() {
     
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
     
     public static var audioBuffers: OKCache<String, AVAudioPCMBuffer> = {
     let manager = OKCache<String, AVAudioPCMBuffer>() {
     
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
