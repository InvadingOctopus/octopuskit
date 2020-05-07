//
//  AudioComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/15.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

// TODO: A way to add multiple `AudioComponent`s to an entity, as GameplayKit replaces older components of the same type.

import GameplayKit

/// Creates an `SKAudioNode` from the specified filename and plays it when this component is added to an entity, adding the audio node to the entity's `NodeComponent` node.
///
/// **Dependencies:** `NodeComponent`
public final class AudioComponent: NodeAttachmentComponent<SKAudioNode> {
    
    // ℹ️ DESIGN: As we have to setup the audio in our initialization, and play it after it has been added to a parent node, we do not use `createAttachment(for:)` and just set `self.attachment` directly.
    
    public let audioNode: SKAudioNode
    
    public init(fileNamed fileName: String) {
        // TODO: Error-handling for missing files.
        self.audioNode = SKAudioNode(fileNamed: fileName)
        audioNode.autoplayLooped = false
        audioNode.isPositional = true
        super.init()
        self.attachment = self.audioNode
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        audioNode.run(SKAction.play())
    }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        audioNode.run(SKAction.stop()) // CHECK: Necessary?
        super.willRemoveFromEntity(withNode: node)
    }
 
}
