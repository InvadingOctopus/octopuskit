//
//  SKLabelNode+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import SpriteKit

public extension SKLabelNode {
    
    // MARK: Initializers
    
    /// Creates an `SKLabelNode` and sets its properties to match the `OKFont`.
    convenience init(font: OKFont) {
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
    convenience init(text: String, font: OKFont) {
        self.init(text: text)
        self.font = font
    }
    
    /// Creates an `SKLabelNode` with the specified character.
    ///
    /// This may be convenient in cases like creating labels from random characters, e.g. `SKLabelNode(character: "🟥🟧🟨🟩🟦🟪".randomElement()!)`
    ///
     /// Calls `init(text:)`.
    @inlinable
    convenience init(character: Character) {
        self.init(text: String(character))
    }
    
    /// Creates an `SKLabelNode` with the specified character and sets its font properties to match the `OKFont`.
    ///
    /// This may be convenient in cases like creating labels from random characters, e.g. `SKLabelNode(character: "🟥🟧🟨🟩🟦🟪".randomElement()!, font: font)`
    @inlinable
    convenience init(character: Character, font: OKFont) {
        self.init(text: String(character), font: font)
    }
    
    /// Convenient shorthand for setting alignment at initialization.
    ///
    /// Calls `init(text:)`.
    convenience init(
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
    convenience init(
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
    convenience init(
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
    final var font: OKFont {
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
    
    /// Encapsulates the `horizontalAlignmentMode` and `verticalAlignmentMode` in a tuple.
    @inlinable
    final var alignment: (horizontal: SKLabelHorizontalAlignmentMode,
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

    /// Converts an anchor point to or from the `horizontalAlignmentMode` and `verticalAlignmentMode`.
    final var anchorPoint: CGPoint {
        
        get {
            let x, y: CGFloat
            
            switch horizontalAlignmentMode {
            case .left:     x = 0
            case .center:   x = 0.5
            case .right:    x = 1
            @unknown default: fatalError("Invalid \(horizontalAlignmentMode)")
            }
            
            switch verticalAlignmentMode {
            case .bottom, .baseline:    y = 0
            case .center:               y = 0.5
            case .top:                  y = 1
            @unknown default: fatalError("Invalid \(verticalAlignmentMode)")
            }
            
            return CGPoint(x: x, y: y)
        }
        
        set {
            switch newValue.x {
            case ..<0.5:    horizontalAlignmentMode = .left
            case 0.5:       horizontalAlignmentMode = .center
            case 0.5...:    horizontalAlignmentMode = .right
            default:        horizontalAlignmentMode = .left /// CHECK: Should this be `center`?
            }
            
            switch newValue.y {
            case ..<0.5:    verticalAlignmentMode = .bottom /// DESIGN: This should not be `.baseline` as the expected behavior of setting an anchor of `0` would be to align the absolute bottom pixel at `y: 0`.
            case 0.5:       verticalAlignmentMode = .center
            case 0.5...:    verticalAlignmentMode = .top
            default:        verticalAlignmentMode = .baseline /// CHECK: Should this be `center`?
            }
        }
    }
    
    // MARK: - Modifiers
    // As in SwiftUI
    
    /// Sets the alignment(s) and returns the node.
    @inlinable @discardableResult
    final func alignment(horizontal: SKLabelHorizontalAlignmentMode,
                         vertical:   SKLabelVerticalAlignmentMode) -> SKLabelNode
    {
        self.horizontalAlignmentMode = horizontal
        self.verticalAlignmentMode   = vertical
        return self
    }
    
    /// Sets the font name and returns the node.
    @inlinable @discardableResult
    final func fontName(_ newValue: String?) -> SKLabelNode {
        self.fontName = newValue
        return self
    }
    
    /// Sets the font size and returns the node.
    @inlinable @discardableResult
    final func fontSize(_ newValue: CGFloat) -> SKLabelNode {
        self.fontSize = newValue
        return self
    }
    
    /// Sets the font color and returns the node.
    @inlinable @discardableResult
    final func fontColor(_ newValue: SKColor?) -> SKLabelNode {
        self.fontColor = newValue
        return self
    }
}
