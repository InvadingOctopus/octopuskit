//
//  MessageTickerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/17.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Cleanup cruft from importing the legacy class.
// TODO: Improve comments/documentation.

import SpriteKit
import GameplayKit

public protocol MessageTickerDelegate: class {
    func messageTicker(_ ticker: MessageTickerComponent, willBeginScrollingFirstMessage: String)
    func messageTicker(_ ticker: MessageTickerComponent, didFinishScrollingLastMessage: String)
}

/// Adds a message ticker to the entity's `NodeComponent` node.
///
/// - NOTE: Requires the parent node to be a `SKSpriteNode` and have an `anchorPoint` of `(x: 0, y: 0)`
///
/// **Dependencies:** `NodeComponent`
public final class MessageTickerComponent: NodeAttachmentComponent<SKNode>, RequiresUpdatesPerFrame {
    
    public weak var delegate: MessageTickerDelegate?
    
    // MARK: Graphics
    
    public fileprivate(set) var parent: SKNode?
    public fileprivate(set) var baseLayer: SKNode?
    public fileprivate(set) var messageLayer: SKNode?
    
    public var stateTransitionDuration: TimeInterval = 0.5
    
    public var backgroundDefaultAlpha: CGFloat = 0.6 {
        didSet {
            guard let background = entityNode else { return }
            if  background.isHidden == false {
                background.alpha = backgroundDefaultAlpha
            }
        }
    }
    
    // MARK: Messages
    
    public var maximumMessages = 5
    @GKInspectable public var scrollingSpeedModifier: TimeInterval = 0.0
    
    public fileprivate(set) var messageLabels: [SKLabelNode] = []
    public fileprivate(set) var messagesBacklog: [String] = []
    
    // MARK: Settings
    
    @GKInspectable public var shouldSpeedUpOnTouch: Bool = true
    @GKInspectable public var shouldHideParentNodeWhenNoMessages: Bool = false
    
    // Properties for the next message
    
    public var font = OKFont(name: "Menlo", color: .white) // TODO: Remove hardcode
    public var messageBlendMode: SKBlendMode = .alpha
    public var messageSpacing: CGFloat = 16.0
    public var messageSeparator = ""
    
    // MARK: Action Keys
    // CHECK: Should these be static?
    
    private let hideParentActionKey = "MessageTicker.HideParent"
    private let pauseActionKey = "MessageTicker.Pause"
    
    // MARK: - Life Cycle
    
    public init(scrollingSpeedModifier: TimeInterval = 0.0,
                shouldSpeedUpOnTouch: Bool = true,
                shouldHideParentNodeWhenNoMessages: Bool = false,
                parentOverride: SKNode? = nil)
    {
        self.scrollingSpeedModifier = scrollingSpeedModifier
        self.shouldSpeedUpOnTouch = shouldSpeedUpOnTouch
        self.shouldHideParentNodeWhenNoMessages = shouldHideParentNodeWhenNoMessages
        super.init(parentOverride: parentOverride)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let unarchiver = aDecoder as? NSKeyedUnarchiver else {
            fatalError("init(coder:) has not been implemented for \(aDecoder)")
        }
        
        super.init(coder: aDecoder)
        
        if let scrollingSpeedModifier = unarchiver.decodeObject(forKey: "scrollingSpeedModifier") as? Double {
            self.scrollingSpeedModifier = TimeInterval(scrollingSpeedModifier)
        }
        
        if let shouldSpeedUpOnTouch = unarchiver.decodeObject(forKey: "shouldSpeedUpOnTouch") as? Bool {
            self.shouldSpeedUpOnTouch = shouldSpeedUpOnTouch
        }
        
        if let shouldHideParentNodeWhenNoMessages = unarchiver.decodeObject(forKey: "shouldHideParentNodeWhenNoMessages") as? Bool {
            self.shouldHideParentNodeWhenNoMessages = shouldHideParentNodeWhenNoMessages
        }
    }
    
    public override func createAttachment(for parent: SKNode) -> SKNode? {
        
        guard
            parent.frame.width > 1
            && parent.frame.height > 1
            else {
            OctopusKit.logForErrors("\(parent) accumulated width or height <= 1")
            return nil
        }
        
        self.parent = parent
        
        baseLayer = SKNode()
        messageLayer = SKNode()
                
        baseLayer?.addChild(messageLayer!) // TODO: Remove !
        return baseLayer
    }
    
    #if os(iOS)
    
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // MARK: Input
        
        // TODO: Implement an abstraction for detecting and storing touches inside and outside our node
        
        guard
            let touchEventComponent = coComponent(TouchEventComponent.self),
            let node = entityNode,
            let parent = node.scene,
            let messageLayer = self.messageLayer
            else { return }
        
        if
            let touchEvent = touchEventComponent.touchesBegan,
            shouldSpeedUpOnTouch
        {
            for touch in touchEvent.touches {
                if node.contains(touch.location(in: parent)) { // TODO: Verify
                    messageLayer.speed = 3.0 // TODO: Remove hardcode
                    break
                }
            }
        }
        
        if touchEventComponent.touchesEnded != nil {
            messageLayer.speed = 1.0
        }
        
    }
    
    #endif
    
    deinit {
        OctopusKit.logForDeinits() // TODO: Mention last message
    }
    
    // MARK: - Messages
    
    /// Adds a horizontally-scrolling label to the ticker's queue and returns the new SKLabelNode.
    @discardableResult public func addMessage(
        _ message: String,
        overridingColor fontColor: SKColor? = nil,
        overridingBlendMode: SKBlendMode? = nil,
        withAction action: SKAction? = nil)
        -> SKLabelNode?
    {
        
        guard
            let parent = self.parent,
            let messageLayer = self.messageLayer
            else { return nil }
        
        // TODO: IMPORTANT: Seems to have a limit on how long the off-view scroll layer can get! It disappears at around 1800 pixels!
        
        beginScrollingState()
        
        if messageLabels.count < 1 {
            delegate?.messageTicker(self, willBeginScrollingFirstMessage: message)
        } else if messageLabels.count >= maximumMessages { // Add to the backlog if we have already too many messageLabels queued, and the removeMessage() function should take care of adding them back in.
            messagesBacklog.append(message)
            return nil
        }
        
        var initialX: CGFloat = 0.0
        var deltaX: CGFloat = 0.0
        
        let newLabel = SKLabelNode(text: "\(message)",
            font: self.font,
            horizontalAlignment: .left,
            verticalAlignment: .center)
        
        newLabel.fontSize = parent.frame.height - 4 // TODO: Verify sizing scheme
        newLabel.blendMode = overridingBlendMode ?? messageBlendMode
        
        if fontColor != nil {
            newLabel.fontColor = fontColor!
        }
        
        initialX = parent.frame.width // Start just outside the edge of the ticker.
        
        if messageLabels.count > 0 { // Other messages already in view?
            if messageLabels.last!.frame.maxX > parent.frame.width { // Is the last message's right edge still outside?
                
                newLabel.text = "\(messageSeparator) \(message)" // HACK: A space after the separator because there seems to be an space before it anyway :(
                
                initialX = messageLabels.last!.frame.maxX // Attach to the end of the last message
                
                if messageSeparator == "" { // Add some space if we don't have a separator string.
                    initialX += messageSpacing
                }
            }
        }
        
        newLabel.position = CGPoint(
            x: initialX,
            y: parent.frame.size.height / 2) // TODO: Verify Y placement
        messageLabels += [newLabel]
        messageLayer.addChild(newLabel)
        
        // OctopusKit.logDebug.add("Ticker message: \"\(message)\" (active:\(messageLabels.count), backlog:\(messagesBacklog.count))")
        
        deltaX = -(initialX + newLabel.frame.width) // Negative because we're scrolling to the left
        
        let scroll = SKAction.moveBy(x: deltaX, y: 0.0, duration: TimeInterval(-deltaX) / (96.0 + scrollingSpeedModifier))
        newLabel.run(SKAction.sequence([
            scroll,
            SKAction.removeFromParent()]),
                     completion: messageDidFinishScrolling)
        
        // Apply any extra actions specified by the caller...
        
        if let action = action {
            newLabel.run(action)
        }
        
        return newLabel
    }
    
    private func beginScrollingState() {
        
        guard let background = entityNode else { return }
        
        // ⚠️ NOTE: Do NOT rely on `.isHidden`, because if the actions from `finishScrollingState()` are still running they can prevent up this transition!
        
        background.removeAction(forKey: hideParentActionKey)
        
        if background.alpha < backgroundDefaultAlpha {
            background.run(SKAction.sequence([
                SKAction.unhide(),
                SKAction.fadeAlpha(to: backgroundDefaultAlpha, duration: stateTransitionDuration)]))
        }
    }
    
    private func messageDidFinishScrolling() {
        let lastMessage = messageLabels.remove(at: 0).text
        
        // Re-add messageLabels in the backlog...
        if messagesBacklog.count > 0 {
            addMessage(messagesBacklog[0])
            messagesBacklog.remove(at: 0)
        }
        
        if messageLabels.count < 1 {
            finishScrollingState()
            delegate?.messageTicker(self, didFinishScrollingLastMessage: lastMessage!) // TODO: CHECK: forced unwrap
        }
        
        // OctopusKit.logForDebug("Ticker message removed: \"\(label.text)\" (remaining:\(messageLabels.count), in backlog:\(messagesBacklog.count))")
    }
    
    private func finishScrollingState() {
        
        guard let background = entityNode else { return }
        
        if shouldHideParentNodeWhenNoMessages == true && background.isHidden == false {
            background.run(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.0, duration: stateTransitionDuration),
                SKAction.hide()]),
                           withKey: hideParentActionKey)
        }
    }
    
    public func togglePause() {
        
        guard
            let messageLayer = self.messageLayer,
            let background = entityNode
            else { return }
        
        messageLayer.isPaused = !messageLayer.isPaused
        
        if messageLayer.isPaused == true {
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
            background.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])), withKey: pauseActionKey)
        } else {
            background.removeAction(forKey: pauseActionKey)
            background.alpha = 1.0
        }
    }

}

