//
//  OffscreenRemovalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Removes the entity's `NodeComponent` node, and optionally the entity as well, from its parent after it has been outside the viewable area of its scene for the specified duration.
///
/// **Dependencies:** `NodeComponent`
public final class OffscreenRemovalComponent: OKComponent, UpdatedPerFrame {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self]
    }
    
    public fileprivate(set) var secondsElapsedSinceOffscreen: TimeInterval = 0
    
    /// The duration in seconds to wait after the node has moved off screen, before removing it.
    @GKInspectable public var removalDelay: TimeInterval = 0
    
    @GKInspectable public var shouldRemoveEntityOnNodeRemoval: Bool = true
    
    public override init() {
        super.init()
    }
    
    public init(removalDelay: TimeInterval = 0,
                shouldRemoveEntityOnNodeRemoval: Bool = true)
    {
        self.removalDelay = removalDelay
        self.shouldRemoveEntityOnNodeRemoval = shouldRemoveEntityOnNodeRemoval
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let unarchiver = aDecoder as? NSKeyedUnarchiver else {
            fatalError("init(coder:) has not been implemented for \(aDecoder)")
        }
        
        super.init(coder: aDecoder)
        
        if let removalDelay = unarchiver.decodeObject(forKey: "removalDelay") as? Double {
            self.removalDelay = removalDelay
        }
        
        if let shouldRemoveEntityOnNodeRemoval = unarchiver.decodeObject(forKey: "shouldRemoveEntityOnNodeRemoval") as? Bool {
            self.shouldRemoveEntityOnNodeRemoval = shouldRemoveEntityOnNodeRemoval
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        // TODO: Confirm that the scene intersection check works without a camera and with arbitrary scene/screen sizes.
        
        super.update(deltaTime: seconds)
                
        guard
            let node = super.entityNode, // We want either NodeComponent or GKSKNodeComponent (in case the Scene Editor was used))
            let scene = node.scene
            else {
                return }
        
        // If the node is within the scene or its camera,
        if (scene.camera != nil && scene.camera!.contains(node))
            || (scene.camera == nil && scene.intersects(node))
        {
            secondsElapsedSinceOffscreen = 0 // Reset the timer.
        }
        else {
            
            // But if the node is "offscreen" (not in its scene's area),
            // for a duration longer than the specified delay,
            // remove it.
            
            secondsElapsedSinceOffscreen += seconds
            
            if secondsElapsedSinceOffscreen >= removalDelay {
                
                node.removeFromParent()
                
                if  shouldRemoveEntityOnNodeRemoval,
                    let entity = self.entity,
                    let entityDelegate = (self.entity as? OKEntity)?.delegate
                {
                    entityDelegate.entityDidRequestRemoval(entity)
                }
            }
        }
    }
    
    /// Resets the removal countdown to `0` even if the node is offscren.
    public func resetTimer() {
        secondsElapsedSinceOffscreen = 0
    }
}
