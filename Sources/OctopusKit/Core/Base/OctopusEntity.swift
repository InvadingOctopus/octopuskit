//
//  OctopusEntity.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/11.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A protocol for types that manage entities, such as `OctopusScene`.
public protocol OctopusEntityDelegate: class {
    func entity(_ entity: GKEntity, didAddComponent component: GKComponent)
    func entity(_ entity: GKEntity, willRemoveComponent component: GKComponent)
    @discardableResult func entity(_ entity: GKEntity, didSpawn spawnedEntity: GKEntity) -> Bool
    func entityDidRequestRemoval(_ entity: GKEntity)
}

/// A collection of components.
///
/// An entity will usually have a visual representation on-screen via a `SpriteKitComponent` node.
///
/// An `OctopusScene` is also represented by an entity via a `SpriteKitSceneComponent`.
open class OctopusEntity: GKEntity {
    
    /// Identifies the entity. Can be non-unique and shared with other entities.
    ///
    /// An `OctopusScene` may search for entities by their name via `entities(withName:)`.
    public var name: String?
    
    public weak var delegate: OctopusEntityDelegate? // CHECK: Should this be `weak`?
    
    open override var description: String {
        // CHECK: Improve?
        return "\(super.description) \"\(self.name ?? "")\""
    }
    
    open override var debugDescription: String {
        return "\(self.description)\(components.count > 0 ? " \(components.count) components = \(components)" : "")"
    }
    
    // ℹ️ NOTE: These inits are not marked with the `convenience` modifier because we want to set `self.name = name` BEFORE calling `GKEntity` inits, in order to ensure that the log entries for `addComponent` will include the `OctopusEntity`'s name if it's supplied.
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
    
    /// Creates an entity, adding an `SpriteKitComponent` to associate it with the specified node and adds any other components if specified.
    ///
    /// Sets the entity's name to the node's name, if any.
    public init(node: SKNode,
                components: [GKComponent] = [])
    {
        // 💬 It may be clearer to use `OctopusEntity(name:components:)` and explicitly write `SpriteKitComponent` in the list.
        
        self.name = node.name
        super.init()
        
        self.addComponent(SpriteKitComponent(node: node))
        
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// Creates an entity and adds an `SpriteKitComponent` associated with the specified node to the entity, optionally adding the node to a specified parent.
    public init(name: String? = nil,
                node: SKNode,
                addToNode parentNode: SKNode? = nil)
    {
        // CHECK: Will making `name` an optional argument conflict with the signature of `GKEntity(node:addToNode:)` extensions?
        self.name = name
        super.init()
        self.addComponent(SpriteKitComponent(node: node, addToNode: parentNode))
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Adds a component to the entity and notifies the delegate, logging a warning if the entity already has another component of the same class, as the new component will replace the existing component.
    open override func addComponent(_ component: GKComponent) {
        
        // Warn if we already have a component of the same class, as GameplayKit does not allow multiple components of the same type in the same entity.
        
        // NOTE: Do not compare with `RelayComponent`s here.
        
        if let existingComponent = self.component(ofType: type(of: component)) {
            OctopusKit.logForWarnings.add("\(self) replacing \(existingComponent) → \(component)")
        }
        
        super.addComponent(component)
        delegate?.entity(self, didAddComponent: component)
    }
    
    deinit {
        OctopusKit.logForDeinits.add("\(self)")
        
        // Give all components a chance to clean up after themselves.
        
        // ⚠️ NOTE: Not doing this may cause a situation where a `deinit`ing component tries to access its `deinit`ed `entity` property in `OctopusComponent.willRemoveFromEntity()`, causing a `-[OctopusKit.OctopusEntity retain]: message sent to deallocated instance` exception.
        
        for component in self.components {
            self.removeComponent(ofType: type(of: component))
        }
    }
    
}
