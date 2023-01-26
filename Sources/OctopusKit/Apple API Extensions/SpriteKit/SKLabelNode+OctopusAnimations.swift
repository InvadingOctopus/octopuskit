//
//  SKLabelNode+OctopusAnimations.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit

extension SKLabelNode {
    
    /// Changes the font color to the specified value, then cycles it between the original color and the specified alternate color for the specified number of times.
    @inlinable
    public func cycleColor(with alternateColor: SKColor = .clear,
                         durationPerCycle duration: TimeInterval = 0.075,
                         repeat count: Int = 1)
    {
        guard count > 0 else { return }
        
        let originalColor = self.fontColor
        var setAlternateColor = true
        
        let flashSequence = SKAction.sequence([
            SKAction.run({
                self.fontColor = setAlternateColor ? alternateColor : originalColor
                setAlternateColor = !setAlternateColor
            }),
            SKAction.wait(forDuration: duration)
            ])
        
        // Repeat for `count` x 2 so that a complete pair of color/decolor actions is run in the block per each `count`.
        
        self.run(SKAction.repeat(flashSequence, count: count * 2),
                 withKey: SKAction.OKAnimationKeys.color)
    }
    
    /// Creates a "ghost" of this label behind it, adds it to the label's parent, scales it to the specified size while fading it to an alpha of `0.0` then removes it from the parent.
    ///
    /// - Returns: The ghost label, or `nil` if this label has no parent or text.
    @inlinable
    public func animateGhost(xScale: CGFloat = 1.25,
                           yScale: CGFloat = 1.0,
                           initialAlpha: CGFloat = 0.5,
                           duration: TimeInterval = 0.5)
                        -> SKLabelNode?
    {
        guard
            let parent = self.parent,
            let text = self.text
            else { return nil }
        
        let ghostLabel = SKLabelNode(text: text,
                                     font: self.font,
                                     horizontalAlignment: self.horizontalAlignmentMode,
                                     verticalAlignment: self.verticalAlignmentMode)
        
        let scale = SKAction.scaleX(by: xScale, y: yScale, duration: duration).timingMode(.easeOut)
        let fade = SKAction.fadeOut(withDuration: duration)
        let scaleAndFade = SKAction.group([scale, fade])
        
        ghostLabel.fontColor = self.fontColor
        ghostLabel.alpha = initialAlpha
        ghostLabel.position = self.position
        ghostLabel.zPosition = self.zPosition - 1 // Let's not obscure the actual label with outdated text if it gets updated during the ghost's animation.
        
        parent.addChild(ghostLabel)
        
        ghostLabel.run(SKAction.sequence([
            scaleAndFade,
            SKAction.removeFromParent()
            ]))
        
        return ghostLabel
    }
    
}
