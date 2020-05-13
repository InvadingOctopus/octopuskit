//
//  TitleEffectsComponent.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/22.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

/// A demonstration component that creates random effects for the title/main menu scene.
final class TitleEffectsComponent: OKComponent, UpdatedPerFrame {
    
    override func update(deltaTime seconds: TimeInterval) {
        
        guard
            let parent = entityNode,
            (parent.scene as? OKScene)?.currentFrameNumber.isMultiple(of: 3) ?? false,
            let parentSize = (entityNode as? SKNodeWithDimensions)?.size
            else { return }
        
        let line = createRandomLine(parentSize: parentSize)
        parent.addChild(line)
    }
    
    func createRandomLine(parentSize: CGSize) -> SKShapeNode {
    
        let line = SKShapeNode(rectOf: CGSize(width: parentSize.width, height: 2))
        
        line.lineWidth = CGFloat(Int.random(in: 1...10))
        line.strokeColor = SKColor.brightColors.randomElement()!
        line.alpha = CGFloat([0.25, 0.5].randomElement()!)
        line.blendMode = .screen
        
        line.run(
            .group([
                .scaleY(to: 3, duration: 0.5),
                .sequence([
                    .wait(forDuration: 0.1),
                    .fadeOut(withDuration: 0.3),
                    .removeFromParent()])
            ]))
        
        line.position = CGPoint(x: 0,
                                y: CGFloat(Int.random(in: -Int(parentSize.height) ... Int(parentSize.height))))
        
        return line
    }
}
