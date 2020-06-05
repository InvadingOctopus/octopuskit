//
//  DebugFrameComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/06/03.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// Adds markers outlining the accumulated frame of the entity's `NodeComponent` node.
public final class DebugFrameComponent: NodeAttachmentComponent <SKNode> {
    
    public let midColor:        SKColor
    public let markerColor:     SKColor
    public let lineColor:       SKColor
    
    public let markerSize:      CGSize
    
    public let alpha:           CGFloat
    public let blendMode:       SKBlendMode
    
    public private(set) var debugFrame: SKNode?
    
    public init(midColor:       SKColor = .cyan,
                markerColor:    SKColor = .magenta,
                lineColor:      SKColor = .yellow,
                markerSize:     CGSize  = .init(widthAndHeight: 10),
                alpha:          CGFloat = 0.75,
                blendMode:      SKBlendMode = .screen,
                zPositionOverride: CGFloat = 100)
    {
        self.midColor       = midColor
        self.markerColor    = markerColor
        self.lineColor      = lineColor
        self.markerSize     = markerSize
        self.alpha          = alpha
        self.blendMode      = blendMode
        
        super.init(zPositionOverride: zPositionOverride)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createAttachment(for parent: SKNode) -> SKNode? {
        
        let debugFrame = SKNode()
        
        let center = SKSpriteNode(color: midColor, size: markerSize)
            .position(parent.point(at: .center))
            .alpha(alpha)
            .blendMode(blendMode)
        
        debugFrame.addChild(center)
        
        // Edge markers
        
        let directions: [OKDirection] = [.topLeft, .top, .topRight,
                                         .left, .right,
                                         .bottomLeft, .bottom, .bottomRight]
        
        for direction in directions {
            
            let marker = SKSpriteNode(color: markerColor, size: markerSize)
                .position(parent.point(at: direction))
                .blendMode(blendMode)
            
            debugFrame.addChild(marker)
        }
        
        // TODO: Lines

        self.debugFrame = debugFrame
        
        return self.debugFrame
    }
}
