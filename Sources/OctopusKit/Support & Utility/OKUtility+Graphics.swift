//
//  OKUtility+Graphics.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-09
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

// MARK: - SpriteKit Utilities

extension OKUtility {
    
    public static func loadFramesFromAtlas(named atlasName: String) -> [SKTexture] {
        // CREDIT: Apple Adventure Sample
        let atlas = SKTextureAtlas(named: atlasName)
        return (atlas.textureNames ).sorted().map { atlas.textureNamed($0) }
    }
    
    public static func runOneShotEmitter(emitter: SKEmitterNode, withDuration duration: CGFloat) {
        // CREDIT: Apple Adventure Sample
        let waitAction = SKAction.wait(forDuration: TimeInterval(duration))
        let birthRateSet = SKAction.run { emitter.particleBirthRate = 0.0 }
        let waitAction2 = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime + emitter.particleLifetimeRange))
        let removeAction = SKAction.removeFromParent()
        
        let sequence = [waitAction, birthRateSet, waitAction2, removeAction] // Correction: var changed to let
        emitter.run(SKAction.sequence(sequence))
    }
    
}

