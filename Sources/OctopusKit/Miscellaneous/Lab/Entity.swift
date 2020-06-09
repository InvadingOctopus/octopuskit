//
//  Entity.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import GameplayKit

public protocol Entity:
    /// class, // Already on `ComponentContainer`
    Nameable,
    ComponentContainer,
    UpdatablePerFrame
{
    // ℹ️ Not currently in use; This is mostly preparation for future independence from GameplayKit, if needed.
    
    var delegate: EntityDelegate? { get }
    
    // init()
    
    func removeFromDelegate()
}

/// A protocol for types that manage entities, such as `OKScene`.
public protocol EntityDelegate: class {
    
    func entity(_ entity: Entity, didAddComponent component:     Component)
    func entity(_ entity: Entity, willRemoveComponent component: Component)
    
    @discardableResult
    func entity(_ entity: Entity, didSpawn spawnedEntity: Entity) -> Bool
    
    func entityDidRequestRemoval(_ entity: Entity)
}
