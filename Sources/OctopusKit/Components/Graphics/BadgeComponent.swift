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
/// To change the badge, create a new `BadgeComponent`. May be subclassed to add more features, such as in `BubbleEmitterComponent`.
///
/// **Dependencies:** `NodeComponent`
open class BadgeComponent: NodeAttachmentComponent <SKNode> {
    
    public let badge: SKNode
    
    /// The edge or corner of the parent node to display the badge on. Only compass directions (`north`, `bottomRight`, etc.)  are accepted.
    public var placement: OKDirection {
        didSet {
            if  placement != oldValue { // Avoid redundancy.
                positionBadge()
            }
        }
    }
    
    // MARK: - Initialization
    
    public init(badge:          SKNode,
                parentOverride: SKNode?     = nil,
                placement:      OKDirection = .topRight,
                zPositionOverride: CGFloat? = nil)
    {
        self.badge     = badge
        self.placement = placement
        
        super.init(parentOverride:      parentOverride,
                   zPositionOverride:   zPositionOverride)
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
        guard let parent = parentOverride // CHECK: Is are these fallbacks correct or even necessary?
                        ?? badge.parent
                        ?? super.parentOverride
                        ?? self.entityNode
        else { return }
        
        let placement  = placementOverride ?? self.placement
        badge.position = parent.point(at: placement)
    }

}

