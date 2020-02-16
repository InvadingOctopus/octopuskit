//
//  OKButtonEntity.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/04.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

public typealias OctopusButtonEntity = OKButtonEntity

/// Encapsulates components for representing a tappable button on the screen.
public final class OKButtonEntity: OKEntity {
    
    // TODO: Sprite button animated by `TextureDictionaryComponent` and `TextureAnimationComponent`.
    
    /// Creates a labelled button with the specified dimensions and text.
    public convenience init(
        name: String? = nil,
        text: String,
        frame: CGRect,
        backgroundColor: SKColor,
        font: OKFont = OKFont.buttonFontDefault,
        parentOverride: SKNode? = nil,
        pointerEventComponent: PointerEventComponent,
        tapHandler: @escaping NodePointerClosureComponent.NodePointerClosureType)
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
                  pointerEventComponent: pointerEventComponent,
                  tapHandler: tapHandler)
        
    }
    
    /// Creates a button with the specified node as the visual representation.
    ///
    /// NOTE: IGNORE WARNING: This initializer may trigger a warning log about missing `requiredComponents` because it will add the `SpriteKitComponent` last, after other components.
    public convenience init(
        name: String = "Button",
        node: SKNode,
        parentOverride: SKNode? = nil,
        pointerEventComponent: PointerEventComponent,
        tapHandler: @escaping NodePointerClosureComponent.NodePointerClosureType)
    {
        self.init(name: name,
                  pointerEventComponent: pointerEventComponent,
                  tapHandler: tapHandler)
        
        // NOTE: IGNORE WARNING: This will cause a warning about missing `requiredComponents` because we are adding the `SpriteKitComponent` last.
        
        self.addComponent(SpriteKitComponent(node: node, addToNode: parentOverride))
    }
    
    fileprivate init(
        name: String = "Button",
        pointerEventComponent: PointerEventComponent,
        tapHandler: @escaping NodePointerClosureComponent.NodePointerClosureType)
    {
        
        super.init()
        self.name = name
        
        var pointerHandlers: [NodePointerState : NodePointerClosureComponent.NodePointerClosureType] = [:]
        
        pointerHandlers[.tapped] = tapHandler
        
        self.addComponents([
            RelayComponent(for: pointerEventComponent),
            NodePointerStateComponent(),
            NodePointerClosureComponent(closures: pointerHandlers)
            ])
        
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
