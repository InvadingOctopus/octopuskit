//
//  SKLabelNode+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

extension SKLabelNode {
    
    // MARK: Initializers
    
    /// Creates an `SKLabelNode` and sets its properties to match the `OKFont`.
    public convenience init(font: OKFont) {
        // In case initializing the font is an expensive process, try to init with the font if name is provided.
        if  font.name != nil {
            self.init(fontNamed: font.name)
        } else {
            self.init()
        }
        
        if  font.color != nil {
            self.fontColor = font.color!
        }
        
        if  font.size != nil {
            self.fontSize = font.size!
        }
    }
    
    /// Creates an `SKLabelNode` with the specified text and sets its font properties to match the `OKFont`.
    @inlinable
    public convenience init(text: String, font: OKFont) {
        self.init(text: text)
        self.font = font
    }
    
    /// Creates an `SKLabelNode` with the specified character.
    ///
    /// This may be convenient in cases like creating labels from random characters, e.g. `SKLabelNode(character: "🟥🟧🟨🟩🟦🟪".randomElement()!)`
    ///
     /// Calls `init(text:)`.
    @inlinable
    public convenience init(character: Character) {
        self.init(text: String(character))
    }
    
    /// Creates an `SKLabelNode` with the specified character and sets its font properties to match the `OKFont`.
    ///
    /// This may be convenient in cases like creating labels from random characters, e.g. `SKLabelNode(character: "🟥🟧🟨🟩🟦🟪".randomElement()!, font: font)`
    @inlinable
    public convenience init(character: Character, font: OKFont) {
        self.init(text: String(character), font: font)
    }
    
    /// Convenient shorthand for setting alignment at initialization.
    ///
    /// Calls `init(text:)`.
    public convenience init(
        text: String,
        horizontalAlignment: SKLabelHorizontalAlignmentMode,
        verticalAlignment:   SKLabelVerticalAlignmentMode)
    {
        self.init(text: text)
        self.horizontalAlignmentMode = horizontalAlignment
        self.verticalAlignmentMode   = verticalAlignment
    }
    
    /// Convenient shorthand for setting font and alignment at initialization.
    ///
    /// Calls `init(font:)`.
    public convenience init(
        text: String,
        font: OKFont,
        horizontalAlignment: SKLabelHorizontalAlignmentMode,
        verticalAlignment:   SKLabelVerticalAlignmentMode)
    {
        self.init(font: font)
        self.horizontalAlignmentMode = horizontalAlignment
        self.verticalAlignmentMode   = verticalAlignment
        self.text = text
    }
    
    /// Creates a label centered inside an optional colored rectangle and border.
    public convenience init(
        text:               String,
        font:               OKFont   = OKFont.bubbleFontDefault.color(.white),
        backgroundColor:    SKColor? = nil,
        backgroundPadding:  CGFloat  = 10.0,
        borderColor:        SKColor? = nil,
        borderPadding:      CGFloat  = 5.0)
    {
        /// TODO: Use `SKShapeNode` and rounded rectangles.
        
        self.init(text: text,
                  font: font,
                  horizontalAlignment: .center,
                  verticalAlignment:   .center)
        
        let backgroundSize          = self.frame.size + backgroundPadding
        
        if  let backgroundColor     = backgroundColor {
            let background          = SKSpriteNode(color: backgroundColor, size: backgroundSize)
            background.zPosition    = -1
            self.addChild(background)
        }
        
        // The label border will just be a solid rectangle, obscured by the smaller background rectangle to create an outline.
        // CHECK: Use `SKShapeNode` for border?
        
        if  let borderColor     = borderColor {
            let borderSize      = backgroundSize + borderPadding
            let border          = SKSpriteNode(color: borderColor, size: borderSize)
            border.zPosition    = -2
            self.addChild(border)
        }
        
    }
    
    // MARK: - Properties
    
    /// Encapsulates the label's font-related properties in an `OKFont`.
    @inlinable
    public var font: OKFont {
        get { OKFont(name: self.fontName, size: self.fontSize, color: self.fontColor) }
        set {
            if  newValue.name  != nil {
                self.fontName   = newValue.name!
            }
            if  newValue.color != nil {
                self.fontColor  = newValue.color!
            }
            if  newValue.size  != nil {
                self.fontSize   = newValue.size!
            }
        }
    }
    
    @inlinable
    open func setAlignment(horizontal: SKLabelHorizontalAlignmentMode,
                           vertical:   SKLabelVerticalAlignmentMode)
    {
        self.horizontalAlignmentMode = horizontal
        self.verticalAlignmentMode   = vertical
    }
    
    /// Encapsulates the `horizontalAlignmentMode` and `verticalAlignmentMode` in a tuple.
    @inlinable
    public var alignment: (horizontal: SKLabelHorizontalAlignmentMode,
                           vertical:   SKLabelVerticalAlignmentMode)
        {
        // CHECK: Is assigning multiple properties via tuples a good "idiomatic" idea?
        get {
            return (horizontal: self.horizontalAlignmentMode,
                    vertical:   self.verticalAlignmentMode)
        }
        set {
            self.horizontalAlignmentMode = newValue.horizontal
            self.verticalAlignmentMode   = newValue.vertical
        }
    }

}
