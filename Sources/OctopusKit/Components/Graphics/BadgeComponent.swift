//
//  BadgeComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Allow dynamic badge reassignment?
// CHECK: Allow multiple badges, one at most in each direction?

import SpriteKit
import GameplayKit

/// Overlays a child node on an edge or corner of the entity's `SpriteKitComponent` node.
///
/// To change the badge, create a new `BadgeComponent`
///
/// **Dependencies:** `SpriteKitComponent`
public final class BadgeComponent: SpriteKitAttachmentComponent<SKNode> {
    
    public let badge: SKNode
    
    /// The edge or corner to display the badge in. Only compass directions are valid for this component.
    public var placement: OctopusDirection {
        didSet {
            if placement != oldValue { // Avoid redundancy.
                positionBadge()
            }
        }
    }
    
    public var zPosition: CGFloat {
        didSet {
            badge.zPosition = zPosition
        }
    }
    
    public init(
        badge: SKNode,
        placement: OctopusDirection = .northEast,
        zPosition: CGFloat = 1)
    {
        self.badge = badge
        self.placement = placement
        self.zPosition = zPosition
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createAttachment(for parent: SKNode) -> SKNode? {
        positionBadge(parentOverride: parent) // Manually specify the parent in case we don't have an `SpriteKitComponent` yet.
        return badge
    }
    
    /// Sets the badge's position at the specified edge or corner of the specified node. If no arguments are provided, then the component's `placement` property and the entity's `SpriteKitComponent` node are used.
    ///
    /// Only compass directions are valid for this method.
    public func positionBadge(placementOverride: OctopusDirection? = nil,
                              parentOverride: SKNode? = nil)
    {
        guard let parent = parentOverride ?? self.entityNode else { return }
        
        let placement = placementOverride ?? self.placement
        
        // TODO: Accomodate for different `anchorPoint` values?
        
        let (maxX, maxY) = (parent.frame.size.width, parent.frame.size.height)
        var (x, y) = (parent.frame.size.width / 2, parent.frame.size.height / 2)
        
        switch placement { // TODO: Fix
        case .north:        y = maxY
        case .northEast:    x = maxX; y = maxY
        case .east:         x = maxX
        case .southEast:    x = maxX; y = 0
        case .south:        y = 0
        case .southWest:    x = 0; y = 0
        case .west:         x = 0;
        case .northWest:    x = 0; y = maxY
        default: break
        }
        
        badge.position = CGPoint(x: x, y: y)
        badge.zPosition = zPosition // CHECK: Necessary?
    }
    
    // MARK: -
    
    /// Creates a text-based badge with the specified background and border.
    public class func createLabelBadge(
        text: String,
        background: SKColor! = nil,
        backgroundSizeOffset: CGFloat = 5.0,
        border: SKColor! = nil,
        borderSizeOffset: CGFloat = 3.0)
        -> SKLabelNode
    {
        // TODO: Improve parameter names and descriptions.
        // CHECK: Move to `OctopusUtility` or some other type?
        
        let label = SKLabelNode(text: text,
                                font: OctopusFont.spriteBubbleFontDefault,
                                horizontalAlignment: .center,
                                verticalAlignment: .center)
        
        let backgroundSize = label.frame.size + backgroundSizeOffset
        
        if let background = background {
            let labelBackground = SKSpriteNode(color: background, size: backgroundSize)
            labelBackground.zPosition = -1
            label.addChild(labelBackground)
        }
        
        // The label border will just be a solid rectangle, obscured by the smaller background rectangle to create an outline.
        // CHECK: Use `SKShapeNode` for border?
        
        let borderSize = backgroundSize + borderSizeOffset
        
        if let border = border {
            let labelBorder = SKSpriteNode(color: border, size: borderSize)
            labelBorder.zPosition = -2
            label.addChild(labelBorder)
        }
        
        return label
    }
}

