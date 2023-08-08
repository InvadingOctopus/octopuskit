//
//  GKEntity+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/11.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import OctopusCore
import GameplayKit

public extension GKEntity {
    
    // MARK: - Properties
    
    /// Returns the SpriteKit scene of either the `SceneComponent`, or the node of the `NodeComponent` or `GKSKNodeComponent` (in that order) associated with this entity, if any.
    ///
    /// A `RelayComponent` may be used in place of those components.
    @inlinable
    var scene: SKScene? {
        
        #if LOGECSDEBUG
        debugLog("self: \(self)")
        #endif
        
        // NOTE: To avoid infinite recursion when a RelayComponent checks its node's scene, we now skip `componentOrRelay(ofType:)` and just use `component(ofType:)` and check `RelayComponent.directlyReferencedComponent` instead of `RelayComponent.target`
        
        return self.component(ofType: SceneComponent.self)?.scene
            ?? self.component(ofType: RelayComponent<SceneComponent>.self)?.directlyReferencedComponent?.scene
            ?? self.node?.scene
    }
    
    /// Convenient shorthand for accessing the SpriteKit node associated with this entity's `NodeComponent` or `GKSKNodeComponent` (in that order.)
    ///
    /// A `RelayComponent` may be used in place of those components.
    @inlinable
    var node: SKNode? {
        
        #if LOGECSDEBUG
        debugLog("self: \(self)")
        #endif
        
        // ❕ NOTE: componentOrRelay(ofType:) used to cause infinite recursion with a `RelayComponent` that only had a `sceneComponentType`, because the RelayComponent tried to access its `entityNode` which leads back here. :)
        // FIXED: We now skip `componentOrRelay(ofType:)` and just use `component(ofType:)` and check `RelayComponent.directlyReferencedComponent` instead of `RelayComponent.target`
        
        // ⚠️ WARNING: SUBCLASSES of `NodeComponent` will NOT be recognized here!
        
        let nodeComponent =
               self.component(ofType: NodeComponent.self)
            ?? self.component(ofType: GKSKNodeComponent.self)
            ?? self.component(ofType: RelayComponent<NodeComponent>.self)?.directlyReferencedComponent
            ?? self.component(ofType: RelayComponent<GKSKNodeComponent>.self)?.directlyReferencedComponent
        
        #if LOGECSDEBUG
        debugLog("nodeComponent: \(nodeComponent), .node: \(nodeComponent?.node)")
        #endif
        
        return nodeComponent?.node
        
        // CHECK: Is looking for GKSKNodeComponent necessary?
    } 
    
    /// Convenient shorthand for accessing the SpriteKit node associated with this entity's `NodeComponent` or `GKSKNodeComponent` (in that order) as an `SKSpriteNode` if applicable.
    ///
    /// A `RelayComponent` may be used in place of those components.
    @inlinable
    var sprite: SKNode? {
        self.node as? SKSpriteNode
    }
    
    /// Convenient shorthand for accessing the `SKPhysicsBody` associated with this entity's `PhysicsComponent` or its `NodeComponent` node (in that order).
    ///
    /// A `RelayComponent` may be used in place of those components.
    @inlinable
    var physicsBody: SKPhysicsBody? {
        self[PhysicsComponent.self]?.physicsBody ?? self.node?.physicsBody
    }
    
    /// Convenient shorthand for accessing the current `OKEntityState` associated with this entity's `StateMachineComponent`, if any.
    ///
    /// A `RelayComponent` may be used in place of that component.
    @inlinable
    var state: OKEntityState? {
        self[StateMachineComponent.self]?.stateMachine.currentState as? OKEntityState
    }
    
    /// Returns the component matching `componentClass` or a `RelayComponent` linked to that type, if present in the entity.
    ///
    /// This subscript is a shortcut for the `componentOrRelay(ofType:)` method.
    @inlinable
    subscript <ComponentType> (componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: GKComponent
    {
        self.componentOrRelay(ofType: componentClass)
    }
    
    // MARK: - Initializers
    
    // ℹ️ Warnings about initializing with nodes that already have an entity, are the responsibility of the `NodeComponent` or `GKSKNodeComponent`.
    
    /// Creates an entity with the supplied components.
    ///
    /// - Note: The order in which the components are passed may be crucial to correctly resolving dependencies between different components.
    convenience init(components: [GKComponent]) {
        self.init()
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// Creates an entity with a `NodeComponent` representing the specified node, optionally adding that node to a specified parent node.
    convenience init(node: SKNode,
                     addToNode parentNode: SKNode? = nil)
    {
        self.init()
        self.addComponent(NodeComponent(node: node, addToNode: parentNode))
    }
    
    // MARK: - Component Management
    
    /// An overload of `addComponent(_:)` that allows optionally `nil` arguments.
    ///
    /// Useful for chaining calls with `coComponent(ofType:)` or other methods that may potentially return `nil`.
    @inlinable
    func addComponent(_ component: GKComponent?) {
        
        #if LOGECSVERBOSE
        debugLog("component: \(component), self: \(self)")
        #endif
        
        if  let component = component {
            self.addComponent(component)
        } else {
            OKLog.logForDebug.debug("\(📜("nil"))") // CHECK: Is logging this helpful?
        }
    }
    
    /// Adds the components in the specified order.
    ///
    /// - NOTE: The order in which the components are passed may be crucial to correctly resolving dependencies between different components.
    @inlinable
    func addComponents(_ components: [GKComponent]) {
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// An overload of `addComponents(_:)` that allows optionally `nil` elements.
    ///
    /// Useful for chaining calls with `coComponent(ofType:)` or other methods that may potentially return `nil`.
    @inlinable
    func addComponents(_ components: [GKComponent?]) {
        for case let component in components {
            self.addComponent(component)
        }
    }
    
    /// Returns the component matching `componentClass` or a `RelayComponent` whose `target` is a component of that type, if present in the entity.
    ///
    /// - WARNING: This method will **not** find *subclasses* of `componentClass`.
    @inlinable
    func componentOrRelay <ComponentType> (ofType componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: GKComponent
    {
        #if LOGECSDEBUG
        debugLog("ComponentType: \(ComponentType.self), componentClass: \(componentClass), self: \(self)")
        #endif
        
        // FIXED: BUG: 201804029A: APPLEBUG? SWIFT LIMITATION?
        // Checking an array like `[GKComponent.Type]` with `entity.componentOrRelay(ofType:)` does not pass the actual metatypes, and so it may cause false warnings about missing components.
        // NOTE: This does not affect directly sending "concrete" subtypes of `GKComponent` to `entity.componentOrRelay(ofType:)`.
        // FIXED! via `GKComponent.baseComponent` 2019.11.11
        // To work around the bug, we're basically reimplementing `GKEntity.component(ofType:)` as we can't override it because `Overriding declarations in extensions is not supported` and `Overriding non-open instance method outside of its defining module` as of 2019-11-11
        // THANKS: https://forums.swift.org/u/TellowKrinkle
        // https://forums.swift.org/t/type-information-loss-when-comparing-generic-variables-with-an-array-of-metatypes/30650/2
        
        // ℹ️ DESIGN: There may be cases when an entity may have a component of a specific type as well as a `RelayComponent` with a target of the same type; e.g. a NodePointerStateComponent and a RelayComponent<NodePointerStateComponent>. See `OKEntity.addComponent(_:)` for the comments about this decision.
        // This method should always return the direct component (non-relay) first.
        
        // Look for a direct match as well as any RelayComponent with a target matching ComponentType
        
        var directComponent: ComponentType?
        var relayComponent:  RelayComponent<ComponentType>?
        
        // #1: Try GKEntity's base implementation first.
        
        directComponent = self.component(ofType: componentClass)
        
        if  directComponent != nil {
            return directComponent!
        }
        
        // #2: If that didn't work, try a manual search.
        
        components.forEach {
            component in
            
            // Using `type(of:)` may fail to accurately find matching types at runtime. See the forums discussion linked above.
            // `RelayComponent` overrides `GKComponent.componentType` to return the type of the relay's target component.
            
            if  component.componentType == componentClass {
                directComponent = component as? ComponentType
                relayComponent  = component as? RelayComponent
            }
        }
        
        return directComponent ?? relayComponent?.target
    }
    
    /// Removes components of the specified types.
    @inlinable
    func removeComponents(ofTypes componentClasses: [GKComponent.Type]) {
        for componentClass in componentClasses {
            self.removeComponent(ofType: componentClass)
        }
    }
    
    /// Removes all components from this entity.
    ///
    /// Calls `removeComponent(ofType:)` for each item in `components`.
    @inlinable
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

public extension GKEntity {
    
    // MARK: - Operators
    
    /// Adds a component to the entity.
    @inlinable
    static func += (entity: GKEntity, component: GKComponent?) {
        entity.addComponent(component)
    }
 
    /// Adds an array of components to the entity.
    @inlinable
    static func += (entity: GKEntity, components: [GKComponent]) {
        entity.addComponents(components)
    }
    
    /// Adds an array of components to the entity.
    @inlinable
    static func += (entity: GKEntity, components: [GKComponent?]) {
        entity.addComponents(components)
    }
    
    /// Removes the component of the specified type from the entity.
    @inlinable
    static func -= <ComponentType> (entity: GKEntity, componentClass: ComponentType.Type)
        where ComponentType: GKComponent
    {
        entity.removeComponent(ofType: componentClass)
    }
    
    /// Removes components of the specified types from the entity.
    @inlinable
    static func -= (entity: GKEntity, componentClasses: [GKComponent.Type]) {
        entity.removeComponents(ofTypes: componentClasses)
    }
}
