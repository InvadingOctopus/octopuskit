//
//  Component.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import GameplayKit

public protocol Component: class, UpdatablePerFrame {
    
    // ℹ️ Not currently in use; This is mostly preparation for future independence from GameplayKit, if needed.
    
    // MARK: Properties
    
    var entity:             Entity?             { get }
    var requiredComponents: [Component.Type]?   { get }
    
    var componentType:      Component.Type      { get }
    
    var entityName:         String?             { get }
    var entityNode:         SKNode?             { get }
    var entityScene:        OKScene?            { get }
    var entityPhysicsBody:  SKPhysicsBody?      { get }
    var entityState:        OKEntityState?      { get }
    var entityDelegate:     OKEntityDelegate?   { get }
    
    var shouldRemoveFromEntityOnDeinit:    Bool { get set }
    var shouldWarnIfDeinitWithoutRemoving: Bool { get set }
    var disableDependencyChecks:           Bool { get set }
    
    // MARK: Life Cycle
    
    init()
    
    func didAddToEntity()
    func didAddToEntity(withNode node: SKNode)
    
    func willRemoveFromEntity()
    func willRemoveFromEntity(withNode node: SKNode)
    
    // MARK: Queries

    func coComponent <ComponentType> (
        ofType componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool)
        -> ComponentType? where ComponentType: Component
    
    func coComponent <ComponentType> (
        _ componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool)
        -> ComponentType? where ComponentType: Component
    
    func checkEntityForRequiredComponents()
    func disableDependencyChecks(_ newValue: Bool)
}

// MARK: - Default Implementation

public extension Component {
    
    // MARK: - Properties
    
    var requiredComponents: [Component.Type]? { nil }
    
    /// Returns the name for the entity associated with this component, if it is an `OKEntity`. A convenience for quickly writing log entries.
    @inlinable
    var entityName: String? {
        self.entity?.name
    }
    
    // TODO: Implement the ability to call methods on components via a component system, in Swift? Maybe through `@dynamicCallable`?
    // "The component system will then forward any component-specific messages it receives to all registered instances of its component class." — https://developer.apple.com/documentation/gameplaykit/gkcomponentsystem
    // TODO: Tests
    
    /// Convenient shorthand for accessing the SpriteKit node that is associated the `NodeComponent` of this component's entity.
    ///
    /// If the entity does not have an `NodeComponent` or `GKSKNodeComponent` (in that order) or a `RelayComponent` linked to one of those component types, then this property will be `nil`.
    @inlinable
    var entityNode: SKNode? {
        #if LOGECSVERBOSE
        debugLog("self: \(self)")
        #endif
        return self.entity?.node
    }
    
    /// Convenient shorthand for accessing the OctopusKit scene containing the SpriteKit node that is associated with the `NodeComponent` of this component's entity.
    ///
    /// If the entity does not have an `NodeComponent` or `GKSKNodeComponent` (in that order) or a `RelayComponent` linked to one of those component types, then this property will be `nil`.
    @inlinable
    var entityScene: OKScene? {
        self.entityNode?.scene as? OKScene
    }
    
    /// Convenient shorthand for accessing the `SKPhysicsBody` associated the scene.
    ///
    /// See the `GKEntity.physicsBody` property to see how the return value is determined.
    @inlinable
    var entityPhysicsBody: SKPhysicsBody? {
        self.entity?.physicsBody
    }
    
    /// Returns the delegate for the entity associated with this component, if any.
    @inlinable
    var entityDelegate: OKEntityDelegate? {
        (self.entity as? OKEntity)?.delegate
    }
    
    // MARK: - Life Cycle
    
    /// - IMPORTANT: If a subclass overrides this method, then `super.didAddToEntity()` *MUST* be called to ensure proper functionality, e.g. to check for dependencies on other components and to set `shouldRemoveFromEntityOnDeinit = true`.
    func didAddToEntity() {
        OctopusKit.logForComponents("\(entity) ← \(self)")
        // super.didAddToEntity()
        guard self.entity != nil else { fatalError("entity not set") }
        
        // Check the list of dependencies on other components.
        
        checkEntityForRequiredComponents()
        
        // ⚠️ NOTE: Set flags BEFORE passing to `didAddToEntity(withNode:)`, in case the subclass decides to remove itself from the entity and clears these flags.
        
        shouldRemoveFromEntityOnDeinit = true
        shouldWarnIfDeinitWithoutRemoving = true
        
        // A convenient delegation method for subclasses to easily access the entity's SpriteKit node, if any.
        if  let node = self.entityNode {
            didAddToEntity(withNode: node)
        }
    }
    
    /// Logs a warning if the entity is missing any of the components in `requiredComponents`.
    ///
    /// - RETURNS: `true` if there are no missing dependencies or no `requiredComponents`
    @discardableResult
    func checkEntityForRequiredComponents() -> Bool {
        
        // ℹ️ DESIGN: See description of `requiredComponents` for explanation about not halting execution on missing dependencies.
        // FIXED: BUG: 201804029A: See comments for `GKEntity.componentOrRelay(ofType:)`
        
        #if LOGECSVERBOSE
        debugLog("self: \(self)")
        #endif
        
        guard let entity = self.entity else {
            // If we don't have an entity,
            // and have requiredComponents: return `false`,
            // but no requiredComponents: return `true`, because code which checks for the return value probably uses it to say if the component has all dependencies or not.
            return self.requiredComponents?.isEmpty ?? true
        }
        
        var hasMissingDependencies: Bool = false
        
        self.requiredComponents?.forEach { requiredComponentType in
            
            #if LOGECSVERBOSE
            debugLog("requiredComponentType: \(requiredComponentType)")
            #endif
            
            let match: Component? = nil // TODO: self.coComponent(requiredComponentType)
            
            // Using `type(of: result)` instead of `GKComponent.componentType` may report `GKComponent` instead of the concrete subclass. See comments for `GKEntity.componentOrRelay(ofType:)`
            
            #if LOGECSVERBOSE
            debugLog("match: \(match)")
            #endif
            
            if  match?.componentType != requiredComponentType {
                
                OctopusKit.logForWarnings("\(entity) is missing a \(requiredComponentType) (or a RelayComponent linked to it) which is required by \(self)")
                OctopusKit.logForTips ("Check the order in which components are added. Ignore warning if entity has any substitutable components.")
                
                hasMissingDependencies = true
                
                // Do not break the iteration here or return early, so we can issue warnings about any other missing dependencies.
            }
        }
        
        return !hasMissingDependencies
        
    }
    
    /// Abstract; To be implemented by subclass. Provides convenient access to the `NodeComponent` node that the entity is associated with.
    func didAddToEntity(withNode node: SKNode) {}
    
    /// Abstract; To be implemented by subclass. Provides convenient access to the `NodeComponent` node that the entity is associated with.
    func willRemoveFromEntity(withNode node: SKNode) {}
    
    /// Tells the entity to remove components of this type, and clears the `shouldRemoveFromEntityOnDeinit` and `shouldWarnIfDeinitWithoutRemoving` flags.
    func removeFromEntity() {
        shouldRemoveFromEntityOnDeinit = false
        shouldWarnIfDeinitWithoutRemoving = false
        self.entity?.removeComponent(ofType: type(of: self))
    }
    
    /// - IMPORTANT: If a subclass overrides this method, then `super.willRemoveFromEntity()` MUST be called to ensure proper functionality, including clearing `shouldRemoveFromEntityOnDeinit`.
    func willRemoveFromEntity() {
        OctopusKit.logForComponents("\(entity) ~ \(self)")
        
        // super.willRemoveFromEntity()
        guard self.entity != nil else { return }
        
        if  let spriteKitComponentNode = entityNode {
            willRemoveFromEntity(withNode: spriteKitComponentNode)
        }
        
        shouldRemoveFromEntityOnDeinit = false
        shouldWarnIfDeinitWithoutRemoving = false
        
        // NOTE: Since removeComponent(ofType:) CANNOT be overridden in a GKEntity subclass (because "Declarations from extensions cannot be overridden yet" and "Overriding non-open instance method outside of its defining module") as of 2017-11-14, use this method to notify the OKEntityDelegate about component removal.
        // if  let entity = self.entity as? OKEntity {
            // TODO: entity.delegate?.entity(entity, willRemoveComponent: self)
        // }
    }
    
    /* Classes only
    deinit {
        OctopusKit.logForDeinits("\(self)")
        
        if  shouldRemoveFromEntityOnDeinit {
            // ⚠️ NOTE: Do NOT call `self.entity?.removeComponent(ofType: type(of: self))` here, as this may remove the NEW component, if one of the same class was added, causing this deinit's object to be replaced.
            willRemoveFromEntity() // CHECKED: Successfully calls `willRemoveFromEntity()` etc. on the subclass :)
        }
        
        if  shouldWarnIfDeinitWithoutRemoving {
            OctopusKit.logForWarnings("\(self) deinit before willRemoveFromEntity()")
        }
    }
    */
    
    // MARK: - Queries
    
    /// Returns the component of type `componentClass`, or a `RelayComponent` linked to a component of that type, if it's present in the entity that is associated with this component.
    ///
    /// Returns `nil` if the requested `componentClass` is this component's class, as that would not be a "co" component, and entities can have only one component of each class.
    ///
    /// - WARNING: This method will **not** find *subclasses* of `componentClass`.
    @inlinable
    func coComponent <ComponentType> (
        ofType componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool = false)
        -> ComponentType? where ComponentType: Component
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
    func coComponent <ComponentType> (
        _ componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool = false)
        -> ComponentType? where ComponentType: Component
    {
        self.coComponent(ofType: componentClass, ignoreRelayComponents: ignoreRelayComponents)
    }
    
    /// Returns `type(of: self)`
    ///
    /// This property is used to accurately determine the type of generic components at runtime.
    ///
    /// A `RelayComponent` overrides this property to return the type of its `target`. This lets `GKEntity.componentOrRelay(ofType:)` return a `RelayComponent.target` that matches the requested component class.
    // @objc
    // open
    @inlinable
    var componentType: Component.Type {
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
    
    /// Sets the `disableDependencyChecks` and returns self.
    @inlinable @discardableResult
    func disableDependencyChecks(_ newValue: Bool) -> Self {
        self.disableDependencyChecks = newValue
        return self
    }
    
}
