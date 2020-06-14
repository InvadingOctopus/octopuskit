//
//  MusicComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/15.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Creates an `SKAudioNode` from the specified filename and plays it when this component is added to an entity, adding the music node to the entity's `NodeComponent` node.
///
/// - WARNING: ⚠️ SpriteKit seems to have a bug where the `SKAudioNode`'s `isPositional` property has no effect. Music may get panned and decrease in volume, unless this component is added to the same entity whose node is the `listener` for the `OKScene`, i.e. the player's entity.
///
/// **Dependencies:** `NodeComponent`
public final class MusicComponent: NodeAttachmentComponent <SKAudioNode> {
    
    /// TODO: Use `AVAudioPlayer`, as it is more suitable for music according to Apple documentation.
    
    /// CHECK: A way to add multiple `AudioComponent`s to an entity, as GameplayKit replaces older components of the same type? We may only want a single `MusicComponent` but multiple `AudioComponents`.
    
    /// BUG: `isPositional = false` does not seem to be working.
    
    /// ℹ️ DESIGN: As we have to setup the music in our initialization, and play it after it has been added to a parent node, we do not use `createAttachment(for:)` and just set `self.attachment` directly.
    
    public let masterNode: SKAudioNode
    
    /// The file name of the most-recently queued music. Useful for avoiding repeats or duplicate queues.
    public private(set) var latestFileName: String
    
    public let fadeInKey  = "OctopusKit.MusicComponent.FadeIn"
    public let fadeOutKey = "OctopusKit.MusicComponent.FadeOut"
    
    public init(fileNamed fileName: String,
                volume:             Float?  = nil,
                parentOverride:     SKNode? = nil)
    {
        // TODO: Error-handling for missing files.
        
        let firstMusicNode              = SKAudioNode(fileNamed: fileName)
        
        firstMusicNode.autoplayLooped   = true
        firstMusicNode.isPositional     = true // BUG: APPLEBUG 20200614A: Not effective.
        
        if  let volume = volume {
            firstMusicNode.run(.changeVolume(to: volume, duration: 0))
        }
        
        self.masterNode                 = SKAudioNode(children: [firstMusicNode])
        self.masterNode.isPositional    = true
        self.latestFileName             = fileName
        
        super.init(self.masterNode,
                   parentOverride: parentOverride)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        for case let audioNode as SKAudioNode in masterNode.children {
            audioNode.run(.stop()) // CHECK: Necessary?
        }
        masterNode.removeAllChildren()
        super.willRemoveFromEntity(withNode: node)
    }
    
    // MARK: Music Management
    
    public func fadeCurrentMusicAndAddNew(fileNamed newFileName: String,
                                          fadeOutDuration:    TimeInterval = 5.0,
                                          fadeInDuration:     TimeInterval = 5.0)
    {
        // Fade-out any current music.
        
        for case let previousAudio as SKAudioNode in masterNode.children {
            // CHECK: Is it helpful to check if an action key is already running?
            if  previousAudio.action(forKey: fadeOutKey) == nil {
                
                let fadeOut = SKAction.changeVolume(to: 0, duration: fadeOutDuration)
                
                previousAudio.run(.sequence([fadeOut,
                                             .removeFromParent()]),
                                  withKey: fadeOutKey)
            }
        }
        
        // Add the new music.
        
        let newMusic = SKAudioNode(fileNamed: newFileName)
        
        newMusic.autoplayLooped = true
        newMusic.isPositional   = false // BUG: APPLEBUG 20200614A: Not effective.
        
        self.masterNode.addChild(newMusic)
        
        // Apply a fade-in.
        
        let zeroVolume = SKAction.changeVolume(to: 0, duration: 0)
        let fadeIn     = SKAction.changeVolume(to: 1, duration: fadeInDuration)
        
        newMusic.run(.sequence([zeroVolume, fadeIn]),
                     withKey: fadeInKey)
        
        // Set the most-recent file name.
        
        self.latestFileName = newFileName
    }
}
