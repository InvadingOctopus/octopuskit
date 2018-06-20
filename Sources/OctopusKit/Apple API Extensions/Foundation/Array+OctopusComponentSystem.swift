//
//  Array+OctopusComponentSystem.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/15.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import Foundation
import GameplayKit

extension Array where Element == OctopusComponentSystem {
    
    /// Creates a `OctopusComponentSystem` for the specified `GKComponent` class and adds it to this array.
    ///
    /// The new system is added to the end of the list, so it will be updated after all currently-added systems.
    public mutating func createSystem(forClass componentClass: GKComponent.Type) {
        // TODO: Warn against or discard duplicates.
        
        let newSystem = OctopusComponentSystem(componentClass: componentClass)
        self.append(newSystem)
        
        OctopusKit.logForComponents.add("\(newSystem) componentClass = \(componentClass), count = \(self.count)")
    }
    
    /// Creates `OctopusComponentSystem`s for the specified `GKComponent` classes and adds them to this array.
    ///
    /// The new systems are added to the end of the list in the order provided.
    public mutating func createSystems(forClasses componentClasses: [GKComponent.Type]) {
        for componentClass in componentClasses {
            self.createSystem(forClass: componentClass)
        }
    }
    
    /// Attempts to add the specified component to all the systems in this array that match the type of the component.
    public func addComponent(_ component: GKComponent) {
        for componentSystem in self {
            componentSystem.addComponent(component)
        }
    }
    
    /// Attempts to add all of the components from the specified entity, to all the systems in this array that match the types of the components.
    public func addComponents(foundIn entity: GKEntity) {
        for componentSystem in self {
            componentSystem.addComponent(foundIn: entity)
        }
    }
    
    /// Attempts to remove all of the components found in the specified entity, from all the systems in this array that match the types of the components.
    public func removeComponents(foundIn entity: GKEntity) {
        for componentSystem in self {
            componentSystem.removeComponent(foundIn: entity)
        }
    }
    
}

