//
//  BubbleEmitterComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import SpriteKit
import GameplayKit

// MARK: - Bubble

/// Represents a temporary node that "bubbles" out from a parent node, such as a number showing the damage or healing received by a character, usually animated as "floating" upwards.
public struct NodeBubble {
    
    public let node:            SKNode

    public let initialPosition: CGPoint
    public let initialAlpha:    CGFloat?
    
    public let animation:       SKAction
    public let removalDelay:    TimeInterval
    
    // REMOVED: public let completion: Closure?
    
    public static let bubbleKey = "OctopusKit.NodeBubble"
    
    // MARK: Animations
    
    /// The default disappearance animation for bubbles; float up while fading out. Fade-out begins after 20% of the `duration`.
    public static func floatAndFade(
        direction:  OKDirection  = .top,
        distance:   CGFloat      = 50,
        duration:   TimeInterval = 1.0)
        -> SKAction
    {
        
        let fadeDelay   = duration * 0.1
        let fadeOut     = SKAction.sequence([.wait(forDuration: fadeDelay),
                                             .fadeAlpha(to: 0.1, duration: duration)])
                         .timingMode(.easeOut)
        
        let floatAway   = SKAction.move(direction,
                                        distance: distance,
                                        duration: duration,
                                        timingMode: .easeOut)
        
        return SKAction.group([fadeOut, floatAway])
    }
    
    /// Blinks the bubble for the specified number of times then runs the default float and fade animation.
    public static func blinkThenFloatAndFade(
        blinkCount:     Int          = 3,
        floatDirection: OKDirection  = .top,
        floatDistance:  CGFloat      = 50,
        floatDuration:  TimeInterval = 1.0)
        -> SKAction
    {
        SKAction.sequence([
            SKAction.blink(withDelay: 0.1).repeat(count: blinkCount),
            floatAndFade(direction: floatDirection,
                         distance:  floatDistance,
                         duration:  floatDuration)
        ])
    }
    
    // MARK: Initializers
    
    /// Creates a bubble.
    /// - Parameters:
    ///   - node:               The graphic which will bubble out from a parent.
    ///   - initialPosition:    The position to reset `node` to before emitting it. Default: `(0,0)`
    ///   - initialAlpha:       The value to reset the `node.alpha` to before emitting it. If `nil` then the node's current `alpha` will be used, which may be `0` if the node was previously emitted. Default: `1`
    ///   - animation:          The `SKAction` to run on the node when emitting it. If `nil` then `NodeBubble.floatAndFade` is used with parameters depending on `removalDelay`. Default: `nil`
    ///   - removalDelay:       The duration after which to remove the emitted `node` from its parent.
    public init(
        node:               SKNode,
        initialPosition:    CGPoint     = .zero,
        initialAlpha:       CGFloat?    = 1,
        animation:          SKAction?   = nil,
        removalDelay:       TimeInterval = 1.0)
    {
        self.node           = node
        
        self.initialPosition = initialPosition
        self.initialAlpha   = initialAlpha
        
        self.animation      = animation ?? NodeBubble.floatAndFade(duration: removalDelay)
        
        self.removalDelay   = removalDelay
        
        if  node.name == nil
        ||  node.name!.isEmpty
        {
            node.name = "Bubble"
        }
    }
    
    /// Creates a text bubble, with the proper horizontal and vertical alignment for the `SKLabelNode`, depending on the `spawnAtBottom` flag.
    public init(
        text:               String,
        font:               OKFont      = OKFont.bubbleFontDefault,
        color:              SKColor     = .white,
        animation:          SKAction?   = nil,
        removalDelay:       TimeInterval = 1.0)
    {
        let label = SKLabelNode(text:  text,
                                font:  font.color(color),
                                horizontalAlignment: .center,
                                verticalAlignment:   .bottom)
        
        label.name = "Bubble: \(text)"
        
        self.init(node:             label,
                  animation:        animation,
                  removalDelay:     removalDelay)
    }
    
    // MARK: Emission
    
    /// Adds the bubble `node` to the specified parent, resets its position and alpha, animates it, then removes the bubble from the parent at the end of its animation.
    /// - Parameters:
    ///   - parent:     The parent node to emit the bubble from. This **must** be a node with a non-zero `frame` and be part of a grandparent node or scene. If the parent is an `SKNode` (which has an empty `frame`) or does not have a parent (scene) of its own, then the bubble will not be positioned or animated correctly.
    ///   - zPosition:  Sets the bubble `node.zPosition` to the specified value, otherwise uses the current `zPosition`. Default: `nil`
    /// - Returns: The emitted `node`.
    @inlinable @discardableResult
    public func emit(from parent:   SKNode,
                     zPosition:     CGFloat? = nil) -> SKNode
    {
        // MARK: Setup

        let bubble = self.node
        
        bubble.removeAllActions()
        bubble.position = self.initialPosition
        bubble.isHidden = false
        
        if  let zPosition = zPosition {
            bubble.zPosition = zPosition
        }
        
        if  let initialAlpha = self.initialAlpha {
            bubble.alpha = initialAlpha
        }
        
        // Add to parent
        
        bubble.removeFromParent() // Make sure
        parent.addChild(bubble)
        
        // MARK: Animate
        
        let delayedRemoval = SKAction.sequence([
            .wait(forDuration: removalDelay),
            .removeFromParent()])
        
        // REMOVED: let completion = self.completion ?? {} /// Just use an empty closure for the completion callback if the `completion` property is `nil`, to avoid duplicating code below for different `run()` calls (one with the `completion:` parameter and one without.)
        
        /// Start the removal countdown together with the animation (`group` not `sequence`).
        
        bubble.run(.group([animation,
                           delayedRemoval]),
                   withKey: NodeBubble.bubbleKey)
        
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
public final class BubbleEmitterComponent: BadgeComponent {
    
    // TODO: Tests
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self]
    }
        
    /// The bubble to emit when this component is added to an entity with a `NodeComponent`.
    public var initialBubble: NodeBubble?
    
    /// If `true`, various visual debugging aids are applied to assist with tracking bugs involving parents and placements etc.
    public let debug: Bool
    
    // MARK: Initialization
    
    /// Creates a `BubbleEmitterComponent` with an optional bubble to emit.
    ///
    /// - IMPORTANT: if the entity's `NodeComponent` node does not have a non-zero `frame` (e.g. an `SKNode` that contains other nodes), then bubbles will not be correctly positioned. Provide a `parentOverride` to a node with a non-zero `frame`.
    ///
    /// - Parameters:
    ///   - initialBubble:  The bubble to emit once when this component is added to an entity with a `NodeComponent`.
    ///   - parentOverride: By default, bubbles are added to the entity's `NodeComponent` node. If the entity node does not have a non-zero `frame`, such as an `SKNode` which contains other nodes, then the bubbles will not be positioned or animated correctly. Use this parameter to specify a parent with a non-zero `frame`.
    ///   - zPosition:      The zPosition of all bubbles. This should be a high enough value to ensure that bubbles are not obscured by other content. Default: `1`
    ///   - placement:      The edge or corner of the parent from which all bubbles should be emitted. Default: `top`
    ///   - debug:          If `true`, the bubble emitter node is changed to a visible rectangle and its placement is randomized after every emission, to assist with tracking bugs involving parents and placements etc.
    public init(initialBubble:  NodeBubble? = nil,
                parentOverride: SKNode?     = nil,
                placement:      OKDirection = .top,
                zPosition:      CGFloat     = 1,
                debug:          Bool        = false)
    {
        self.initialBubble  = initialBubble
        self.debug          = debug
        
        // The "badge" will be our emitter, the parent node of all bubbles, so they can be spawned from a fixed position in relation to the entity.
        
        let badge: SKNode
        
        if !debug {
            badge = SKNode()
        } else {
            badge = SKSpriteNode(color: .magenta, size: CGSize(widthAndHeight: 10))
                .blendMode(.screen)
        }
        
        super.init(badge:               badge,
                   parentOverride:      parentOverride,
                   placement:           placement,
                   zPositionOverride:   zPosition)
    }
            
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Emission
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
       
        // Emit the first bubble if any.
        guard let initialBubble = self.initialBubble else { return }
        self.emit(bubble: initialBubble)
    }
    
    /// Emits the specified bubble from this component's `parentOverride` or the entity's node.
    @inlinable @discardableResult
    public func emit(bubble:            NodeBubble,
                     zPositionOverride: CGFloat? = nil) -> SKNode?
    {
        if  debug {
            // Randomize the emitter placement if debugging.
            super.placement = OKDirection.compassDirections.randomElement()!
            debugLog("badge placement: \(super.placement) — position: \(badge.position)", topic: "\(self)")
        }
        
        // Emit the bubbles from our "badge" (which is just the fixed SKNode used for positioning).
        
        return bubble.emit(from:        self.badge,
                           zPosition:   zPositionOverride ?? super.zPositionOverride)
    }
    
    public override func willRemoveFromEntity(withNode node: SKNode) {
        self.initialBubble?.node.removeFromParent()
    }
    
}
