//
//  MusicComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/15.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Use `AVAudioPlayer`, as it is more suitable for music according to Apple documentation.

// CHECK: A way to add multiple `AudioComponent`s to an entity, as GameplayKit replaces older components of the same type? We may only want a single `MusicComponent` but multiple `AudoComponents`.

// BUG: `isPositional = false` does not seem to be working.

import GameplayKit

/// Creates an `SKAudioNode` from the specified filename and plays it when this component is added to an entity, adding the music node to the entity's `SpriteKitComponent` node.
///
/// **Dependencies:** `SpriteKitComponent`
public final class MusicComponent: SpriteKitAttachmentComponent<SKAudioNode> {
    
    // ℹ️ DESIGN: As we have to setup the music in our initialization, and play it after it has been added to a parent node, we do not use `createAttachment(for:)` and just set `self.attachment` directly.
    
    public let musicNode: SKAudioNode
    
    public init(fileNamed fileName: String) {
        // TODO: Error-handling for missing files.
        self.musicNode = SKAudioNode(fileNamed: fileName)
        musicNode.autoplayLooped = true
        musicNode.isPositional = false // BUG: Not effective.
        super.init()
        self.attachment = self.musicNode
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        musicNode.run(SKAction.stop()) // CHECK: Necessary?
        super.willRemoveFromEntity(withNode: node)
    }
}
