//
//  BubbleEmitterComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

// MARK: - Bubble

/// Represents a temporary node that "bubbles" up from a parent node, such as a number showing the damage received by a character.
public struct NodeBubble {
    
    public let node:            SKNode

    public let offset:          CGPoint
    public let spawnAtBottom:   Bool
    
    public let alphaOnEmit:     CGFloat?
    public let blink:           Bool
    
    public let duration:        TimeInterval
    public let completion:      Closure?
    
    // MARK: Initializers
    
    public init(
        node:               SKNode,
        offset:             CGPoint     = .zero,
        spawnAtBottom:      Bool        = false,
        alphaOnEmit:        CGFloat?    = nil,
        blink:              Bool        = false,
        duration:           TimeInterval = 0.5,
        completion:         Closure?    = nil)
    {
        self.node           = node

        self.offset         = offset
        self.spawnAtBottom  = spawnAtBottom
        
        self.alphaOnEmit    = alphaOnEmit
        self.blink          = blink
        
        self.duration       = duration
        self.completion     = completion
        
        if  node.name == nil
            ||  node.name!.isEmpty
        {
            node.name = "Bubble"
        }
    }
    
    /// Creates a text bubble, with the proper horizontal and vertical alignment for the `SKLabelNode`, depending on the `spawnAtBottom` flag.
    public init(
        text:               String,
        font:               OKFont      = OKFont.spriteBubbleFontDefault,
        offset:             CGPoint     = .zero,
        spawnAtBottom:      Bool        = false,
        alphaOnEmit:        CGFloat?    = nil,
        blink:              Bool        = false,
        duration:           TimeInterval = 0.5,
        completion:         Closure?    = nil)
    {
        let label = SKLabelNode(text: text,
                                font: font,
                                horizontalAlignment: .center,
                                verticalAlignment: spawnAtBottom ? .top : .bottom)
        
        label.name = "Bubble: \(text)"
        
        self.init(node:             label,
                  offset:           offset,
                  spawnAtBottom:    spawnAtBottom,
                  alphaOnEmit:      alphaOnEmit,
                  blink:            blink,
                  duration:         duration,
                  completion:       completion)
    }
    
    // MARK: Emission
    
    @inlinable @discardableResult
    public func emit(from parent:   SKNode,
                     zPosition:     CGFloat?) -> SKNode
    {
        
        // TODO: Validate parent size and account for `anchorPoint`
        
        let parentFrame = parent.calculateAccumulatedFrame()
        let bubble      = self.node
        
        // Initialize position and alpha
        
        bubble.removeAllActions()
        
        bubble.position.x = offset.x // Reset the position in case the bubble is re-emitted.
        bubble.position.y = spawnAtBottom ? offset.y : parentFrame.size.height + offset.y
        
        if  let zPosition = zPosition {
            bubble.zPosition = zPosition
        }
        
        if  let alphaOnEmit = self.alphaOnEmit {
            bubble.alpha = alphaOnEmit
        }
        
        // Add to parent
        
        bubble.removeFromParent() // Make sure
        parent.addChild(bubble)
        
        // Animate
        
        let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: duration)
            .timingMode(.easeOut)
        
        let floatAway = SKAction.moveBy(x: 0, y: parentFrame.size.height / 2, duration: duration)
            .timingMode(.easeOut)
        
        let completion = self.completion ?? {} // Just use an empty closure for the completion callback if the `completion` property is `nil`, to avoid duplicating code below for different `run()` calls (one with the `completion:` parameter and one without.)
        
        if blink {
            
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
        
        // Return the emitted node
        
        return bubble
    }
}

// MARK: - BubbleComponent

/// Adds a child node which "floats" up like a bubble from the top or bottom of the entity's `NodeComponent` node (or the specified parent).
///
/// Useful for displaying status updates or damage values over a character etc.
///
/// **Dependencies:** `NodeComponent`
public final class BubbleEmitterComponent: OKComponent {
    
    // TODO: Tests
    // TODO: Fully customizable direction.
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self]
    }
    
    public var parentOverride:  SKNode?
    public var zPosition:       CGFloat = 1
    
    /// To emit when this component is added to an entity with a `NodeComponent`.
    public var initialBubble:   NodeBubble?
    
    // MARK: Initializers
    
    public init(initialBubble:  NodeBubble? = nil,
                parentOverride: SKNode? = nil,
                zPosition:      CGFloat = 1)
    {
        self.initialBubble  = initialBubble
        self.parentOverride = parentOverride
        self.zPosition      = zPosition
        super.init()
    }
            
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Emission
    
    public override func didAddToEntity(withNode node: SKNode) {
        guard let initialBubble = self.initialBubble else { return }
        self.emit(bubble: initialBubble)
    }
    
    /// Emits the specified bubble from this component's `parentOverride` or the entity's node.
    @inlinable @discardableResult
    public func emit(bubble: NodeBubble,
                     zPositionOverride: CGFloat? = nil) -> SKNode?
    {
        guard let parent = self.parentOverride ?? self.entityNode else { return nil }
    
        return bubble.emit(from: parent, zPosition: zPositionOverride ?? self.zPosition)
    }
    
//    @inlinable
//    public override func createAttachment(for parent: SKNode) -> SKNode? {
//        guard let initialBubble = self.initialBubble else { return nil }
//        return initialBubble.emit(from: parent)
//    }
    
}
