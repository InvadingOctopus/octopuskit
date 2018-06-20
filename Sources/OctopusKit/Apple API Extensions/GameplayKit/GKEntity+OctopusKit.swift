//
//  GKEntity+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/11.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import GameplayKit

extension GKEntity {
    
    // MARK: - Properties
    
    /// Returns the SpriteKit scene of either the `SpriteKitSceneComponent`, or the node of the `SpriteKitComponent` or `GKSKNodeComponent` (in that order) associated with this entity, if any.
    ///
    /// A `RelayComponent` may be used in place of those components.
    public var scene: SKScene? {
        return componentOrRelay(ofType: SpriteKitSceneComponent.self)?.scene
            ?? self.node?.scene
    }
    
    /// Convenient shorthand for accessing the SpriteKit node associated with this entity's `SpriteKitComponent` or `GKSKNodeComponent` (in that order.)
    ///
    /// A `RelayComponent` may be used in place of those components.
    public var node: SKNode? {
        return componentOrRelay(ofType: SpriteKitComponent.self)?.node
            ?? componentOrRelay(ofType: GKSKNodeComponent.self)?.node // CHECK: Necessary?
    }
    
    /// Convenient shorthand for accessing the SpriteKit node associated with this entity's `SpriteKitComponent` or `GKSKNodeComponent` (in that order) as an `SKSpriteNode` if applicable.
    ///
    /// A `RelayComponent` may be used in place of those components.
    public var sprite: SKNode? {
        return self.node as? SKSpriteNode
    }
    
    // MARK: - Initializers
    
    // ℹ️ Warnings about initializing with nodes that already have an entity, are the responsibility of the `SpriteKitComponent` or `GKSKNodeComponent`.
    
    /// Creates an entity with the supplied components.
    ///
    /// - Note: The order in which the components are passed may be crucial to correctly resolving dependencies between different components.
    public convenience init(components: [GKComponent]) {
        self.init()
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// Creates an entity with a `SpriteKitComponent` representing the specified node, optionally adding that node to a specified parent node.
    public convenience init(node: SKNode,
                            addToNode parentNode: SKNode? = nil)
    {
        self.init()
        self.addComponent(SpriteKitComponent(node: node, addToNode: parentNode))
    }
    
    // MARK: - Component Management
    
    /// An overload of `addComponent(_:)` that allows optionally `nil` arguments.
    ///
    /// Useful for chaining calls with `coComponent(ofType:)` or other methods that may potentially return `nil`.
    public func addComponent(_ component: GKComponent?) {
        if let component = component {
            self.addComponent(component)
        }
        else {
            OctopusKit.logForDebug.add("nil") // CHECK: Is logging this helpful?
        }
    }
    
    /// Adds the components in the specified order.
    ///
    /// - Note: The order in which the components are passed may be crucial to correctly resolving dependencies between different components.
    public func addComponents(_ components: [GKComponent]) {
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// An overload of `addComponents(_:)` that allows optionally `nil` elements.
    ///
    /// Useful for chaining calls with `coComponent(ofType:)` or other methods that may potentially return `nil`.
    public func addComponents(_ components: [GKComponent?]) {
        for case let component in components {
            self.addComponent(component)
        }
    }
    
    /// Returns the component matching `componentClass` or a `RelayComponent` linked to that type, if present in the entity.
    ///
    /// ⚠️ BUG: 201804029A: See method comments.
    public func componentOrRelay<ComponentType>(ofType componentClass: ComponentType.Type) -> ComponentType? where ComponentType: GKComponent {
        // ⚠️
        // BUG: 201804029A: APPLEBUG: Sending an array like `[GKComponent.Type]`, such the one at `OctopusComponent.requiredComponents?`, to `entity.componentOrRelay(ofType:)` does not use the actual metatypes, and so it can cause false warnings about missing components.
        
        // ℹ️ DESIGN: Cannot override `GKEntity.component(ofType:)` because `Overriding declarations in extensions is not supported` and `Overriding non-open instance method outside of its defining module` as of 2018-04-10
        
        return self.component(ofType: componentClass)
            ?? self.component(ofType: RelayComponent<ComponentType>.self)?.target
    }
    
    /// Removes components of the specified types.
    public func removeComponents(ofTypes componentClasses: [GKComponent.Type]) {
        for componentClass in componentClasses {
            self.removeComponent(ofType: componentClass)
        }
    }
    
    /// Removes all components from this entity.
    public func removeAllComponents() {
        
        // NOTE: Cannot modify a collection while it is being enumerated, so go the longer way around by using a second list of items to remove.
        
        var componentsToRemove = Set<GKComponent>()
        
        for component in components {
            componentsToRemove.insert(component)
        }
        
        for componentToRemove in componentsToRemove {
            self.removeComponent(ofType: type(of: componentToRemove))
        }
    }
}
