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
    
    public var name: String?
    public var size: CGFloat?
    public var color: SKColor?
    
    public init(name: String? = nil,
                size: CGFloat? = nil,
                color: SKColor? = nil)
    {
        assert(name != nil || size != nil || color != nil, "OKFont initialized with all values nil!")
        self.name = name
        self.size = size
        self.color = color
    }
    
    /// - Returns: An `SKLabelNode` with the specified text and its font properties sent to this `OKFont`.
    public func createLabel(text: String) -> SKLabelNode {
        return SKLabelNode(text: text, font: self)
    }
    
    /// - Returns: An `SKLabelNode` with the specified text and alignment, and its font properties sent to this `OKFont`.
    public func createLabel(
        text: String,
        horizontalAlignment: SKLabelHorizontalAlignmentMode,
        verticalAlignment: SKLabelVerticalAlignmentMode)
        -> SKLabelNode
    {
        return SKLabelNode(
            text: text,
            font: self,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment)
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
