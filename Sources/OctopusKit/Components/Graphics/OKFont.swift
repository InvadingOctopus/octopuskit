//
//  OKFont.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/25.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

public typealias OctopusFont = OKFont

public struct OKFont {
    
    public var name:    String?
    public var size:    CGFloat?
    public var color:   SKColor?
    
    public init(name:   String?  = nil,
                size:   CGFloat? = nil,
                color:  SKColor? = nil)
    {
        guard name != nil || size != nil || color != nil else {
            OctopusKit.logForErrors("OKFont initialized with all values nil")
            fatalError()
        }
        
        self.name  = name
        self.size  = size
        self.color = color
    }
    
    // MARK: Modifiers
    
    /// Returns a new copy of this font with the specified color.
    @inlinable
    public func color(_ newColor: SKColor) -> OKFont {
        OKFont(name:  self.name,
               size:  self.size,
               color: newColor)
    }
    
    /// Returns a new copy of this font with the specified size.
    @inlinable
    public func size(_ newSize: CGFloat) -> OKFont {
        OKFont(name:  self.name,
               size:  newSize,
               color: self.color)
    }
    
    // MARK: Label Construction
    
    /// Returns a new `SKLabelNode` with the specified text and its font properties sent to this `OKFont`.
    @inlinable
    public func createLabel(text: String) -> SKLabelNode {
        SKLabelNode(text: text, font: self)
    }
    
    /// Returns a new `SKLabelNode` with the specified text and alignment, and its font properties sent to this `OKFont`.
    @inlinable
    public func createLabel(
        text:                String,
        horizontalAlignment: SKLabelHorizontalAlignmentMode,
        verticalAlignment:   SKLabelVerticalAlignmentMode)
        -> SKLabelNode
    {
        SKLabelNode(
            text: text,
            font: self,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment:   verticalAlignment)
    }
    
    // MARK: - Predefined Fonts
    
    public static let debugFont = OKFont(name:  "Menlo-Bold",
                                         size:  12,
                                         color: .gray)
    
    public static let buttonFontDefault = OKFont(name:  "Menlo-Bold",
                                                 size:  20,
                                                 color: .white)
    
    public static let bubbleFontDefault = OKFont(name:  "Menlo-Bold",
                                                 size:  10,
                                                 color: .white)
}
