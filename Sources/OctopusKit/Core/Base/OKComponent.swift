//
//  OKComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/11.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Should there be a way to mark components which have an `update` method, and automatically add them to a scene's component systems?

import OctopusCore
import GameplayKit
import OSLog

public typealias OctopusComponent = OKComponent

/// An object which adds a discrete visual or behavioral effect to an entity or scene. The core concept of the OctopusKit.
///
/// Components may interact with other components and modify entities, and control game states.
///
/// Components may also be purely abstract collections of data, without any logic.
open class OKComponent: GKComponent {
    
    // ℹ️ Also see GKComponent+OctopusKit extensions.
    
    /// A list of co-component types that this component depends on.
    ///
    /// - NOTE: The component should not raise an application-halting error or exception if a dependency is missing, because components may be added to or removed from an entity during runtime to dynamically modify the entity's behavior. In the absence of a dependency, a component should fail gracefully and simply skip a part or all of its functionality, optionally logging a warning.
    @inlinable
    open var requiredComponents: [GKComponent.Type]? {
        // CHECK: Rename to `dependencies`?
        nil
    }
    
    /// Returns the entity associated with this component, if it is an `OKEntity`.
    @inlinable
    public var octopusEntity: OKEntity? {
        self.entity as? OKEntity
    }
    
    /// Returns the delegate for the entity associated with this component, if any.
    @inlinable
    public var entityDelegate: OKEntityDelegate? {
        (self.entity as? OKEntity)?.delegate
    }
    
    /// Ensures that any necessary cleanup (such as removing child nodes) is performed in case of a forced deinit, which may be caused by GameplayKit if multiple components of the same type are added to the same entity, as that replaces previous components of the same class **without** letting them call `willRemoveFromEntity()`.
    public internal(set) var shouldRemoveFromEntityOnDeinit    = false
    
    public internal(set) var shouldWarnIfDeinitWithoutRemoving = false
    
    /// If `true`, this component will not check for the components it depends on in the entity it is added to, and `checkEntityForRequiredComponents()` will be ignored.
    ///
    /// This flag may be useful for suppressing warnings when creating an entity with `RelayComponent(sceneComponentType:)`, because those relays will not be able to find their target components before the entity is added to a scene.
    open var disableDependencyChecks: Bool = false
    
    // These initializers are for subclasses to implement Xcode Scene Builder support.
    public override init() { super.init() }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    // MARK: - Adding To Entity
    
    /// - IMPORTANT: If a subclass overrides this method, then `super.didAddToEntity()` *MUST* be called to ensure proper functionality, e.g. to check for dependencies on other components and to set `shouldRemoveFromEntityOnDeinit = true`.
    open override func didAddToEntity() {
        OKLog.logForComponents.debug("\(📜("\(entity) ← \(self)"))")
        super.didAddToEntity()
        guard self.entity != nil else { fatalError("entity not set") }
        
        // Check the list of dependencies on other components.
        
        checkEntityForRequiredComponents()
        
        // ⚠️ NOTE: Set flags BEFORE passing to `didAddToEntity(withNode:)`, in case the subclass decides to remove itself from the entity and clears these flags.
        
        shouldRemoveFromEntityOnDeinit    = true
        shouldWarnIfDeinitWithoutRemoving = true
        
        // A convenient delegation method for subclasses to easily access the entity's SpriteKit node, if any.
        if  let node = self.entityNode {
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
            
            let match = self.coComponent(requiredComponentType)
            
            // Using `type(of: result)` instead of `GKComponent.componentType` may report `GKComponent` instead of the concrete subclass. See comments for `GKEntity.componentOrRelay(ofType:)`
            
            #if LOGECSVERBOSE
            debugLog("match: \(match)")
            #endif
            
            if  match?.componentType != requiredComponentType {
                
                OKLog.logForWarnings.debug("\(📜("\(entity) is missing a \(requiredComponentType) (or a RelayComponent linked to it) which is required by \(self)"))")
                OKLog.logForTips.debug("\(📜("Check the order in which components are added. Ignore warning if entity has a substitutable component, or a RelayComponent(sceneComponentType:) but not yet added to a scene."))")
                
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
    open override func willRemoveFromEntity() {
        OKLog.logForComponents.debug("\(📜("\(entity) ~ \(self)"))")
        
        super.willRemoveFromEntity()
        guard self.entity != nil else { return }
        
        if  let spriteKitComponentNode = entityNode {
            willRemoveFromEntity(withNode: spriteKitComponentNode)
        }
        
        shouldRemoveFromEntityOnDeinit    = false
        shouldWarnIfDeinitWithoutRemoving = false
        
        // NOTE: Since removeComponent(ofType:) CANNOT be overridden in a GKEntity subclass (because "Declarations from extensions cannot be overridden yet" and "Overriding non-open instance method outside of its defining module") as of 2017-11-14, use this method to notify the OKEntityDelegate about component removal.
        if  let entity = self.entity as? OKEntity {
            entity.delegate?.entity(entity, willRemoveComponent: self)
        }
    }
    
    /// Abstract; To be implemented by subclass. Provides convenient access to the `NodeComponent` node that the entity is associated with.
    ///
    /// - NOTE: ❕ This method may not be called if the entity does not have a node at the time of removal. Therefore, this method should only be used for removing effects related to the node. Override `willRemoveFromEntity()` for any cleanup that *must* be guaranteed on removal.
    open func willRemoveFromEntity(withNode node: SKNode) {}
    
    deinit {
        OKLog.logForDeinits.debug("\(📜("\(self)"))")
        
        if  shouldRemoveFromEntityOnDeinit {
            // ⚠️ NOTE: Do NOT call `self.entity?.removeComponent(ofType: type(of: self))` here, as this may remove the NEW component, if one of the same class was added, causing this deinit's object to be replaced.
            willRemoveFromEntity() // CHECKED: Successfully calls `willRemoveFromEntity()` etc. on the subclass :)
        }
        
        if  shouldWarnIfDeinitWithoutRemoving {
            OKLog.logForWarnings.debug("\(📜("\(self) deinit before willRemoveFromEntity()"))")
        }
    }
}

// MARK: - Modifiers

public extension OKComponent {
    
    /// Sets the `disableDependencyChecks` and returns self.
    @inlinable @discardableResult
    func disableDependencyChecks(_ newValue: Bool) -> Self {
        self.disableDependencyChecks = newValue
        return self
    }
}
