//
//  OctopusComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/11.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Should there be a way to mark components which have an `update` method, and automatically add them to a scene's component systems?

import GameplayKit

/// A protocol for components that must be updated every frame to perform their function.
///
/// The component must be updated every frame during the scene's `update(_:)` method, by directly calling the component's `update(deltaTime:)` method, updating the component's entity, or updating the component system which this component is registered with.
public protocol OctopusUpdatableComponent {
    // TODO: Better name.
    
    // ℹ️ Swift does not have a means to enforce implementation of methods in subclasses, so this protocol is mostly fluff and simply serves as documentation for now. 2018-05-05
    
    func update(deltaTime seconds: TimeInterval)
}

/// An object which adds a discrete visual or behavorial effect to an entity or scene. The core concept of the OctopusKit.
///
/// Components may interact with other components and modify entities, and control game states.
///
/// Components may also be purely abstract collections of data, without any logic.
open class OctopusComponent: GKComponent {
    
    /// A list of co-component types that this component depends on.
    ///
    /// - NOTE: The component should not raise an application-halting error or exception if a dependency is missing, because components may be added to or removed from an entity during runtime to dynamically modify the entity's behavior. In the absence of a dependency, a component should fail gracefully and simply skip a part or all of its functionality, optionally logging a warning.
    open var requiredComponents: [GKComponent.Type]? {
        // CHECK: Rename to `dependencies`?
        return nil
    }
    
    /// Returns the entity associated with this component, if it is an `OctopusEntity`.
    public var octopusEntity: OctopusEntity? {
        return self.entity as? OctopusEntity
    }
    
    /// Returns the delegate for the entity associated with this component, if any.
    public var entityDelegate: OctopusEntityDelegate? {
        return (self.entity as? OctopusEntity)?.delegate
    }
    
    /// Ensures that any necessary cleanup (such as removing child nodes) is performed in case of a forced deinit, which may be caused by GameplayKit if multiple components of the same type are added to the same entity, as that replaces previous components of the same class without letting them call `willRemoveFromEntity()`.
    public internal(set) var shouldRemoveFromEntityOnDeinit = false
    
    public internal(set) var shouldWarnIfDeinitWithoutRemoving = false
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// - Important: If a subclass overrides this method, then `super.didAddToEntity()` *MUST* be called to ensure proper functionality, e.g. to check for dependencies on other components and to set `shouldRemoveFromEntityOnDeinit = true`.
    open override func didAddToEntity() {
        OctopusKit.logForComponents.add("\(String(optional: entity)) ← \(self)")
        super.didAddToEntity()
        guard self.entity != nil else { fatalError("entity not set") }
        
        // Check the list of dependencies on other components.
        
        checkEntityForRequiredComponents()
        
        // ⚠️ NOTE: Set flags BEFORE passing to `didAddToEntity(withNode:)`, in case the subclass decides to remove itself from the entity and clears these flags.
        
        shouldRemoveFromEntityOnDeinit = true
        shouldWarnIfDeinitWithoutRemoving = true
        
        // A convenient delegation method for subclasses to easily access the entity's SpriteKit node, if any.
        if let node = self.entityNode {
            didAddToEntity(withNode: node)
        }
    }
    
    /// Logs a warning if the entity is missing any of the components in `requiredComponents`.
    ///
    /// ⚠️ BUG: 201804029A: See method comments.
    fileprivate func checkEntityForRequiredComponents() {
        // ⚠️
        // BUG: 201804029A: APPLEBUG: Sending an array like `[GKComponent.Type]` to `entity.componentOrRelay(ofType:)` does not use the actual metatypes, and so it can cause false warnings about missing components.
        // NOTE: The bug does not affect directly sending "concrete" subtypes of `GKComponent` to `entity.componentOrRelay(ofType:)`.
        // TODO: Find a way to get true runtime metatypes from an array of parent metatype.
        
        // ℹ️ See description of `requiredComponents` for explanation about not halting execution on missing dependencies.
        
        guard let entity = self.entity else { return }
        
        if let requiredComponents = self.requiredComponents {

            for requiredComponent in requiredComponents {
                
                let result = entity.componentOrRelay(ofType: requiredComponent)
                
                if  result == nil
                    || type(of: result!) != requiredComponent // Is this dynamic checking necessary instead of just testing for `nil`?
                {
                    OctopusKit.logForDebug.add("BUG in method: IGNORE warning: \(entity) is missing a \(requiredComponent) (or a RelayComponent linked to it) which is required by \(self)")
                    // OctopusKit.logForWarnings.add("\(entity) is missing a \(requiredComponent) (or a RelayComponent linked to it) which is required by \(self)")
                    // OctopusKit.logForTips.add("Check the order in which components are added. Ignore warning if entity has any substitutable components.")
                }
                
            }
        }
    }
    
    /// Abstract; To be implemented by subclass. Provides convenient access to the `SpriteKitComponent` node that the entity is associated with.
    open func didAddToEntity(withNode node: SKNode) {}
    
    /// Abstract; To be implemented by subclass. Provides convenient access to the `SpriteKitComponent` node that the entity is associated with.
    open func willRemoveFromEntity(withNode node: SKNode) {}
    
    /// Tells the entity to remove components of this type, and clears the `shouldRemoveFromEntityOnDeinit` and `shouldWarnIfDeinitWithoutRemoving` flags.
    open func removeFromEntity() {
        shouldRemoveFromEntityOnDeinit = false
        shouldWarnIfDeinitWithoutRemoving = false
        self.entity?.removeComponent(ofType: type(of: self))
    }
    
    /// - Important: If a subclass overrides this method, then `super.willRemoveFromEntity()` MUST be called to ensure proper functionality, including clearing `shouldRemoveFromEntityOnDeinit`.
    open override func willRemoveFromEntity() {
        OctopusKit.logForComponents.add("\(String(optional: entity)) ~ \(self)")
        
        super.willRemoveFromEntity()
        guard self.entity != nil else { return }
        
        if let spriteKitComponentNode = entityNode {
            willRemoveFromEntity(withNode: spriteKitComponentNode)
        }
        
        shouldRemoveFromEntityOnDeinit = false
        shouldWarnIfDeinitWithoutRemoving = false
        
        // NOTE: Since removeComponent(ofType:) CANNOT be overriden in a GKEntity subclass (because "Declarations from extensions cannot be overridden yet" and "Overriding non-open instance method outside of its defining module") as of 2017-11-14, use this method to notify the OctopusEntityDelegate about component removal.
        if let entity = self.entity as? OctopusEntity {
            entity.delegate?.entity(entity, willRemoveComponent: self)
        }
    }
    
    deinit {
        OctopusKit.logForDeinits.add("\(self)")
        
        if shouldRemoveFromEntityOnDeinit {
            // ⚠️ NOTE: Do NOT call `self.entity?.removeComponent(ofType: type(of: self))` here, as this may remove the NEW component, if one of the same class was added, causing this deinit's object to be replaced.
            willRemoveFromEntity() // CHECKED: Successfully calls `willRemoveFromEntity()` etc. on the subclass :)
        }
        if shouldWarnIfDeinitWithoutRemoving {
            OctopusKit.logForWarnings.add("\(self) deinit before willRemoveFromEntity()")
        }
    }
}

