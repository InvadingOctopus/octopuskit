//
//  SKLabelNode+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

extension SKLabelNode {
    
    /// Creates an `SKLabelNode` and sets its properties to match the `OctopusFont`.
    public convenience init(font: OctopusFont) {
        // In case initializing the font is an expensive process, try to init with the font if name is provided.
        if font.name != nil {
            self.init(fontNamed: font.name)
        } else {
            self.init()
        }
        
        if font.color != nil {
            self.fontColor = font.color!
        }
        
        if font.size != nil {
            self.fontSize = font.size!
        }
    }
    
    /// Creates an `SKLabelNode` with the specified text and sets its font properties to matchthe `OctopusFont`.
    public convenience init(text: String, font: OctopusFont) {
        self.init(text: text)
        self.font = font
    }
    
    /// Convenient shorthand for setting alignment at initialization.
    ///
    /// Calls `init(text:)`.
    public convenience init(
        text: String,
        horizontalAlignment: SKLabelHorizontalAlignmentMode,
        verticalAlignment: SKLabelVerticalAlignmentMode)
    {
        self.init(text: text)
        self.horizontalAlignmentMode = horizontalAlignment
        self.verticalAlignmentMode = verticalAlignment
    }
    
    /// Convenient shorthand for setting font and alignment at initialization.
    ///
    /// Calls `init(font:)`.
    public convenience init(
        text: String,
        font: OctopusFont,
        horizontalAlignment: SKLabelHorizontalAlignmentMode,
        verticalAlignment: SKLabelVerticalAlignmentMode)
    {
        self.init(font: font)
        self.horizontalAlignmentMode = horizontalAlignment
        self.verticalAlignmentMode = verticalAlignment
        self.text = text
    }
    
    /// Encapsulates the label's font-related properties in an `OctopusFont`.
    public var font: OctopusFont {
        get {
            return OctopusFont(name: self.fontName, size: self.fontSize, color: self.fontColor)
        }
        set {
            if newValue.name != nil {
                self.fontName = newValue.name!
            }
            if newValue.color != nil {
                self.fontColor = newValue.color!
            }
            if newValue.size != nil {
                self.fontSize = newValue.size!
            }
        }
    }
    
    open func setAlignment(horizontal: SKLabelHorizontalAlignmentMode,
                             vertical: SKLabelVerticalAlignmentMode) {
        self.horizontalAlignmentMode = horizontal
        self.verticalAlignmentMode = vertical
    }
    
    /// Encapsulates the `horizontalAlignmentMode` and `verticalAlignmentMode` in a tuple.
    public var alignment: (horizontal: SKLabelHorizontalAlignmentMode, vertical: SKLabelVerticalAlignmentMode) {
        // CHECK: Is assigning multiple properties via tuples a good "idiomatic" idea?
        get {
            return (horizontal: self.horizontalAlignmentMode,
                    vertical: self.verticalAlignmentMode)
        }
        set {
            self.horizontalAlignmentMode = newValue.horizontal
            self.verticalAlignmentMode = newValue.vertical
        }
    }
    
}
