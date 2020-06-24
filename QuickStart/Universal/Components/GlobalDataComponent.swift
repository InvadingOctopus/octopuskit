//
//  GlobalDataComponent.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/07/27.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

/// A custom component for the QuickStart project that holds some simple data to be shared across multiple game states and scenes.
final class GlobalDataComponent: OKComponent, RequiresUpdatesPerFrame, ObservableObject {
    
    public var secondsElapsed: TimeInterval = 0
    
    /// A more slowly-updated version of `secondsElapsed`. Should reduce strain on SwiftUI updates? :)
    public var secondsElapsedRounded: Int = 0 {
        willSet {
            // ℹ️ We don't use @Published here because that causes a SwiftUI update every frame, even when this value does not change between seconds.
            if newValue != secondsElapsedRounded {
                self.objectWillChange.send()
            }
        }
    }
    
    @Published
    public var emojiCount: Int = 0 {
        didSet {
            emojiHighScore = max(emojiCount, emojiHighScore)
        }
    }
    
    @OKUserDefault(key: "emojiHighScore", defaultValue: 50) public var emojiHighScore: Int
    
    override func update(deltaTime seconds: TimeInterval) {
        secondsElapsed += seconds
        secondsElapsedRounded = Int(secondsElapsed.rounded(.down))
    }
}

