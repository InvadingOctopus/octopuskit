//
//  TouchTestComponent.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/20.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

/// A custom component for the QuickStart project that changes the color of a sprite depending on the state of a touch that interacts with it.
final class TouchVisualFeedbackComponent: OctopusComponent, OctopusUpdatableComponent {
    
    override var requiredComponents: [GKComponent.Type]? {
        return [SpriteKitComponent.self,
                NodeTouchComponent.self]
    }
    
    var defaultColor = SKColor.blue
    
    override func didAddToEntity(withNode node: SKNode) {
        
        // TODO: COMMENT
        
        guard let sprite = node as? SKSpriteNode else { return }
        
        sprite.colorBlendFactor = 1.0
        self.defaultColor = sprite.color
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        // TODO: COMMENT
        
        guard
            let node = entityNode as? SKSpriteNode,
            let nodeTouchComponent = coComponent(ofType: NodeTouchComponent.self),
            nodeTouchComponent.stateChangedThisFrame
            else { return }
        
        // TODO: COMMENT
        
        switch nodeTouchComponent.state {
            
        case .touching:
            node.color = .cyan
            
        case .touchingOutside:
            node.color = .gray
            
        case .tapped:
            node.color = .green
            node.blink(times: 3)
                    
        case .disabled:
            node.color = .black
        
        default:
            node.color = defaultColor
        }
    }

}

