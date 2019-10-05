//
//  DelayedRemovalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/16.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Removes this component's entity from the scene after the specified time has passed.
///
/// If the entity's `delegate` is `nil`, then only the entity's `SpriteKitComponent` node will be removed from its parent.
public final class DelayedRemovalComponent: OctopusComponent, OctopusUpdatableComponent {
    
    /// The duration in seconds to wait before removing the node.
    public var removalDelay: TimeInterval = 0
    
    public fileprivate(set) var secondsElapsed: TimeInterval = 0
    
    public init(removalDelay: TimeInterval) {
        self.removalDelay = removalDelay
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        secondsElapsed += seconds
        
        if
            let entity = self.entity,
            secondsElapsed >= removalDelay
        {
            entity.component(ofType: SpriteKitComponent.self)?.node.removeFromParent()
            
            if let entityDelegate = (self.entity as? OctopusEntity)?.delegate {
                entityDelegate.entityDidRequestRemoval(entity)
            }
        }
    }
}

