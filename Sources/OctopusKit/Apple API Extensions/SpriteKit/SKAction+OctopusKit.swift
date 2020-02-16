//
//  SKAction+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit

extension SKAction {
    
    // MARK: - Types
    
    /// Keys for custom actions.
    ///
    /// Useful for searching for and stopping repeating actions, and to override actions that modify the same properties of a node.
    ///
    /// - Note: These keys must be manually specified when calling `run(_:withKey:)` on a node.
    public struct OKAnimationKeys {
        public static let alpha = "OctopusKit.Animation.Alpha"
        public static let blink = "OctopusKit.Animation.Blink"
        public static let color = "OctopusKit.Animation.Color"
        public static let scale = "OctopusKit.Animation.Scale"
    }
    
    // MARK: - Convenience Methods
    
    /// Sets the `timingMode` and returns self.
    ///
    /// Useful for chaining calls to an `SKAction` initializer.
    @inlinable
    open func withTimingMode(_ timingMode: SKActionTimingMode) -> SKAction {
        self.timingMode = timingMode
        return self
    }
    
    /// Creates an action that idles for a specified period of time then executes the supplied closure.
    ///
    /// - Important: Take care to use capture lists to avoid strong reference cycles in closures.
    @inlinable
    open func waitForDurationAndRunClosure(interval: TimeInterval,
                                           closure: @escaping () -> Void)
                                        -> SKAction
    {
        return SKAction.sequence([
            SKAction.wait(forDuration: interval),
            SKAction.run(closure)
            ])
    }
    
    // MARK: - Custom Animations
    
    /// Creates an action that cycles a node's hidden state between `true` and `false` with the specified delay in between.
    ///
    /// Makes the node visible before blinking it.
    open class func blink(
        withDelay delay: TimeInterval = 0.1)
        -> SKAction
    {
        let blinkOut = SKAction.hide()
        let blinkIn = SKAction.unhide()
        
        let blinkOutIn = SKAction.sequence([
            blinkOut,
            SKAction.wait(forDuration: delay),
            blinkIn,
            SKAction.wait(forDuration: delay)])
        
        return SKAction.sequence([
            blinkIn, // In case the node is hidden before this action begins.
            blinkOutIn])
    }
    
    /// Creates an action that scales the node's size to the specified values then reverts it to `1.0`.
    open class func bulge(
        xScale: CGFloat,
        yScale: CGFloat,
        scalingDuration: TimeInterval = 0.35,
        scalingTimingMode: SKActionTimingMode = .easeOut,
        revertDuration: TimeInterval = 0.15,
        revertTimingMode: SKActionTimingMode = .easeOut)
        -> SKAction
    {
        return SKAction.sequence([
            SKAction.scaleX(by: xScale, y: yScale, duration: scalingDuration).withTimingMode(scalingTimingMode),
            SKAction.scale(to: 1.0, duration: revertDuration).withTimingMode(revertTimingMode)])
    }
    
    /// Creates an action that animates a sprite's blend factor to `1.0`.
    ///
    /// This action can only be executed by an `SKSpriteNode` object.
    open class func colorizeIn(withDuration duration: TimeInterval = 0.25) -> SKAction {
        return SKAction.colorize(withColorBlendFactor: 1.0, duration: duration)
    }
    
    /// Creates an action that animates a sprite's blend factor to `0.0`.
    ///
    /// This action can only be executed by an `SKSpriteNode` object.
    open class func colorizeOut(withDuration duration: TimeInterval = 0.25) -> SKAction {
        return SKAction.colorize(withColorBlendFactor: 0.0, duration: duration)
    }
    
    /// Creates an action that immediately changes the colorization of a sprite to the `initialColor` and `blendFactor`, then cycles the colorization once between the specified target color then back to the initial color.
    ///
    /// This action can only be executed by an `SKSpriteNode` object.
    open class func cycleColor(
        from initialColor: SKColor = .clear,
        to targetColor: SKColor,
        blendFactor: CGFloat = 1.0,
        initialToTargetDuration: TimeInterval = 0.25,
        targetToInitialDuration: TimeInterval = 0.25,
        initialToTargetTimingMode: SKActionTimingMode = .linear,
        targetToInitialTimingMode: SKActionTimingMode = .linear)
        -> SKAction
    {
        let setInitialColor = SKAction.colorize(with: initialColor, colorBlendFactor: blendFactor, duration: 0)
        
        let initialToTargetColorize = SKAction.colorize(with: targetColor, colorBlendFactor: blendFactor, duration: initialToTargetDuration)
        
        let targetToInitialColorize = SKAction.colorize(with: initialColor, colorBlendFactor: blendFactor, duration: targetToInitialDuration)
        
        return SKAction.sequence([
            setInitialColor,
            initialToTargetColorize,
            targetToInitialColorize])
    }
    
    /// Creates an action that immediately changes the alpha value of the node to `0.0` then increases it to `targetAlpha` if specified, otherwise `1.0`, over the specified duration.
    ///
    /// The `timingMode` affects the fade-in.
    open class func fadeInFromZero(
        to targetAlpha: CGFloat = 1.0,
        withDuration duration: TimeInterval = 1.0,
        timingMode: SKActionTimingMode = .linear)
        -> SKAction
    {
        let fadeToZero = SKAction.fadeAlpha(to: 0, duration: 0)
        let fadeIn = SKAction.fadeAlpha(to: targetAlpha, duration: duration).withTimingMode(timingMode)
        
        return SKAction.sequence([
            fadeToZero,
            fadeIn])
    }
    
    /// Creates an action that animates the alpha value of the node to `0.0` then removes the node from its parent.
    ///
    /// The `timingMode` affects the fade-out.
    open class func fadeOutAndRemove(
        withDuration duration: TimeInterval = 1.0,
        timingMode: SKActionTimingMode = .linear)
        -> SKAction
    {
        return SKAction.sequence([
            SKAction.fadeOut(withDuration: duration).withTimingMode(timingMode),
            SKAction.removeFromParent()])
    }
    
    /// Creates an action that simultaneously animates the alpha value of the node to `0.0` and its scale to the specified target, then removes the node from its parent.
    open class func fadeOutAndScaleAndRemove(
        to scale: CGFloat = 1.25,
        duration: TimeInterval = 0.15,
        scaleTimingMode: SKActionTimingMode = .easeOut,
        fadeTimingMode: SKActionTimingMode = .easeOut)
        -> SKAction
    {
        let scale = SKAction.scale(to: scale, duration: duration).withTimingMode(scaleTimingMode)
        let fadeOut = SKAction.fadeOut(withDuration: duration).withTimingMode(fadeTimingMode)
        let scaleAndFadeOut = SKAction.group([scale, fadeOut])
        
        return SKAction.sequence([
            scaleAndFadeOut,
            SKAction.removeFromParent()])
    }
    
    /// Creates an action that immediately changes the alpha value of a node to `initialAlpha`, then repeatedly animates the alpha between `initialAlpha` and `targetAlpha` until the action is stopped.
    open class func pulseAlpha(
        from initialAlpha: CGFloat = 0.1,
        to targetAlpha: CGFloat = 0.4,
        initialToTargetDuration: TimeInterval = 0.25,
        targetToInitialDuration: TimeInterval = 0.25,
        initialToTargetTimingMode: SKActionTimingMode = .linear,
        targetToInitialTimingMode: SKActionTimingMode = .linear)
        -> SKAction
    {
        let setInitialAlpha = SKAction.fadeAlpha(to: initialAlpha, duration: 0)
        
        let initialToTargetFade = SKAction.fadeAlpha(to: targetAlpha, duration: initialToTargetDuration).withTimingMode(initialToTargetTimingMode)

        let targetToInitialFade = SKAction.fadeAlpha(to: initialAlpha, duration: targetToInitialDuration).withTimingMode(targetToInitialTimingMode)
        
        let pulse = SKAction.sequence([initialToTargetFade, targetToInitialFade])
        
        return SKAction.sequence([setInitialAlpha,
                                  SKAction.repeatForever(pulse)])
    }
    
}
