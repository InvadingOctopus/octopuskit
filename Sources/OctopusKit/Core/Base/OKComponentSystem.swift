//
//  OKComponentSystem.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/13.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

public typealias OctopusComponentSystem = OKComponentSystem

/// Manages component objects of a single specific class. Adds validation and convenience methods for common tasks to `GKComponentSystem`.
public final class OKComponentSystem: GKComponentSystem <GKComponent> {

    public override init(componentClass cls: AnyClass) {
        
        // Warn about unnecessary systems.
        
        if !(cls.self is RequiresUpdatesPerFrame.Type)
        && !(cls.self is TurnBased.Type)
        {
            OctopusKit.logForWarnings("System created for component that is not marked as RequiresUpdatesPerFrame: \(cls)")
            OctopusKit.logForTips("Either this system is unnecessary, or you forgot to add RequiresUpdatesPerFrame protocol conformance to \(cls)")
        }
        
        super.init(componentClass: cls)
    }
    
    /// Adds an applicable component to this system, ignoring duplicates.
    public final override func addComponent(_ component: GKComponent) {
        
        guard !(components.contains(component)) else {
            OctopusKit.logForDebug("\(component) already in system – Skipping")
            return
        }
        
        OctopusKit.logForComponents("\(self) ← \(component)")

        super.addComponent(component)
    }

    /// Adds all applicable components from the specified entity to this system, ignoring duplicates.
    public final override func addComponent(foundIn entity: GKEntity) {
        super.addComponent(foundIn: entity)
    }
    
    /// Adds all applicable components from the specified entities to this system, ignoring duplicates.
    public final func addComponents(foundIn entities: [GKEntity]) {
        // ⚠️ NOTE: Cannot add this method as an extension to `GKComponentSystem` as of 2017/10/14, because "Extension of a generic Objective-C class cannot access the class's generic parameters at runtime"
        
        for entity in entities {
            self.addComponent(foundIn: entity)
        }
    }
}
