//
//  BadgeComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Allow dynamic badge reassignment?
// CHECK: Allow multiple badges, one at most in each direction?

import SpriteKit
import GameplayKit

/// Overlays a child node on an edge or corner of the entity's `NodeComponent` node.
///
/// To change the badge, create a new `BadgeComponent`
///
/// **Dependencies:** `NodeComponent`
public final class BadgeComponent: NodeAttachmentComponent <SKNode> {
    
    public let badge: SKNode
    
    /// The edge or corner to display the badge in. Only compass directions are valid for this component.
    public var placement: OKDirection {
        didSet {
            if  placement != oldValue { // Avoid redundancy.
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
        badge:     SKNode,
        placement: OKDirection = .northEast,
        zPosition: CGFloat = 1)
    {
        self.badge     = badge
        self.placement = placement
        self.zPosition = zPosition
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createAttachment(for parent: SKNode) -> SKNode? {
        positionBadge(parentOverride: parent) // Manually specify the parent in case we don't have an `NodeComponent` yet.
        return badge
    }
    
    /// Sets the badge's position at the specified edge or corner of the specified node. If no arguments are provided, then the component's `placement` property and the entity's `NodeComponent` node are used.
    ///
    /// Only compass directions are valid for this method.
    public func positionBadge(placementOverride: OKDirection? = nil,
                              parentOverride:    SKNode?      = nil)
    {
        guard let parent = parentOverride ?? self.entityNode else { return }
        
        let placement    = placementOverride ?? self.placement
        let parentFrame  = parent.calculateAccumulatedFrame()
        
        // TODO: Accommodate for different `anchorPoint` values?
        
        let (maxX, maxY) = (parentFrame.maxX, parentFrame.maxY)
        let (minX, minY) = (parentFrame.minX, parentFrame.minY)
        var (x, y)       = (parentFrame.midX, parentFrame.midY)
        
        switch placement { // TODO: Verify
        case .north:        y = maxY
        case .northEast:    x = maxX; y = maxY
        case .east:         x = maxX
        case .southEast:    x = maxX; y = minY
        case .south:        y = minY
        case .southWest:    x = minX; y = minY
        case .west:         x = minX;
        case .northWest:    x = minX; y = maxY
        default: break
        }
        
        // Since the parent's min/max frame values will be in the grandparent's (e.g. scene) coordinate space, try to convert them to the parent's space.
        // TODO: Verify
        
        let position    = CGPoint(x: x, y: y)
        let grandParent = parent.parent
        
        badge.position  = grandParent?.convert(position, to: parent) ?? position
        badge.zPosition = zPosition // CHECK: Necessary?
    }
    
    // MARK: -
    
    /// Creates a text-based badge with the specified background and border.
    public class func createLabelBadge(
        text:                   String,
        background:             SKColor! = nil,
        backgroundSizeOffset:   CGFloat  = 5.0,
        border:                 SKColor! = nil,
        borderSizeOffset:       CGFloat  = 3.0)
        -> SKLabelNode
    {
        // TODO: Improve parameter names and descriptions.
        // CHECK: Move to `OKUtility` or some other type?
        
        let label = SKLabelNode(text: text,
                                font: OKFont.spriteBubbleFontDefault,
                                horizontalAlignment: .center,
                                verticalAlignment: .center)
        
        let backgroundSize = label.frame.size + backgroundSizeOffset
        
        if  let background = background {
            let labelBackground = SKSpriteNode(color: background, size: backgroundSize)
            labelBackground.zPosition = -1
            label.addChild(labelBackground)
        }
        
        // The label border will just be a solid rectangle, obscured by the smaller background rectangle to create an outline.
        // CHECK: Use `SKShapeNode` for border?
        
        let borderSize = backgroundSize + borderSizeOffset
        
        if  let border = border {
            let labelBorder = SKSpriteNode(color: border, size: borderSize)
            labelBorder.zPosition = -2
            label.addChild(labelBorder)
        }
        
        return label
    }
}

