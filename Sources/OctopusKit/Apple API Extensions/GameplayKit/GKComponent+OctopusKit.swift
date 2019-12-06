//
//  GKComponent+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/24.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import GameplayKit

extension GKComponent {
    
    /// Convenient shorthand for accessing the SpriteKit node that is associated the `SpriteKitComponent` of this component's entity.
    ///
    /// If the entity does not have an `SpriteKitComponent` or `GKSKNodeComponent` (in that order) or a `RelayComponent` linked to one of those component types, then this property will be `nil`.
    @inlinable
    public var entityNode: SKNode? {
        #if LOGECSVERBOSE
        debugLog("self: \(self)")
        #endif
        return self.entity?.node
    }
    
    /// Returns the component of type `componentClass`, or a `RelayComponent` linked to a component of that type, if it's present in the entity that is associated with this component.
    ///
    /// Returns `nil` if the requested `componentClass` is this component's class, as that would not be a "co" component, and entities can have only one component of each class.
    @inlinable
    public func coComponent <ComponentType> (
        ofType componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool = false)
        -> ComponentType? where ComponentType: GKComponent
    {
        #if LOGECSVERBOSE
        debugLog("ComponentType: \(ComponentType.self), componentClass: \(componentClass), ignoreRelayComponents: \(ignoreRelayComponents), self: \(self)")
        #endif
        
        if  componentClass == type(of: self) {
            
            #if LOGECSVERBOSE
            debugLog("componentClass == type(of: self) — Returning `nil`")
            #endif
            
            return nil
        
        }   else if ignoreRelayComponents {
            
            let match = self.entity?.component(ofType: componentClass)
            
            #if LOGECSVERBOSE
            debugLog("self.entity?.component(ofType: componentClass) == \(match)")
            #endif
            
            return match
            
        }   else {
            
            let match = self.entity?.componentOrRelay(ofType: componentClass)
            
            #if LOGECSVERBOSE
            debugLog("self.entity?.componentOrRelay(ofType: componentClass) == \(match)")
            #endif
            
            return self.entity?.componentOrRelay(ofType: componentClass)
        }
    }
    
    /// A shortcut for `coComponent(ofType:)` without a parameter name to reduce text clutter.
    @inlinable
    public func coComponent <ComponentType> (
        _ componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool = false)
        -> ComponentType? where ComponentType: GKComponent
    {
        return self.coComponent(ofType: componentClass, ignoreRelayComponents: ignoreRelayComponents)
    }
    
    /// Returns `type(of: self)`
    ///
    /// This property is used to accurately determine the type of generic components at runtime.
    ///
    /// A `RelayComponent` overrides this property to return the type of its `target`. This lets `GKEntity.componentOrRelay(ofType:)` return a `RelayComponent.target` that matches the requested component class.
    @objc
    open var componentType: GKComponent.Type {
        // This is a workaround for the bug where `OctopusComponent.requiredComponents` could not be correctly matched with `GKEntity.component(ofType:)` at runtime when the entity has a `RelayComponent` for the dependency.
        // See comments for `GKEntity.componentOrRelay(ofType:)`
        // THANKS: https://forums.swift.org/u/TellowKrinkle
        // https://forums.swift.org/t/type-information-loss-when-comparing-generic-variables-with-an-array-of-metatypes/30650
        
        #if LOGECSVERBOSE
        debugLog("self: \(self), \(type(of: self))")
        #endif
        
        return type(of: self)
    }
    
    /*
    /// Used by `RelayComponent` to substitute itself with the target component.
    @objc open var baseComponent: GKComponent? {
        // CHECK: Include? Will it improve correctness and performance in GKEntity.componentOrRelay(ofType:) or is it unnecessary?
        // THANKS: https://forums.swift.org/u/TellowKrinkle
        // https://forums.swift.org/t/type-information-loss-when-comparing-generic-variables-with-an-array-of-metatypes/30650
        return self
    }
    */
    
}
