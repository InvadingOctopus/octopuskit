//
//  OctopusLogoScene.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-23
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import AVFoundation

/// A template for presenting the OctopusKit logo.
public final class OctopusLogoScene: OctopusScene {
    
    public override func willMove(to view: SKView) {
        self.name = "OctopusKit Logo Scene"
        super.willMove(to: view)
    }
    
    public override func prepareContents() {
        super.prepareContents()
        self.backgroundColor = .black
        self.isUserInteractionEnabled = false
        beginAct1()
    }
    
    public func beginAct1() {
        createLogo(text: "👾", completion: beginAct2)
        // audioEngine.playUISound("BeepLong")
    }
    
    public func beginAct2() {
        createLogo(text: "🐙", completion: beginAct3)
        // audioEngine.playUISound("BeepLong")
    }
    
    public func beginAct3() {
        introSceneDidFinish()
    }
    
    /// Signals the delegate to present the next scene (effectively the first scene of the game, after the logo.)
    public func introSceneDidFinish() {
       octopusSceneDelegate?.octopusSceneDidFinish(self)
    }
    
    /// Creates and animates the specified text.
    @discardableResult private func createLogo(text: String, completion: (() -> Void)? = nil) -> SKNode {
        
        let logo = SKLabelNode(text: text)
        logo.alignment = (.center, .center)
        logo.position = CGPoint(
            x: self.frame.midX,
            y: self.frame.midY)
        logo.alpha = 0
        logo.setScale(10.0)
        
        let animationDuration = 0.5
        let wait = 0.75
        let shrink = SKAction.scale(to: 1.0, duration: animationDuration).withTimingMode(.easeIn)
        let fadeIn = SKAction.fadeIn(withDuration: animationDuration)
        let shrinkAndFadeIn = SKAction.group([shrink, fadeIn])
        
        self.addChild(logo)
        
        if let completion = completion {
            logo.run(.sequence([
                shrinkAndFadeIn,
                .wait(forDuration: wait),
                .removeFromParent()]),
                     completion: completion
            )
        }
        
        return logo
    }
  
}
