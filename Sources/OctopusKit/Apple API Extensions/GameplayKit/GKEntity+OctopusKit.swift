//
//  GKEntity+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/11.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import GameplayKit

public extension GKEntity {
    
    // MARK: - Properties
    
    /// Returns the SpriteKit scene of either the `SpriteKitSceneComponent`, or the node of the `SpriteKitComponent` or `GKSKNodeComponent` (in that order) associated with this entity, if any.
    ///
    /// A `RelayComponent` may be used in place of those components.
    var scene: SKScene? {
        return componentOrRelay(ofType: SpriteKitSceneComponent.self)?.scene
            ?? self.node?.scene
    }
    
    /// Convenient shorthand for accessing the SpriteKit node associated with this entity's `SpriteKitComponent` or `GKSKNodeComponent` (in that order.)
    ///
    /// A `RelayComponent` may be used in place of those components.
    var node: SKNode? {
        return componentOrRelay(ofType: SpriteKitComponent.self)?.node
            ?? componentOrRelay(ofType: GKSKNodeComponent.self)?.node // CHECK: Necessary?
    }
    
    /// Convenient shorthand for accessing the SpriteKit node associated with this entity's `SpriteKitComponent` or `GKSKNodeComponent` (in that order) as an `SKSpriteNode` if applicable.
    ///
    /// A `RelayComponent` may be used in place of those components.
    var sprite: SKNode? {
        return self.node as? SKSpriteNode
    }
    
    /// Returns the component matching `componentClass` or a `RelayComponent` linked to that type, if present in the entity.
    ///
    /// This subscript is a shortcut for the `componentOrRelay(ofType:)` method.
    subscript <ComponentType> (componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: GKComponent
    {
        self.componentOrRelay(ofType: componentClass)
    }
    
    // MARK: - Initializers
    
    // ℹ️ Warnings about initializing with nodes that already have an entity, are the responsibility of the `SpriteKitComponent` or `GKSKNodeComponent`.
    
    /// Creates an entity with the supplied components.
    ///
    /// - Note: The order in which the components are passed may be crucial to correctly resolving dependencies between different components.
    convenience init(components: [GKComponent]) {
        self.init()
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// Creates an entity with a `SpriteKitComponent` representing the specified node, optionally adding that node to a specified parent node.
    convenience init(node: SKNode,
                     addToNode parentNode: SKNode? = nil)
    {
        self.init()
        self.addComponent(SpriteKitComponent(node: node, addToNode: parentNode))
    }
    
    // MARK: - Component Management
    
    /// An overload of `addComponent(_:)` that allows optionally `nil` arguments.
    ///
    /// Useful for chaining calls with `coComponent(ofType:)` or other methods that may potentially return `nil`.
    func addComponent(_ component: GKComponent?) {
        if  let component = component {
            self.addComponent(component)
        } else {
            OctopusKit.logForDebug.add("nil") // CHECK: Is logging this helpful?
        }
    }
    
    /// Adds the components in the specified order.
    ///
    /// - NOTE: The order in which the components are passed may be crucial to correctly resolving dependencies between different components.
    func addComponents(_ components: [GKComponent]) {
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// An overload of `addComponents(_:)` that allows optionally `nil` elements.
    ///
    /// Useful for chaining calls with `coComponent(ofType:)` or other methods that may potentially return `nil`.
    func addComponents(_ components: [GKComponent?]) {
        for case let component in components {
            self.addComponent(component)
        }
    }
    
    /// Returns the component matching `componentClass` or a `RelayComponent` whose `target` is a component of that type, if present in the entity.
    func componentOrRelay <ComponentType> (ofType componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: GKComponent
    {
        // FIXED: BUG: 201804029A: APPLEBUG? SWIFT LIMITATION?
        // Checking an array like `[GKComponent.Type]` with `entity.componentOrRelay(ofType:)` does not pass the actual metatypes, and so it may cause false warnings about missing components.
        // NOTE: This does not affect directly sending "concrete" subtypes of `GKComponent` to `entity.componentOrRelay(ofType:)`.
        // FIXED! via `GKComponent.baseComponent` 2019.11.11
        // To work around the bug, we're basically reimplementing `GKEntity.component(ofType:)` as we can't override it because `Overriding declarations in extensions is not supported` and `Overriding non-open instance method outside of its defining module` as of 2019-11-11
        // THANKS: https://forums.swift.org/u/TellowKrinkle
        // https://forums.swift.org/t/type-information-loss-when-comparing-generic-variables-with-an-array-of-metatypes/30650/2
        
        let componentOrRelay = components.first { component in
            // Using `type(of:)` will fail to accurately find all matches. See the Swift forums discussion linked above.
            // `RelayComponent` overrides `GKComponent.componentType` to return the type of the relay's target component.
            component.componentType == componentClass
        } //?.baseComponent as? ComponentType
        
        return  componentOrRelay as? ComponentType
            ?? (componentOrRelay as? RelayComponent<ComponentType>)?.target
        
        // CHECK: PERFORMANCE: Will using `baseComponent` for every component be better, compared to casting as `RelayComponent`?
    }
    
    /// Removes components of the specified types.
    func removeComponents(ofTypes componentClasses: [GKComponent.Type]) {
        for componentClass in componentClasses {
            self.removeComponent(ofType: componentClass)
        }
    }
    
    /// Removes all components from this entity.
    func removeAllComponents() {
        
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
