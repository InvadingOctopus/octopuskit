//
//  GKEntityWrapper.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/06/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit
import SpriteKit

/// Experimental prototype for protocol-based components.
open class GKEntityWrapper: Entity, UpdatablePerFrame {

    public let gkEntity = GKEntity()
    
    // MARK: - Properties
    
    /// Identifies the entity. Can be non-unique and shared with other entities.
    ///
    /// An `OKScene` may search for entities by their name via `entities(withName:)`.
    public var name: String? = nil
    
    public var components: [Component] = []
    
    public var delegate: EntityDelegate? = nil // CHECK: Should this be `weak`?
    
    /// Indicates whether a scene should check whether it has systems for each of this entity's components that must be updated every frame or turn. Setting `true` may improve performance for entities that are added frequently. Setting `false` may help reduce bugs that result from missing systems.
    open var suppressSystemsAvailabilityCheck: Bool = false
    
    open var description: String {
        // CHECK: Improve?
        "\(gkEntity.description) \"\(self.name ?? "")\""
    }
    
    open var debugDescription: String {
        "\(self.description)\(components.count > 0 ? " \(components.count) components = \(components)" : "")"
    }
    
    // MARK: Component Shortcuts
    
    /// Convenient shorthand for accessing the current `EntityState` associated with this entity's `StateMachineComponent`, if any.
    ///
    /// A `RelayComponent` may be used in place of that component.
    @inlinable
    public final var state: OKEntityState? {
        nil // TODO: self[StateMachineComponent.self]?.stateMachine.currentState as? EntityState
    }
    
    /// Returns the SpriteKit scene of either the `SceneComponent`, or the node of the `NodeComponent` or `GKSKNodeComponent` (in that order) associated with this entity, if any.
    ///
    /// A `RelayComponent` may be used in place of those components.
    @inlinable
    public final var scene: SKScene? {
        
        #if LOGECSDEBUG
        debugLog("self: \(self)")
        #endif
        
        // NOTE: To avoid infinite recursion when a RelayComponent checks its node's scene, we now skip `componentOrRelay(ofType:)` and just use `component(ofType:)` and check `RelayComponent.directlyReferencedComponent` instead of `RelayComponent.target`
        
        return nil
        // TODO:
//        return self.component(ofType: SceneComponent.self)?.scene
//            ?? self.component(ofType: RelayComponent<SceneComponent>.self)?.directlyReferencedComponent?.scene
//            ?? self.node?.scene
    }
    
    /// Convenient shorthand for accessing the SpriteKit node associated with this entity's `NodeComponent` or `GKSKNodeComponent` (in that order.)
    ///
    /// A `RelayComponent` may be used in place of those components.
    @inlinable
    public final var node: SKNode? {
        
        #if LOGECSDEBUG
        debugLog("self: \(self)")
        #endif
        
        // ❕ NOTE: componentOrRelay(ofType:) used to cause infinite recursion with a `RelayComponent` that only had a `sceneComponentType`, because the RelayComponent tried to access its `entityNode` which leads back here. :)
        // FIXED: We now skip `componentOrRelay(ofType:)` and just use `component(ofType:)` and check `RelayComponent.directlyReferencedComponent` instead of `RelayComponent.target`
        
        // ⚠️ WARNING: SUBCLASSES of `NodeComponent` will NOT be recognized here!
        
        return nil
        // TODO:
//        let nodeComponent =
//               self.component(ofType: NodeComponent.self)
//            ?? self.component(ofType: GKSKNodeComponent.self)
//            ?? self.component(ofType: RelayComponent<NodeComponent>.self)?.directlyReferencedComponent
//            ?? self.component(ofType: RelayComponent<GKSKNodeComponent>.self)?.directlyReferencedComponent
//
//        #if LOGECSDEBUG
//        debugLog("nodeComponent: \(nodeComponent), .node: \(nodeComponent?.node)")
//        #endif
//
//        return nodeComponent?.node
        
        // CHECK: Is looking for GKSKNodeComponent necessary?
    }
    
    /// Convenient shorthand for accessing the SpriteKit node associated with this entity's `NodeComponent` or `GKSKNodeComponent` (in that order) as an `SKSpriteNode` if applicable.
    ///
    /// A `RelayComponent` may be used in place of those components.
    @inlinable
    public final var sprite: SKSpriteNode? {
        self.node as? SKSpriteNode
    }
    
    /// Convenient shorthand for accessing the `SKPhysicsBody` associated with this entity's `PhysicsComponent` or its `NodeComponent` node (in that order).
    ///
    /// A `RelayComponent` may be used in place of those components.
    @inlinable
    public final var physicsBody: SKPhysicsBody? {
        nil // TODO: self[PhysicsComponent.self]?.physicsBody ?? self.node?.physicsBody
    }
    
    /// Returns the component matching `componentClass` or a `RelayComponent` linked to that type, if present in the entity.
    ///
    /// This subscript is a shortcut for the `componentOrRelay(ofType:)` method.
    @inlinable
    public subscript <ComponentType> (componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: Component
    {
        nil // TODO: self.componentOrRelay(ofType: componentClass)
    }
    
    // MARK: - Initializers
    
    /// ℹ️ Warnings about initializing with nodes that already have an entity, are the responsibility of the `NodeComponent` or `GKSKNodeComponent`.
    
    // ℹ️ NOTE: These inits are not marked with the `convenience` modifier because we want to set `self.name = name` BEFORE calling `GKEntity` inits, in order to ensure that the log entries for `addComponent` will include the `Entity`'s name if it's supplied.
    // However, if these were convenience initializers, we would get the error: "'self' used in property access 'name' before 'self.init' call"
    
    /// Creates an entity with the specified name and adds the components in the specified order.
    public init(name: String? = nil,
                components: [Component] = [])
    {
        self.name = name
        
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// Creates an entity, adding an `NodeComponent` to associate it with the specified node and adds any other components if specified.
    ///
    /// Sets the entity's name to the node's name, if any.
    public init(node: SKNode,
                components: [Component] = [])
    {
        // 💬 It may be clearer to use `Entity(name:components:)` and explicitly write `NodeComponent` in the list.
        
        self.name = node.name
        
        // TODO: self.addComponent(NodeComponent(node: node))
        
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
        
        // TODO: self.addComponent(NodeComponent(node: node, addToNode: parentNode))
    }
    
    /// Creates an entity with the supplied components.
    ///
    /// - Note: The order in which the components are passed may be crucial to correctly resolving dependencies between different components.
    public required  convenience init(components: [Component]) {
        self.init()
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// Creates an entity with a `NodeComponent` representing the specified node, optionally adding that node to a specified parent node.
    public required convenience init(node: SKNode,
                     addToNode parentNode: SKNode? = nil)
    {
        self.init()
        // TODO: self.addComponent(NodeComponent(node: node, addToNode: parentNode))
    }
    
    // MARK: - GKEntity
    
    public final func update(deltaTime: TimeInterval) {
        self.components.forEach { $0.update(deltaTime: deltaTime) }
    }
        
    // MARK: - Component Management
    
    // MARK: Adding Components
    
    /// Adds a component to the entity and notifies the delegate, logging a warning if the entity already has another component of the same class, as the new component will replace the existing component.
    public func addComponent(_ component: Component) {
        
        /// 🐛 NOTE: BUG? GameplayKit's default implementation does NOT remove a component from its current entity before adding it to a different entity.
        /// So we do that here, because otherwise it may cause unexpected behavior. A component's `entity` property can only point to one entity anyway; the latest.
        
        /// ℹ️ DESIGN: DECIDED: When adding a `RelayComponent<TargetComponentType>`, we should NOT remove any existing component of the same type as the RelayComponent's target.
        /// REASON: Components need to operate on their entity; adding a RelayComponent to an entity does NOT and SHOULD NOT set the target component's `entity` property to that entity. So we cannot and SHOULD NOT replace a direct component with a RelayComponent.
        /// NOTE: This design decision means that an entity might find 2 components of the same type when checking for them with `GKEntity.componentOrRelay(ofType:)`, e.g. a NodePointerStateComponent and a RelayComponent<NodePointerStateComponent>, so `GKEntity.componentOrRelay(ofType:)` must always return the direct component first.
        
        /// NOTE: Checking the `component.componentType` of a `RelayComponent` will return its `target?.componentType`, so we will use `type(of: component)` instead, to avoid deleting a direct component when a relay to the same component type is added.
        
        #if LOGECSVERBOSE
        debugLog("component: \(component), self: \(self)")
        #endif
        
        // TODO:
//        component.entity?.removeComponent(ofType: type(of: component))
//
//        // Warn if we already have a component of the same class, as GameplayKit does not allow multiple components of the same type in the same entity.
//
//        if  let existingComponent = self.component(ofType: type(of: component)) {
//
//            /// If we have the **exact component instance** that is being added, just skip it and return.
//
//            // TODO: Add test for both these cases.
//
//            if  existingComponent === component { /// Note the 3 equal-signs: `===`
//
//                OctopusKit.logForWarnings("\(self) already has \(component) — Not re-adding")
//                OctopusKit.logForTips("If you mean to reset the component or call its `didAddToEntity()` again, then remove it manually and re-add.")
//
//                return
//
//            } else {
//
//                OctopusKit.logForWarnings("\(self) replacing \(existingComponent) → \(component)")
//
//                // NOTE: BUG? GameplayKit's default implementation does NOT seem to set the about-to-be-replaced component's entity property to `nil`.
//                // So we manually remove an existing duplicate component here, if any.
//
//                self.removeComponent(ofType: type(of: existingComponent))
//            }
//        }
//
//        super.addComponent(component)
//        delegate?.entity(self, didAddComponent: component)
    }
    
    /// An overload of `addComponent(_:)` that allows optionally `nil` arguments.
    ///
    /// Useful for chaining calls with `coComponent(ofType:)` or other methods that may potentially return `nil`.
    @inlinable
    public final func addComponent(_ component: Component?) {
        
        #if LOGECSVERBOSE
        debugLog("component: \(component), self: \(self)")
        #endif
        
        if  let component = component {
            self.addComponent(component)
        } else {
            OctopusKit.logForDebug("nil") // CHECK: Is logging this helpful?
        }
    }
    
    /// Adds the components in the specified order.
    ///
    /// - NOTE: The order in which the components are passed may be crucial to correctly resolving dependencies between different components.
    @inlinable
    public final func addComponents(_ components: [Component]) {
        for component in components {
            self.addComponent(component)
        }
    }
    
    /// An overload of `addComponents(_:)` that allows optionally `nil` elements.
    ///
    /// Useful for chaining calls with `coComponent(ofType:)` or other methods that may potentially return `nil`.
    @inlinable
    public final func addComponents(_ components: [Component?]) {
        for case let component in components {
            self.addComponent(component)
        }
    }
    
    // MARK: Queries
    
    public final func component<ComponentType>(ofType componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType : Component
    {
        nil // TODO
    }

    /// Returns the component matching `componentClass` or a `RelayComponent` whose `target` is a component of that type, if present in the entity.
    ///
    /// - WARNING: This method will **not** find *subclasses* of `componentClass`.
    @inlinable
    public final func componentOrRelay <ComponentType> (ofType componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: Component
    {
        #if LOGECSDEBUG
        debugLog("ComponentType: \(ComponentType.self), componentClass: \(componentClass), self: \(self)")
        #endif
        
        // FIXED: BUG: 201804029A: APPLEBUG? SWIFT LIMITATION?
        // Checking an array like `[Component.Type]` with `entity.componentOrRelay(ofType:)` does not pass the actual metatypes, and so it may cause false warnings about missing components.
        // NOTE: This does not affect directly sending "concrete" subtypes of `Component` to `entity.componentOrRelay(ofType:)`.
        // FIXED! via `Component.baseComponent` 2019.11.11
        // To work around the bug, we're basically reimplementing `Entity.component(ofType:)` as we can't override it because `Overriding declarations in extensions is not supported` and `Overriding non-open instance method outside of its defining module` as of 2019-11-11
        // THANKS: https://forums.swift.org/u/TellowKrinkle
        // https://forums.swift.org/t/type-information-loss-when-comparing-generic-variables-with-an-array-of-metatypes/30650/2
        
        // ℹ️ DESIGN: There may be cases when an entity may have a component of a specific type as well as a `RelayComponent` with a target of the same type; e.g. a NodePointerStateComponent and a RelayComponent<NodePointerStateComponent>. See `Entity.addComponent(_:)` for the comments about this decision.
        // This method should always return the direct component (non-relay) first.
        
        // Look for a direct match as well as any RelayComponent with a target matching ComponentType
        
        return nil // TODO:
//        var directComponent: ComponentType?
//        var relayComponent:  RelayComponent<ComponentType>?
//
//        // #1: Try GKEntity's base implementation first.
//
//        directComponent = self.component(ofType: componentClass)
//
//        if  directComponent != nil {
//            return directComponent!
//        }
//
//        // #2: If that didn't work, try a manual search.
//
//        components.forEach {
//            component in
//
//            // Using `type(of:)` may fail to accurately find matching types at runtime. See the forums discussion linked above.
//            // `RelayComponent` overrides `Component.componentType` to return the type of the relay's target component.
//
//            if  component.componentType == componentClass {
//                directComponent = component as? ComponentType
//                relayComponent  = component as? RelayComponent
//            }
//        }
//
//        return directComponent ?? relayComponent?.target
    }
    
    // MARK: Removing Components
    
    public final func removeComponent<ComponentType>(ofType componentClass: ComponentType.Type) where ComponentType : Component {
        return
    }
    
    /// Removes components of the specified types.
    @inlinable
    public final func removeComponents(ofTypes componentClasses: [Component.Type]) {
        for componentClass in componentClasses {
            // TODO: self.removeComponent(ofType: componentClass)
        }
    }
    
    /// Removes all components from this entity.
    ///
    /// Calls `removeComponent(ofType:)` for each item in `components`.
    @inlinable
    public final func removeAllComponents() {
        
        // NOTE: Cannot modify a collection while it is being enumerated, so go the longer way around by using a second list of items to remove.
        
        // TODO:
//        var componentsToRemove = Set<Component>()
//
//        for component in components {
//            componentsToRemove.insert(component)
//        }
//
//        for componentToRemove in componentsToRemove {
//            self.removeComponent(ofType: type(of: componentToRemove))
//        }
    }
    
    // MARK: - Self Removal
    
    /// Requests this entity's `EntityDelegate` (i.e. the scene) to remove this entity.
    @inlinable
    public final func removeFromDelegate() {
        // TODO: self.delegate?.entityDidRequestRemoval(self)
    }
    
    deinit {
        OctopusKit.logForDeinits("\(self)")
        
        // Give all components a chance to clean up after themselves.
        
        // ⚠️ NOTE: Not doing this may cause a situation where a `deinit`ing component tries to access its `deinit`ed `entity` property in `OKComponent.willRemoveFromEntity()`, causing a `-[OctopusKit.Entity retain]: message sent to deallocated instance` exception.
        
        for component in self.components {
            // TODO: self.removeComponent(ofType: type(of: component))
        }
    }
    
}

