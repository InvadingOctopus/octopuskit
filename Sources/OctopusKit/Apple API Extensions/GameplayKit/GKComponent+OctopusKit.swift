//
//  GKComponent+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/24.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import GameplayKit

public extension GKComponent {
    
    /// Convenient shorthand for accessing the SpriteKit node that is associated the `SpriteKitComponent` of this component's entity.
    ///
    /// If the entity does not have an `SpriteKitComponent` or `GKSKNodeComponent` (in that order) or a `RelayComponent` linked to one of those component types, then this property will be `nil`.
    var entityNode: SKNode? {
        return self.entity?.node
    }
    
    /// Returns the component of type `componentClass`, or a `RelayComponent` linked to a component of that type, if it's present in the entity that is associated with this component.
    func coComponent<ComponentType>(
        ofType componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool = false)
        -> ComponentType? where ComponentType: GKComponent
    {
        if ignoreRelayComponents {
            return self.entity?.component(ofType: componentClass)
        }
        else {
            return self.entity?.component(ofType: componentClass)
                ?? self.entity?.component(ofType: RelayComponent<ComponentType>.self)?.target
        }
    }
    
    /// A version of `coComponent(ofTYpe:)` without a parameter name to reduce text clutter.
    func coComponent<ComponentType>(
        _ componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool = false)
        -> ComponentType? where ComponentType: GKComponent
    {
        return self.coComponent(ofType: componentClass, ignoreRelayComponents: ignoreRelayComponents)
    }
}
