//
//  GameStateLabelComponent.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/06/22.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

/// Creates a label, attaches it to the `SpriteKitComponent` node of the entity, and sets the text of the label to the name of the current game state.
final class GameStateLabelComponent: SpriteKitAttachmentComponent<SKLabelNode>, OctopusUpdatableComponent {
    
    var stateLabel: SKLabelNode?
    
    var stateName: String {
        switch OctopusKit.shared?.gameController.currentState {
        case is LogoState:      return "LogoState"
        case is TitleState:     return "TitleState"
        case is PlayState:      return "PlayState"
        case is PausedState:    return "PausedState"
        case is GameOverState:  return "GameOverState"
        default:                return "[unknown state]"
        }
    }
    
    override func createAttachment(for parent: SKNode) -> SKLabelNode? {
      
        let stateLabel = SKLabelNode(text: stateName,
                                     font: OctopusFont(name: "AvenirNextCondensed-Bold",
                                                       size: 25,
                                                       color: .white))
        
        stateLabel.setAlignment(horizontal: .center, vertical: .top)
        
        if let view = (parent as? SKScene)?.view {
            stateLabel.insetPositionBySafeArea(at: .top, forView: view)
        }
        
        self.stateLabel = stateLabel
        return stateLabel
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        stateLabel?.text = stateName
    }
}

