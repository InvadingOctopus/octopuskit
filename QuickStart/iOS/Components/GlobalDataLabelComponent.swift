//
//  GlobalDataLabelComponent.swift
//  OctopusKitQuickstart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/07/27.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit
import OctopusKit

/// A custom component for the Quickstart project that displays the data from a `GlobalDataComponent`.
final class GlobalDataLabelComponent: SpriteKitAttachmentComponent<SKLabelNode>, OctopusUpdatableComponent {
    
    override var requiredComponents: [GKComponent.Type]? {
        return [GlobalDataComponent.self]
    }
    
    var globalDataLabel: SKLabelNode?
    
    override func createAttachment(for parent: SKNode) -> SKLabelNode? {
        
        let globalDataLabel = SKLabelNode(text: "Global Data",
                                          font: OctopusFont(name: "Menlo-Bold",
                                                            size: 15,
                                                            color: .white))
        
        globalDataLabel.setAlignment(horizontal: .left, vertical: .center)
        globalDataLabel.numberOfLines = 3
        
        if let view = (parent as? SKScene)?.view {
            globalDataLabel.position.x = parent.frame.minX + 10
            globalDataLabel.position.y += 100
            globalDataLabel.insetPositionBySafeArea(at: .top, forView: view)
        }
        
        self.globalDataLabel = globalDataLabel
        return globalDataLabel
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let globalDataComponent = coComponent(GlobalDataComponent.self) else { return }
        
        globalDataLabel?.text = """
        Global Data Component: \(globalDataComponent.dataString)
        Shows seconds since start
        and persists across scenes.
        """
    }
}

