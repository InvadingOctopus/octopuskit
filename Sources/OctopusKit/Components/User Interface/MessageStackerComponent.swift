//
//  MessageStackerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/04.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Cleanup cruft from importing the legacy class.
// TODO: Improve comments/documentation.

import SpriteKit
import GameplayKit

public protocol MessageStackerDelegate: class {
    func messageStacker(_ stacker: MessageStackerComponent, willBeginDisplayingFirstMessage: String)
    func messageStacker(_ stacker: MessageStackerComponent, didFinishDisplayingLastMessage: String)
}

/// Adds a message stacker to the entity's `NodeComponent` node.
///
/// **Dependencies:** `NodeComponent`
public final class MessageStackerComponent: NodeAttachmentComponent<SKNode> {
    
    public weak var delegate: MessageStackerDelegate?
    
    // MARK: Graphics
    
    public fileprivate(set) var parent: SKNode?
    public fileprivate(set) var baseLayer: SKNode?
    public fileprivate(set) var messageLayer: SKNode?
    
    public let pushActionKey = "MessageStacker.Push" // CHECK: Should this be static?
    
    // MARK: - Messages
    
    public fileprivate(set) var messageLabels: [SKLabelNode] = []
    
    public let stackDirection: OKVerticalOrientation
    
    /// The delay before a message begins to fade out: the duration of how long a message is displayed.
    
    // Properties for next message
    
    public var font = OKFont(name: "Menlo", size: 12.0, color: .white)
    public var fontHorizontalAlignment: SKLabelHorizontalAlignmentMode = .left
    public var blendMode: SKBlendMode = .alpha
    public var verticalSpacing: CGFloat = 2.0
    
    public var pushDuration: TimeInterval = 0.5
    public var fadeDelay: TimeInterval = 1.0
    public var fadeDuration: TimeInterval = 0.75
    
    public var shouldFlashNewMessages: Bool
    
    public fileprivate(set) var newLabelPosition: CGPoint = CGPoint.zero
    
    // MARK: - Life Cycle
    
    public init(stackDirection: OKVerticalOrientation = .up,
                shouldFlashNewMessages: Bool = true,
                parentOverride: SKNode? = nil,
                positionOffset: CGPoint? = nil,
                zPositionOverride: CGFloat? = nil)
    {
        self.stackDirection = stackDirection
        self.shouldFlashNewMessages = shouldFlashNewMessages
        super.init(parentOverride: parentOverride,
                   positionOffset: positionOffset,
                   zPositionOverride: zPositionOverride)
    }
    
    public required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createAttachment(for parent: SKNode) -> SKNode? {
        
        guard
            let parentSize = (parent as? SKNodeWithDimensions)?.size,
            parentSize.width > 1
                && parentSize.height > 1
            else {
                OctopusKit.logForErrors("\(parent) width or height <= 1")
                return nil
        }
        
        self.parent = parent
        
        newLabelPosition.y = (stackDirection == OKVerticalOrientation.up) ? -1 : parent.frame.size.height // NOTE: `addMessage()` should set the new label's top or bottom to those values, respectively, depending on the stack direction.

        
        baseLayer = SKNode()
        messageLayer = SKNode()
        
        baseLayer?.addChild(messageLayer!) // TODO: Remove !
        return baseLayer
    }
    
    deinit {
        OctopusKit.logForDeinits("messages.count = \(messageLabels.count)") // TODO: Mention last message
    }
    
    // MARK: - Messages
    
    /// Adds a message to the vertically-scrolling stack and returns the new `SKLabelNode`.
    @discardableResult public func addMessage(
        _ message: String,
        overridingColor fontColor: SKColor? = nil,
        overridingSpacing: CGFloat? = nil,
        overridingBlendMode: SKBlendMode? = nil,
        withAction action: SKAction? = nil)
        -> SKLabelNode?
    {
        
        guard
            let parent = self.parent,
            let messageLayer = self.messageLayer
            else { return nil }
        
        if messageLabels.count < 1 {
            delegate?.messageStacker(self, willBeginDisplayingFirstMessage: message)
        }
        
        var initialY: CGFloat = 0.0
        var deltaY: CGFloat = 0.0
        let messageSpacing = overridingSpacing ?? self.verticalSpacing
        var previousLabel: SKLabelNode?
        let newLabel = SKLabelNode(text: "\(message)", font: self.font)
        
        newLabel.horizontalAlignmentMode = fontHorizontalAlignment
        newLabel.verticalAlignmentMode = (stackDirection == OKVerticalOrientation.up) ? .top : .bottom
        newLabel.blendMode = overridingBlendMode ?? blendMode
        
        if fontColor != nil {
            newLabel.fontColor = fontColor!
        }
        
        let labelHeight = newLabel.frame.height
        
        if messageLabels.count > 0 {
            previousLabel = messageLabels.last!
        }
        
        // ? Start just outside the edge of the ticker, depending on the direction of the stack, and add spacing if other messages already in view.
        // ? Start behind the most recent label.
        
        switch stackDirection {
        case .up:
            initialY = -1
            if previousLabel != nil  {
                initialY = (previousLabel!.position.y - previousLabel!.frame.height) - messageSpacing
            }
            
        case .down:
            initialY = parent.frame.height
            if previousLabel != nil {
                initialY = (previousLabel!.position.y + previousLabel!.frame.height) + messageSpacing
            }
        }
        
        switch newLabel.horizontalAlignmentMode {
        case .left:     newLabel.position.x = 0
        case .right:    newLabel.position.x = parent.frame.maxX
        case .center:   newLabel.position.x = parent.frame.midX
        
        @unknown default: fatalError() // CHECK: Is this the correct way to handle this?
        }
        
        newLabel.position.y = initialY
        
        messageLabels += [newLabel]
        messageLayer.addChild(newLabel)
        
        // Push all the labels in the stack...
        
        switch stackDirection {
        case .up:   deltaY = (-initialY) + labelHeight
        case .down: deltaY = -((initialY - parent.frame.height) + labelHeight)
        }
        
        let push = SKAction.moveBy(x: 0, y: deltaY, duration: pushDuration)
        push.timingMode = .easeOut
        
        for label in messageLabels {
            label.removeAction(forKey: pushActionKey) // Stop any previous movement actions so their distance doesn't keep increasing.
            label.run(push, withKey: pushActionKey)
        }
        
        // Begin animating and fading-out the new label...
        
        if shouldFlashNewMessages == true {
            newLabel.cycleColor(with: .clear, repeat: 3)
        }
        
        // NOTE: Include the pushDuration from the previous action.
        newLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: pushDuration + fadeDelay),
            SKAction.fadeOut(withDuration: fadeDuration),
            SKAction.removeFromParent()]),
                     completion: messageDidFinishFading)
        
        // Apply any extra actions specified by the caller...
        
        if let action = action {
            newLabel.run(action)
        }
        
        return newLabel
    }
    
    private func messageDidFinishFading() {
        
        guard
            let parent = self.parent,
            let messageLayer = self.messageLayer
            else { return }
        
        let lastMessage = messageLabels.remove(at: 0).text
        
        if messageLabels.count < 1 {
            messageLayer.position.y = 0 // In case `messageLayer` was being scrolled.
            messageLayer.position.y -= (parent.frame.size.height) // TODO: Compensate for a non-zero `anchorPoint` e.g.: (parent.frame.size.height * (parent as? SKSpriteNode)?.anchorPoint.y)
            
            delegate?.messageStacker(self, didFinishDisplayingLastMessage: lastMessage!) // TODO: Remove !
        }
        
        // OctopusKit.logForDebug("Ticker message removed: \"\(label.text)\" (remaining:\(messageLabels.count), in backlog:\(messageLabelsBacklog.count))")
    }

}

