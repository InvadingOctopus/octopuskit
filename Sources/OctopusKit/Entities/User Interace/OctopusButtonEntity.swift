//
//  OctopusButtonEntity.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/04.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Encapsulates components for representing a tappable button on the screen.
public final class OctopusButtonEntity: OctopusEntity {
    
    // TODO: Sprite button animated by `TextureDictionaryComponent` and `TextureAnimationComponent`.
    
    /// Creates a labelled button with the specified dimensions and text.
    public convenience init(
        name: String? = nil,
        text: String,
        frame: CGRect,
        backgroundColor: SKColor,
        font: OctopusFont = OctopusFont.buttonFontDefault,
        parentOverride: SKNode? = nil,
        touchEventComponent: TouchEventComponent,
        tapHandler: @escaping NodeTouchClosureComponent.NodeTouchClosureType)
    {
        let buttonSprite = SKSpriteNode(color: backgroundColor, size: frame.size)
        buttonSprite.position = frame.center
        
        let label = SKLabelNode(text: text,
                                font: font,
                                horizontalAlignment: .center,
                                verticalAlignment: .center)
        
        buttonSprite.addChild(label)
        
        self.init(name: name ?? "\(text) Button", // If no name is specified, set it to the text.
                  node: buttonSprite,
                  parentOverride: parentOverride,
                  touchEventComponent: touchEventComponent,
                  tapHandler: tapHandler)
        
    }
    
    /// Creates a button with the specified node as the visual representation.
    public convenience init(
        name: String = "Button",
        node: SKNode,
        parentOverride: SKNode? = nil,
        touchEventComponent: TouchEventComponent,
        tapHandler: @escaping NodeTouchClosureComponent.NodeTouchClosureType)
    {
        self.init(name: name,
                  touchEventComponent: touchEventComponent,
                  tapHandler: tapHandler)
        
        self.addComponent(SpriteKitComponent(node: node, addToNode: parentOverride))
    }
    
    fileprivate init(
        name: String = "Button",
        touchEventComponent: TouchEventComponent,
        tapHandler: @escaping NodeTouchClosureComponent.NodeTouchClosureType)
    {
        
        super.init()
        self.name = name
        
        var touchHandlers: [NodeTouchComponent.TouchInteractionState : NodeTouchClosureComponent.NodeTouchClosureType] = [:]
        
        touchHandlers[.tapped] = tapHandler
        
        self.addComponents([
            RelayComponent(for: touchEventComponent),
            NodeTouchComponent(),
            NodeTouchClosureComponent(closures: touchHandlers)
            ])
        
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
