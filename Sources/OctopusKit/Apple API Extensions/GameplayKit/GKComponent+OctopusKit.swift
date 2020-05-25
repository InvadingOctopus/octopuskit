//
//  GKComponent+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/24.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

extension GKComponent {

    // TODO: Implement the ability to call methods on components via a component system, in Swift? Maybe through `@dynamicCallable`?
    // "The component system will then forward any component-specific messages it receives to all registered instances of its component class." — https://developer.apple.com/documentation/gameplaykit/gkcomponentsystem
    // TODO: Tests
    
    /// Convenient shorthand for accessing the SpriteKit node that is associated with the `NodeComponent` of this component's entity.
    ///
    /// If the entity does not have an `NodeComponent` or `GKSKNodeComponent` (in that order) or a `RelayComponent` linked to one of those component types, then this property will be `nil`.
    @inlinable
    public var entityNode: SKNode? {
        #if LOGECSVERBOSE
        debugLog("self: \(self)")
        #endif
        return self.entity?.node
    }
    
    /// Convenient shorthand for accessing the OctopusKit scene containing the SpriteKit node that is associated with the `NodeComponent` of this component's entity.
    ///
    /// If the entity does not have an `NodeComponent` or `GKSKNodeComponent` (in that order) or a `RelayComponent` linked to one of those component types, then this property will be `nil`.
    @inlinable
    public var entityScene: OKScene? {
        self.entityNode?.scene as? OKScene
    }
    
    /// Returns the name for the entity associated with this component, if it is an `OKEntity`. A convenience for quickly writing log entries.
    @inlinable
    public var entityName: String? {
        (self.entity as? OKEntity)?.name
    }
    
    /// Returns the component of type `componentClass`, or a `RelayComponent` linked to a component of that type, if it's present in the entity that is associated with this component.
    ///
    /// Returns `nil` if the requested `componentClass` is this component's class, as that would not be a "co" component, and entities may have only one component of each class.
    ///
    /// - WARNING: This method will **not** find *subclasses* of `componentClass`.
    @inlinable
    public func coComponent <ComponentType> (
        ofType componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool = false) -> ComponentType?
        where ComponentType:   GKComponent
    {
        #if LOGECSVERBOSE
        debugLog("ComponentType: \(ComponentType.self), componentClass: \(componentClass), ignoreRelayComponents: \(ignoreRelayComponents), self: \(self)")
        #endif
        
        if  componentClass == type(of: self) {
            
            /// Return `nil` if this component is looking for its own class. See reason in method documentation.
            
            #if LOGECSVERBOSE
            debugLog("componentClass == type(of: self) — Returning `nil`")
            #endif
            
            return nil
        
        } else if ignoreRelayComponents {
            
            let match = self.entity?.component(ofType: componentClass)
            
            #if LOGECSVERBOSE
            debugLog("self.entity?.component(ofType: componentClass) == \(match)")
            #endif
            
            return match
            
        } else {
            
            let match = self.entity?.componentOrRelay(ofType: componentClass)
            
            #if LOGECSVERBOSE
            debugLog("self.entity?.componentOrRelay(ofType: componentClass) == \(match)")
            #endif
            
            return match
        }
    }
    
    /// A shortcut for `coComponent(ofType:)` without a parameter name to reduce text clutter.
    @inlinable
    public func coComponent <ComponentType> (
        _ componentClass:       ComponentType.Type,
        ignoreRelayComponents:  Bool = false) -> ComponentType?
        where ComponentType:    GKComponent
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
        // This is a workaround for the bug where `OKComponent.requiredComponents` could not be correctly matched with `GKEntity.component(ofType:)` at runtime when the entity has a `RelayComponent` for the dependency.
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
