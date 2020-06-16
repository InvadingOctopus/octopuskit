//
//  DelayedRemovalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Removes this component's entity from the scene after the specified time has passed, and optionally also removes all components from the entity.
///
/// If the entity's `delegate` is `nil`, then only the entity's `NodeComponent` node will be removed from its parent.
public final class DelayedRemovalComponent: OKComponent, RequiresUpdatesPerFrame {
    
    /// The duration in seconds to wait before removing the node.
    public var removalDelay:        TimeInterval
   
    /// If `true`, the entity is told to remove all its components, after it is removed from the scene.
    ///
    /// - WARNING: ⚠️ Setting this to `true` may cause a runtime crash related to modifying the components array in a component system.
    public var removeComponents:    Bool = false
    
    public fileprivate(set) var secondsElapsed: TimeInterval = 0
    
    /// Initializes a component which removes its entity from the scene.
    /// - Parameters:
    ///   - removalDelay:       The duration to wait before initiating the removal.
    ///   - removeComponents:   If `true`, the entity is told to remove all its components as well, after it's removed from the scene. This may be necessary in some cases for objects to be freed from memory and `deinit`. Default: `false`
    public init(removalDelay:       TimeInterval,
                removeComponents:   Bool = false)
    {
        self.removalDelay       = removalDelay
        self.removeComponents   = removeComponents
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        secondsElapsed += seconds
        
        if  let entity = self.entity,
            secondsElapsed >= removalDelay
        {
            #if LOGECSVERBOSE
            OctopusKit.logForComponents("Removing \(entity)", object: "\(self)")
            #endif
            
            entityNode?.removeFromParent()
            entityDelegate?.entityDidRequestRemoval(entity)
            
            if  removeComponents {
                entity.removeAllComponents()
            }
        }
    }
}

