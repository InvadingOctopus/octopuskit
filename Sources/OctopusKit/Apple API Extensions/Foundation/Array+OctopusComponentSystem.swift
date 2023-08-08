//
//  Array+OKComponentSystem.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/15.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests
// TODO: A way to combine array optionals?

import Foundation
import OctopusCore
import GameplayKit

public extension Array where Element == OKComponentSystem {
    
    /// Creates a `OKComponentSystem` for the specified `GKComponent` class and adds it to this array.
    ///
    /// The new system is added to the end of the list, so it will be updated after all currently-added systems.
    @inlinable
    mutating func createSystem(forClass componentClass: GKComponent.Type) {
        
        // Warn against duplicates.
        
        let isDuplicateSystem = self.contains { system in
            system.componentClass == componentClass
        }
        
        if  isDuplicateSystem {
            OKLog.logForErrors.debug("\(📜("\(componentClass) added more than once! This may cause components to update multiple times every frame."))")
        }
        
        // Create and add the new system.
        
        let newSystem = OKComponentSystem(componentClass: componentClass)
        self.append(newSystem)
        
        #if LOGECSVERBOSE
        OKLog.logForComponents.debug("\(📜("\(newSystem) componentClass = \(componentClass), count = \(self.count)"))")
        #endif
    }
    
    /// Creates `OKComponentSystem`s for the specified `GKComponent` classes and adds them to this array.
    ///
    /// The new systems are added to the end of the list in the order provided.
    @inlinable
    mutating func createSystems(forClasses componentClasses: [GKComponent.Type]) {
        for componentClass in componentClasses {
            self.createSystem(forClass: componentClass)
        }
    }
    
    /// Attempts to add the specified component to all the systems in this array that match the type of the component.
    @inlinable
    func addComponent(_ component: GKComponent) {
        for componentSystem in self {
            componentSystem.addComponent(component)
        }
    }
    
    /// Attempts to add all of the components from the specified entity, to all the systems in this array that match the types of the components.
    @inlinable
    func addComponents(foundIn entity: GKEntity) {
        for componentSystem in self {
            componentSystem.addComponent(foundIn: entity)
        }
    }
    
    /// Attempts to remove all of the components found in the specified entity, from all the systems in this array that match the types of the components.
    @inlinable
    func removeComponents(foundIn entity: GKEntity) {
        for componentSystem in self {
            componentSystem.removeComponent(foundIn: entity)
        }
    }
}

