//
//  GKComponentWrapper.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/06/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Experimental prototype for protocol-based components.
open class GKComponentWrapper: Component, UpdatablePerFrame {
    
    // TODO: Implement the ability to call methods on components via a component system, in Swift? Maybe through `@dynamicCallable`?
    // "The component system will then forward any component-specific messages it receives to all registered instances of its component class." — https://developer.apple.com/documentation/gameplaykit/gkcomponentsystem
    // TODO: Tests
    
    public let gkComponent: GKComponent
    
    /// A list of co-component types that this component depends on.
    ///
    /// - NOTE: The component should not raise an application-halting error or exception if a dependency is missing, because components may be added to or removed from an entity during runtime to dynamically modify the entity's behavior. In the absence of a dependency, a component should fail gracefully and simply skip a part or all of its functionality, optionally logging a warning.
    @inlinable
    open var requiredComponents: [Component.Type]? {
        // CHECK: Rename to `dependencies`?
        nil
    }
    
    /// Ensures that any necessary cleanup (such as removing child nodes) is performed in case of a forced deinit, which may be caused by GameplayKit if multiple components of the same type are added to the same entity, as that replaces previous components of the same class **without** letting them call `willRemoveFromEntity()`.
    public internal(set) var shouldRemoveFromEntityOnDeinit    = false
    
    public internal(set) var shouldWarnIfDeinitWithoutRemoving = false
    
    /// If `true`, this component will not check for the components it depends on in the entity it is added to, and `checkEntityForRequiredComponents()` will be ignored.
    ///
    /// This flag may be useful for suppressing warnings when creating an entity with `RelayComponent(sceneComponentType:)`, because those relays will not be able to find their target components before the entity is added to a scene.
    open var disableDependencyChecks: Bool = false
    
    public init() {
        self.gkComponent = GKComponent()
    }
    
    // MARK: - GKComponent
    
    public var entity: Entity? {
        self.gkComponent.entity as? Entity
    }
    
    open func update(deltaTime: TimeInterval) {}
    
    // MARK: - Adding To Entity
    
    /// - IMPORTANT: If a subclass overrides this method, then `super.didAddToEntity()` *MUST* be called to ensure proper functionality, e.g. to check for dependencies on other components and to set `shouldRemoveFromEntityOnDeinit = true`.
    open func didAddToEntity() {
        
        OctopusKit.logForComponents("\(entity) ← \(self)")
        
        // super.didAddToEntity()
        
        guard self.entity != nil else { fatalError("didAddToEntity() called but entity is nil") }

        // Check the list of dependencies on other components.

        checkEntityForRequiredComponents()

        // ⚠️ NOTE: Set flags BEFORE passing to `didAddToEntity(withNode:)`, in case the subclass decides to remove itself from the entity and clears these flags.

        shouldRemoveFromEntityOnDeinit    = true
        shouldWarnIfDeinitWithoutRemoving = true

        // A convenient delegation method for subclasses to easily access the entity's SpriteKit node, if any.
        if  let node = self.entity?.node {
            didAddToEntity(withNode: node)
        }
    }
    
    /// Abstract; To be implemented by subclass. Provides convenient access to the `NodeComponent` node that the entity is associated with.
    ///
    /// - NOTE: ❕ This method may not be called if the entity does not have a node at the time of adding this component. Therefore, this method should only be used for adding effects related to the node. Override `didAddToEntity()` for any code that *must* be guaranteed upon adding this component to an entity.
    open func didAddToEntity(withNode node: SKNode) {}
    
    // MARK: - Validation
    
    /// Logs a warning if the entity is missing any of the components in `requiredComponents`.
    ///
    /// - Returns: `true` if there are no missing dependencies or no `requiredComponents`, or if the `disableDependencyChecks` flags is set.
    @inlinable @discardableResult
    public final func checkEntityForRequiredComponents() -> Bool {

        guard !disableDependencyChecks else { return true }
        
        // ℹ️ DESIGN: See description of `requiredComponents` for explanation about not halting execution on missing dependencies.
        // FIXED: BUG: 201804029A: See comments for `Entity.componentOrRelay(ofType:)`
        
        #if LOGECSVERBOSE
        debugLog("self: \(self)")
        #endif
        
        guard let requiredComponents = self.requiredComponents else { return true }
        
        guard let entity = self.entity else {
            // If we don't have an entity,
            // and have requiredComponents: return `false`,
            // but no requiredComponents: return `true`, because code which checks for the return value probably uses it to say if the component has all dependencies or not.
            return requiredComponents.isEmpty
        }
        
        var hasMissingDependencies: Bool = false
        
        requiredComponents.forEach { requiredComponentType in
            
            #if LOGECSVERBOSE
            debugLog("requiredComponentType: \(requiredComponentType)")
            #endif
            
            let match: Component? = nil // self.coComponent(requiredComponentType.self)
            
            /// Using `type(of: result)` instead of `Component.componentType` may report `Component` instead of the concrete subclass. See comments for `Entity.componentOrRelay(ofType:)`
            
            #if LOGECSVERBOSE
            debugLog("match: \(match)")
            #endif
            
            if  match?.componentType != requiredComponentType {
                
                OctopusKit.logForWarnings("\(entity) is missing a \(requiredComponentType) (or a RelayComponent linked to it) which is required by \(self)")
                OctopusKit.logForTips("Check the order in which components are added. Ignore warning if entity has a substitutable component, or a RelayComponent(sceneComponentType:) but not yet added to a scene.")
                
                hasMissingDependencies = true
                
                // Do not break the iteration here or return early, so we can issue warnings about any other missing dependencies.
            }
        }
        
        return !hasMissingDependencies
    }

    // MARK: - Removal
    
    /// Tells the entity to remove components of this type, and clears the `shouldRemoveFromEntityOnDeinit` and `shouldWarnIfDeinitWithoutRemoving` flags.
    open func removeFromEntity() {
        shouldRemoveFromEntityOnDeinit    = false
        shouldWarnIfDeinitWithoutRemoving = false
        self.entity?.removeComponent(ofType: type(of: self))
    }
    
    /// - IMPORTANT: If a subclass overrides this method, then `super.willRemoveFromEntity()` MUST be called to ensure proper functionality, including clearing `shouldRemoveFromEntityOnDeinit`.
    open func willRemoveFromEntity() {
        
        OctopusKit.logForComponents("\(entity) ~ \(self)")
        
        // super.willRemoveFromEntity()
        
        guard self.entity != nil else { return }

        if  let spriteKitComponentNode = self.entity?.node {
            willRemoveFromEntity(withNode: spriteKitComponentNode)
        }

        shouldRemoveFromEntityOnDeinit    = false
        shouldWarnIfDeinitWithoutRemoving = false

        /// NOTE: Since `removeComponent(ofType:)` CANNOT be overridden in a GKEntity subclass (because "Declarations from extensions cannot be overridden yet" and "Overriding non-open instance method outside of its defining module") as of 2017-11-14, use this method to notify the OKEntityDelegate about component removal. CHECK: Current relevancy of this comment.
        if  let entity = self.entity as? OKEntity {
            // TODO: entity.delegate?.entity(entity, willRemoveComponent: self)
        }
    }
    
    /// Abstract; To be implemented by subclass. Provides convenient access to the `NodeComponent` node that the entity is associated with.
    ///
    /// - NOTE: ❕ This method may not be called if the entity does not have a node at the time of removal. Therefore, this method should only be used for removing effects related to the node. Override `willRemoveFromEntity()` for any cleanup that *must* be guaranteed on removal.
    open func willRemoveFromEntity(withNode node: SKNode) {}
    
    deinit {
        OctopusKit.logForDeinits("\(self)")

        if  shouldRemoveFromEntityOnDeinit {
            /// ⚠️ NOTE: Do NOT call `self.entity?.removeComponent(ofType: type(of: self))` here, as this may remove the NEW component, if one of the same class was added, causing this deinit's object to be replaced.
            willRemoveFromEntity() // CHECKED: Successfully calls `willRemoveFromEntity()` etc. on the subclass :)
        }

        if  shouldWarnIfDeinitWithoutRemoving {
            OctopusKit.logForWarnings("\(self) deinit before willRemoveFromEntity()")
        }
    }
    
    // MARK: - Queries
    
    /// Returns the component of type `componentClass`, or a `RelayComponent` linked to a component of that type, if it's present in the entity that is associated with this component.
    ///
    /// Returns `nil` if the requested `componentClass` is this component's class, as that would not be a "co" component, and entities may have only one component of each class.
    ///
    /// - WARNING: This method will **not** find *subclasses* of `componentClass`.
    @inlinable
    public func coComponent <ComponentType> (
        ofType componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool = false) -> ComponentType?
        where ComponentType:   Component
    {

        #if LOGECSDEBUG
        debugLog("ComponentType: \(ComponentType.self), componentClass: \(componentClass), ignoreRelayComponents: \(ignoreRelayComponents), self: \(self)")
        #endif
        
        if  componentClass == type(of: self) {
            
            /// Return `nil` if this component is looking for its own class. See reason in method documentation.
            
            #if LOGECSDEBUG
            debugLog("componentClass == type(of: self) — Returning `nil`")
            #endif
            
            return nil
            
        } else if ignoreRelayComponents {
            
            let match = self.entity?.component(ofType: componentClass)
            
            #if LOGECSDEBUG
            debugLog("self.entity?.component(ofType: componentClass) == \(match)")
            #endif
            
            return match
            
        } else {
            
            let match = self.entity?.componentOrRelay(ofType: componentClass)
            
            #if LOGECSDEBUG
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
        where ComponentType:    Component
    {
        return nil //self.coComponent(ofType: componentClass, ignoreRelayComponents: ignoreRelayComponents)
    }
    
    /// Returns `type(of: self)`
    ///
    /// This property is used to accurately determine the type of generic components at runtime.
    ///
    /// A `RelayComponent` overrides this property to return the type of its `target`. This lets `Entity.componentOrRelay(ofType:)` return a `RelayComponent.target` that matches the requested component class.
    open var componentType: Component.Type {
        /// This is a workaround for the bug where `OKComponent.requiredComponents` could not be correctly matched with `Entity.component(ofType:)` at runtime when the entity has a `RelayComponent` for the dependency.
        /// See comments for `Entity.componentOrRelay(ofType:)`
        // THANKS: https://forums.swift.org/u/TellowKrinkle
        // https://forums.swift.org/t/type-information-loss-when-comparing-generic-variables-with-an-array-of-metatypes/30650
        
        #if LOGECSDEBUG
        debugLog("self: \(self), \(type(of: self))")
        #endif
        
        return type(of: self)
    }
    
    /*
    /// Used by `RelayComponent` to substitute itself with the target component.
    @objc open var baseComponent: Component? {
        // CHECK: Include? Will it improve correctness and performance in Entity.componentOrRelay(ofType:) or is it unnecessary?
        // THANKS: https://forums.swift.org/u/TellowKrinkle
        // https://forums.swift.org/t/type-information-loss-when-comparing-generic-variables-with-an-array-of-metatypes/30650
        return self
    }
    */

    // MARK: - Modifiers

    /// Sets the `disableDependencyChecks` and returns self.
    @inlinable @discardableResult
    public func disableDependencyChecks(_ newValue: Bool) -> Self {
        self.disableDependencyChecks = newValue
        return self
    }
    
}
