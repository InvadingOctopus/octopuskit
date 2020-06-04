//
//  OKEntity.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/11.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

public typealias OctopusEntityDelegate = OKEntityDelegate
public typealias OctopusEntity = OKEntity

/// A protocol for types that manage entities, such as `OKScene`.
public protocol OKEntityDelegate: class {
    func entity(_ entity: GKEntity, didAddComponent component:     GKComponent)
    func entity(_ entity: GKEntity, willRemoveComponent component: GKComponent)
    
    @discardableResult
    func entity(_ entity: GKEntity, didSpawn spawnedEntity: GKEntity) -> Bool
    
    func entityDidRequestRemoval(_ entity: GKEntity)
}

/// A collection of components.
///
/// An entity will usually have a visual representation on-screen via a `NodeComponent` node.
///
/// An `OKScene` is also represented by an entity via a `SceneComponent`.
open class OKEntity: GKEntity {
    
    // ℹ️ Also see GKEntity+OctopusKit extensions.
    
    /// Identifies the entity. Can be non-unique and shared with other entities.
    ///
    /// An `OKScene` may search for entities by their name via `entities(withName:)`.
    public var name: String?
    
    public weak var delegate: OKEntityDelegate? // CHECK: Should this be `weak`?
    
    open override var description: String {
        // CHECK: Improve?
        "\(super.description) \"\(self.name ?? "")\""
    }
    
    /// Indicates whether a scene should check whether it has systems for each of this entity's components that must be updated every frame or turn. Setting `true` may improve performance for entities that are added frequently. Setting `false` may help reduce bugs that result from missing systems.
    open var suppressSystemsAvailabilityCheck: Bool = false
    
    open override var debugDescription: String {
        "\(self.description)\(components.count > 0 ? " \(components.count) components = \(components)" : "")"
    }
    
    // MARK: - Initializers
    
    // ℹ️ NOTE: These inits are not marked with the `convenience` modifier because we want to set `self.name = name` BEFORE calling `GKEntity` inits, in order to ensure that the log entries for `addComponent` will include the `OKEntity`'s name if it's supplied.
    // However, if these were convenience initializers, we would get the error: "'self' used in property access 'name' before 'self.init' call"
    
    /// Creates an entity with the specified name and adds the components in the specified order.
    public init(name: String? = nil,
                components: [GKComponent] = [])
    {
        self.name = name
        super.init()
        
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// Creates an entity, adding an `NodeComponent` to associate it with the specified node and adds any other components if specified.
    ///
    /// Sets the entity's name to the node's name, if any.
    public init(node: SKNode,
                components: [GKComponent] = [])
    {
        // 💬 It may be clearer to use `OKEntity(name:components:)` and explicitly write `NodeComponent` in the list.
        
        self.name = node.name
        super.init()
        
        self.addComponent(NodeComponent(node: node))
        
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// Creates an entity and adds an `NodeComponent` associated with the specified node to the entity, optionally adding the node to a specified parent.
    public init(name: String? = nil,
                node: SKNode,
                addToNode parentNode: SKNode? = nil)
    {
        // CHECK: Will making `name` an optional argument conflict with the signature of `GKEntity(node:addToNode:)` extensions?
        self.name = name
        super.init()
        self.addComponent(NodeComponent(node: node, addToNode: parentNode))
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    // MARK: - Components
    
    /// Adds a component to the entity and notifies the delegate, logging a warning if the entity already has another component of the same class, as the new component will replace the existing component.
    open override func addComponent(_ component: GKComponent) {
        
        /// 🐛 NOTE: BUG? GameplayKit's default implementation does NOT remove a component from its current entity before adding it to a different entity.
        /// So we do that here, because otherwise it may cause unexpected behavior. A component's `entity` property can only point to one entity anyway; the latest.
        
        /// ℹ️ DESIGN: DECIDED: When adding a `RelayComponent<TargetComponentType>`, we should NOT remove any existing component of the same type as the RelayComponent's target.
        /// REASON: Components need to operate on their entity; adding a RelayComponent to an entity does NOT and SHOULD NOT set the target component's `entity` property to that entity. So we cannot and SHOULD NOT replace a direct component with a RelayComponent.
        /// NOTE: This design decision means that an entity might find 2 components of the same type when checking for them with `GKEntity.componentOrRelay(ofType:)`, e.g. a NodePointerStateComponent and a RelayComponent<NodePointerStateComponent>, so `GKEntity.componentOrRelay(ofType:)` must always return the direct component first.
        
        /// NOTE: Checking the `component.componentType` of a `RelayComponent` will return its `target?.componentType`, so we will use `type(of: component)` instead, to avoid deleting a direct component when a relay to the same component type is added.
        
        #if LOGECSVERBOSE
        debugLog("component: \(component), self: \(self)")
        #endif
        
        component.entity?.removeComponent(ofType: type(of: component))
        
        // Warn if we already have a component of the same class, as GameplayKit does not allow multiple components of the same type in the same entity.
        
        if  let existingComponent = self.component(ofType: type(of: component)) {
            
            /// If we have the **exact component instance** that is being added, just skip it and return.
            
            // TODO: Add test for both these cases.
            
            if  existingComponent === component { /// Note the 3 equal-signs: `===`
                
                OctopusKit.logForWarnings("\(self) already has \(component) — Not re-adding")
                OctopusKit.logForTips("If you mean to reset the component or call its `didAddToEntity()` again, then remove it manually and re-add.")
                
                return
                
            } else {
            
                OctopusKit.logForWarnings("\(self) replacing \(existingComponent) → \(component)")
            
                // NOTE: BUG? GameplayKit's default implementation does NOT seem to set the about-to-be-replaced component's entity property to `nil`.
                // So we manually remove an existing duplicate component here, if any.
                
                self.removeComponent(ofType: type(of: existingComponent))
            }
        }
        
        super.addComponent(component)
        delegate?.entity(self, didAddComponent: component)
    }
    
    // MARK: - Removal
    
    /// Requests this entity's `OKEntityDelegate` (i.e. the scene) to remove this entity.
    @inlinable
    public final func removeFromDelegate() {
        self.delegate?.entityDidRequestRemoval(self)
    }
    
    deinit {
        OctopusKit.logForDeinits("\(self)")
        
        // Give all components a chance to clean up after themselves.
        
        // ⚠️ NOTE: Not doing this may cause a situation where a `deinit`ing component tries to access its `deinit`ed `entity` property in `OKComponent.willRemoveFromEntity()`, causing a `-[OctopusKit.OKEntity retain]: message sent to deallocated instance` exception.
        
        for component in self.components {
            self.removeComponent(ofType: type(of: component))
        }
    }
    
}
