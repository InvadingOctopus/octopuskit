//
//  BubbleComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Adds a child node which "floats" up from the top or bottom of the entity's `NodeComponent` node (or the specified parent).
///
/// Useful for displaying damage values over a character etc.
///
/// - NOTE: To emit multiple bubbles from a single component, use `BubbleEmitterComponent`.
///
/// **Dependencies:** `NodeComponent`
@available(*, deprecated, message: "Use BubbleEmitterComponent")
public final class BubbleComponent: NodeAttachmentComponent <SKNode> {
    
    // TODO: Tests
    // TODO: Fully customizable direction.

    public let bubble:          SKNode
    public let yOffset:         CGFloat
    public let spawnAtBottom:   Bool
    public let duration:        TimeInterval
    public let shouldBlink:     Bool
    public let completion:      (() -> Void)?
    
    public init(
        bubble:             SKNode,
        yOffset:            CGFloat         = 0,
        spawnAtBottom:      Bool            = false,
        duration:           TimeInterval    = 0.5,
        shouldBlink:        Bool            = true,
        parentOverride:     SKNode?         = nil,
        zPositionOverride:  CGFloat         = 1,
        completion:         (() -> Void)?   = nil)
    {
        self.bubble         = bubble
        self.yOffset        = yOffset
        self.spawnAtBottom  = spawnAtBottom
        self.duration       = duration
        self.shouldBlink    = shouldBlink
        self.completion     = completion
        
        super.init(parentOverride:    parentOverride,
                   zPositionOverride: zPositionOverride)
    }
    
    /// Creates a text bubble.
    public convenience init(
        text:               String,
        font:               OKFont?         = nil,
        yOffset:            CGFloat         = 0,
        spawnAtBottom:      Bool            = false,
        duration:           TimeInterval    = 0.5,
        shouldBlink:        Bool            = true,
        parentOverride:     SKNode?         = nil,
        zPositionOverride:  CGFloat         = 1,
        completion:         (() -> Void)?   = nil)
    {
        let label = SKLabelNode(text: text,
                                font: font ?? OKFont.spriteBubbleFontDefault,
                                horizontalAlignment: .center,
                                verticalAlignment: spawnAtBottom ? .top : .bottom)
        
        self.init(bubble:               label,
                  yOffset:              yOffset,
                  spawnAtBottom:        spawnAtBottom,
                  duration:             duration,
                  shouldBlink:          shouldBlink,
                  parentOverride:       parentOverride,
                  zPositionOverride:    zPositionOverride,
                  completion:           completion)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createAttachment(for parent: SKNode) -> SKNode? {
        
        // TODO: Validate parent size and account for `anchorPoint`
        
        let parentFrame = parent.calculateAccumulatedFrame()
        
        // Position the bubble.
        
        bubble.position.y = spawnAtBottom ? yOffset : parentFrame.size.height + yOffset
        
        // Animate the bubble.
        
        let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: duration)
        fadeOut.timingMode = .easeOut
        
        let floatAway = SKAction.moveBy(x: 0, y: parentFrame.size.height / 2, duration: duration)
        floatAway.timingMode = .easeOut
        
        let completion = self.completion ?? {} // Just use an empty closure for the completion callback if the `completion` property is `nil`, to avoid duplicating code below for different `run()` calls (one with the `completion:` parameter and one without.)
        
        if shouldBlink {
            
            let hide    = SKAction.hide()
            let unhide  = SKAction.unhide()
            
            let blink   = SKAction.sequence([
                hide,
                .wait(forDuration: 0.1),
                unhide])
            
            bubble.run(.sequence([
                .wait(forDuration: 0.1),
                blink,
                .wait(forDuration: 0.1),
                blink,
                .wait(forDuration: 0.1),
                .group([fadeOut, floatAway]),
                .removeFromParent()]),
                       completion: completion)
        
        } else {
            
            bubble.run(.sequence([
                .group([fadeOut, floatAway]),
                .removeFromParent()]),
                       completion: completion)
        }
        
        return bubble
    }
    
}

