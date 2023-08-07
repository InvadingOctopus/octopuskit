//
//  OKEntityContainer.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/08.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore
import SpriteKit
import GameplayKit

public typealias OctopusEntityContainer = OKEntityContainer

/// A protocol for sharing common code between `OKScene` and `OKSubscene` (or other types which manage entities) via Default Implementation Extensions.
public protocol OKEntityContainer: AnyObject {
    
    // CHECK: Replace `GKEntity` with `OKEntity`?
    
    // CHECK: Extract `createEntityFromChildNode(...)` and `addChildFromOrphanNodeComponent(...)` out to an SKNode-specific protocol?
    
    var entities:                     Set<GKEntity> { get set }
    var entitiesToRemoveOnNextUpdate: Set<GKEntity> { get set }
    var componentSystems:       [OKComponentSystem] { get set }
    
    // MARK: Entities & Components
    
    func entities(withName name: String) -> [OKEntity]
    
    func addEntity  (_ entity:    GKEntity)
    func addEntities(_ entities: [GKEntity])
    
    @inlinable @discardableResult
    func checkSystemAvailability <ComponentType> (for componentClass: ComponentType.Type,
                                                  in entity: GKEntity) -> Bool
        where ComponentType: GKComponent
    
    func checkSystemsAvailability        (for entity: GKEntity)
    func addAllComponentsFromAllEntities (to systemsCollection: [OKComponentSystem]?)
    func renameUnnamedEntitiesToNodeNames()
    
    @discardableResult func removeEntityOnNextUpdate(_ entityToRemove: GKEntity) -> Bool
    @discardableResult func removeEntity            (_ entityToRemove: GKEntity) -> Bool
    @discardableResult func removeEntities          (named name: String) -> Int
    
    // MARK: Frame Update
    
    func updateSystems(in systemsCollection: [OKComponentSystem]?, deltaTime seconds: TimeInterval)
}

/// A protocol for sharing common code between `OKScene` and `OKSubscene` (or other types which manage entities and nodes) via Default Implementation Extensions.
public protocol OKEntityContainerNode: OKEntityContainer where Self: SKNode {
    
    @discardableResult func createEntityFromChildNode(
        withName name: String,
        addingComponents components: [GKComponent]?,
        addEntityToScene: Bool)
        -> OKEntity?
    
    func addChildFromOrphanNodeComponent(in entity: GKEntity)
}

// MARK: - Default Implementation

public extension OKEntityContainer {
    
    // MARK: Adding Entities
    
    /// Adds an entity to the `entities` set, disallowing duplicate entities, and registers its components with the relevant systems.
    ///
    /// If the entity is an `OKEntity`, this scene is set as its delegate.
    @inlinable
    func addEntity(_ entity: GKEntity) {
        
        guard entities.insert(entity).inserted else {
            OKLog.logForWarnings.debug("\(entity) is already in \(self) — Not re-adding")
            return
        }
        
        OKLog.logForComponents.debug("\(entity.debugDescription), entities.count = \(entities.count)")
        
        // If it's an `OKEntity` (as opposed to a basic `GKEntity`) and this entity container is an `OKEntityDelegate` (e.g. an `OKScene`) then introduce them to each other.
        
        // CHECK: PERFORMANCE: Impact from casting?
        
        let octopusEntity = entity as? OKEntity
        
        octopusEntity?.delegate = self as? OKEntityDelegate
        
        // Issue a warning if the entity has any components that must be updated every frame or turn to perform their functions, but this scene does not have any component systems for them.
        
        if !(octopusEntity?.suppressSystemsAvailabilityCheck ?? false) { // A flag for improving performance by skipping this check for frequently-added entities.
            self.checkSystemsAvailability(for: entity)
        }
        
        // If the entity has as `NodeComponent` or `GKSKNodeComponent` whose node does not belong to any parent, add that node to this scene.
        
        // ℹ️ This lets `OKEntityDelegate` methods spawn new visual entities without explicitly specifying the scene, and also lets us conveniently add new entities by simply writing `self.addEntity(OKEntity(components: [NodeComponent(node: someSprite)]))`
        
        (self as? OKEntityContainerNode)?.addChildFromOrphanNodeComponent(in: entity) // CHECK: PERFORMANCE: Impact from casting?
        
        // In case the entity added components to itself before its `OKEntityDelegate` was set (which ensures that new components are automatically registered with the scene's component systems), add the entity's components to this scene's systems now to make sure we don't miss any.
        
        self.componentSystems.addComponents(foundIn: entity)
        
    }
    
    /// Adds multiple entities to the `entities` set in the order they are listed in the specified array, disallowing duplicate entities, and registers their components with the relevant systems.
    ///
    /// If an entity is an `OKEntity`, this scene is set as its delegate.
    @inlinable
    func addEntities(_ entities: [GKEntity]) {
        for entity in entities {
            self.addEntity(entity)
        }
    }
    
    /// Attempts to add all of the components from all entities in the scene, to all of the systems in the specified array that match the types of the components.
    ///
    /// If no `systemsCollection` is specified, then `componentSystems` is used.
    @inlinable
    func addAllComponentsFromAllEntities(to systemsCollection: [OKComponentSystem]? = nil) {
        
        let systemsCollection = systemsCollection ?? self.componentSystems
        
        OKLog.logForFramework.debug("systemsCollection = \(systemsCollection)")
        
        for entity in entities {
            systemsCollection.addComponents(foundIn: entity)
        }
    }
    
    /// Sets the names of all unnamed entities to the name of their `NodeComponent` or `GKSKNodeComponent` nodes.
    @inlinable
    func renameUnnamedEntitiesToNodeNames() {
        for case let entity as (OKEntity & Nameable) in entities {
            if  let node = entity.node,
                entity.name == nil
            {
                entity.name = node.name
            }
        }
    }
    
    // MARK: Finding Entities
    
    /// Returns an array of `OKEntity`s containing all the entities matching `name`. The array may be empty if no matches are found.
    @inlinable
    func entities(withName name: String) -> [OKEntity] {
        
        /// CHECK: Why an `Array` instead of a `Set`?
        
        let matches: [OKEntity] = self.entities.compactMap { entity in
            if  let hit = (entity as? OKEntity),
                hit.name == name
            {
                return hit
            } else {
                return nil
            }
        }
        
        return matches
    }
    
    // MARK: Removing Entities
    
    /// Marks an entity for removal in the next frame, at the beginning of the next call to `update(_:)`.
    ///
    /// This ensures that the list of entities is not mutated during a frame update, which would cause an exception/crash because of mutating a collection while it is being enumerated during the update
    ///
    /// - Returns: `true` if the entry was in the `entities` set.
    @inlinable @discardableResult
    func removeEntityOnNextUpdate(_ entityToRemove: GKEntity) -> Bool {
        
        guard entities.contains(entityToRemove) else {
            // CHECK: Warn on missing entry if the entity is going to leave anyway?
            // OKLog.logForWarnings.debug("\(entity) is not registered with \(self)")
            return false
        }
        
        OKLog.logForComponents.debug("\(entityToRemove.debugDescription)")
        
        // ℹ️ `entitiesToRemoveOnNextUpdate` is a `Set` which prevents duplicate values.
        
        entitiesToRemoveOnNextUpdate.insert(entityToRemove)
        return true
    }
    
    /// Removes an entity from the scene, and unregisters its components from the default component systems array.
    ///
    /// - IMPORTANT: ⚠️ Attempting to modify the list of entities during a frame update will cause an exception/crash, because of mutating a collection while it is being enumerated. To ensure safe removal, use `removeEntityOnNextUpdate(_:)`.
    ///
    /// - NOTE: ❕ Removing an entity from a scene **does not** remove all components from the entity. i.e. the entity is **not** explicitly destroyed and its components may not receive the `willRemoveFromEntity()` call.
    ///
    /// - Returns: `true` if the entry was in the `entities` set and removed.
    @inlinable @discardableResult
    func removeEntity(_ entityToRemove: GKEntity) -> Bool {
        
        guard entities.contains(entityToRemove) else {
            // CHECK: Warn on missing entry if the entity is going to leave anyway?
            // OKLog.logForWarnings.debug("\(entity) is not registered with \(self)")
            return false
        }
        
        // Unregister the entity's components from systems first.
        componentSystems.removeComponents(foundIn: entityToRemove)
        
        // Remove the entity's `NodeComponent` node, if any, from the scene.
        
        if  let nodeToRemove = entityToRemove.node,
            (self as? SKNode)?.children.contains(nodeToRemove) ?? false // If the entity container is not an `SKNode` descendant, then let the entity's node remain in its parent. CHECK: Is this intuitive? PERFORMANCE: Any impact from casting?
        {
            // CHECK: Does `self.children` only include top-level nodes or the entire node tree? Removing only top-level nodes would be the desirable behavior, and removing the entire tree may be unnecessary and inefficient (especially if complex node sub-hierarchies may have to be rebuilt later.)
            
            nodeToRemove.removeFromParent()
        }
        
        if  let entityToRemove = entityToRemove as? OKEntity { // Perform the tasks that only apply to `OKEntity`.
            
            // Remove all components from the entity if needed, so they can properly dispose of their behavior, e.g. removing a SpriteKit node from the scene, or terminating background processing.
            // CHECKED: Not removing all components from every entity does NOT prevent the scene from deinit'ing.
            /// ⚠️ NOTE: Do *not* remove components from entities that are not owned by this scene! e.g., the global `OKGameCoordinator` entity.
            if  entityToRemove.removeAllComponentsWhenRemovedFromScene {
                entityToRemove.removeAllComponents()
            }
            
            // Clear the entity's delegate.
            // CHECK: Should this step be skipped if this scene is not the delegate?
            entityToRemove.delegate = nil
        }
        
        // NOTE: Remove the entity after components have been removed, to avoid the "entity is not registered with scene" warnings and reduce the potential for other unexpected behavior.
        
        if  entities.remove(entityToRemove) != nil {
            OKLog.logForComponents.debug("Removed \(entityToRemove.debugDescription), entities.count = \(entities.count)")
            return true
        } else {
            return false
        }
    }
    
    /// Removes all entries that match the specified name.
    /// - Returns: The number of entities that were removed.
    @inlinable @discardableResult
    func removeEntities(named name: String) -> Int {
        
        var removalCount = 0
        
        // Create a separate array so we don't modify the `entities` property while iterating through it.
        
        let entitiesToRemove = self.entities(withName: name)
            .filter { $0.name == name }
        
        for entity in entitiesToRemove { // May be better than `forEach`, considering the `removalCount` mutation.
            if self.removeEntityOnNextUpdate(entity) { removalCount += 1 }
        }
        
        return removalCount
    }
    
    // MARK: Validating Entities
    
    /// Checks whether this entity container (e.g. scene) has the relevant component systems for all the entity's components that are marked as `RequiresUpdatesPerFrame` or `TurnBased`, and warns about any missing systems.
    ///
    /// Components without a system will not have their per-frame or per-turn logic executed automatically, resulting in incorrect or unexpected game behavior.
    @inlinable
    func checkSystemsAvailability(for entity: GKEntity) {
        
        for component in entity.components
            where component is RequiresUpdatesPerFrame
               || component is TurnBased
        {
            self.checkSystemAvailability(for: type(of: component), in: entity)
        }
    }
    
    /// Checks whether this entity container (e.g. scene) has a component system for the specified component class, and warns if the system is missing for a component that is marked as `RequiresUpdatesPerFrame` or `TurnBased`.
    ///
    /// Components without a system will not have their per-frame or per-turn logic executed automatically, resulting in incorrect or unexpected game behavior.
    ///
    /// - Note: This method should be called only for components that conform to `RequiresUpdatesPerFrame` or `TurnBased`, as it does not make sense to have systems for components which do not need to be updated.
    @inlinable @discardableResult
    func checkSystemAvailability <ComponentType> (for componentClass: ComponentType.Type,
                                                  in entity: GKEntity) -> Bool
        where ComponentType: GKComponent
    {
        // CHECK: PERFORMANCE: Should this be generic?
        
        let found = self.componentSystems.contains {
            $0.componentClass == componentClass
        }
        
        if  found {
            return true
        } else {
            
            if componentClass is RequiresUpdatesPerFrame.Type
            || componentClass is TurnBased.Type
            {
                OKLog.logForWarnings.debug("\(self) missing component system for \(componentClass) in \(entity)")
            }
            
            return false
        }
    }
    
    // MARK: - Frame Update
    
    /// Updates each of the component systems in the order they're listed in the specified array. If no `systemsCollection` is specified, then the scene's `componentSystems` property is used.
    ///
    /// A deterministic order of systems in the component systems array ensures that all components get updated after the other components they depend on.
    @inlinable
    func updateSystems(in systemsCollection: [OKComponentSystem]? = nil,
                       deltaTime seconds:    TimeInterval)
    {
        let systemsCollection = systemsCollection ?? self.componentSystems
        
        for componentSystem in systemsCollection {
            componentSystem.update(deltaTime: seconds)
        }
    }
    
}

// MARK: - Node-based Container

public extension OKEntityContainerNode {
    
    /// Searches the scene for a child node matching the specified name, and creates a new entity associated with it, adding any specified components, and adds the entity to the scene unless choosing not to.
    ///
    /// If more than one child node shares the same name, the first node discovered is used. The entity's name will be set to the node's name.
    ///
    /// Useful for loading scenes and reference nodes built in the Xcode Scene Editor.
    ///
    /// - NOTE: A `NodeComponent` is automatically added to the entity.
    ///
    /// - NOTE: If the node is already associated with an existing entity, it will be re-associated with the new entity.
    ///
    /// - NOTE: For processing multiple entities that share the same name, use `for node in scene[name]`
    ///
    /// - Parameter name: The name to search for. This may be either the literal name of the node or a customized search string. See [Searching the Node Tree](apple-reference-documentation://hsY9-_wZau) in Apple documentation.
    @inlinable
    @discardableResult func createEntityFromChildNode(
        withName name: String,
        addingComponents components: [GKComponent]? = nil,
        addEntityToScene: Bool = true)
        -> OKEntity?
    {
        // ℹ️ There is no multiple entity version of this method, as the `components` parameter would cause the SAME components to be added to each entity (because they're reference types), leaving them in effect on only the last entity to be created!
        
        guard let node = self.childNode(withName: name) else {
            OKLog.logForWarnings.debug("No node with name \"\(name)\" in \(self)")
            return nil
        }
        
        let newEntity = OKEntity(name: node.name, node: node) // ❕ Set the name to the node's name instead of the search string. :)
        
        if  let components = components {
            newEntity.addComponents(components)
        }
        
        if  addEntityToScene {
            self.addEntity(newEntity)
        }
        
        return newEntity
    }
    
    /// Adds an `entity`'s `NodeComponent` or `GKSKNodeComponent` node to the scene if that node does not currently have a parent.
    ///
    /// This is useful in cases like spawning sub-entities from a master/parent entity without explicitly specifying the scene.
    ///
    /// - WARNING: Subclasses of `NodeComponent` or `GKSKNodeComponent` will **not** be added, because component access at runtime looks for specific classes.
    @inlinable
    func addChildFromOrphanNodeComponent(in entity: GKEntity) {
        
        guard
            let node = entity.node, // ⚠️ Either `NodeComponent` or `GKSKNodeComponent` (in case the Scene Editor was used) but NOT their subclasses! See the warning in the method documentation above.
            node != self // Tricky pitfall to avoid there! "A Node can't parent itself" :P
            else { return }
        
        guard node.parent == nil else {
            // Warn if this node's parent is not in the scene.
            if  node.parent! != self,
               !node.inParentHierarchy(self)
            {
                OKLog.logForWarnings.debug("\(node) has parent \(node.parent) that is not in scene \(self)")
            }
            return
        }
        
        // TODO: Validate 'physicsBody'
        // ⚠️ Before adding the node, handle cases like the node's 'physicsBody' already belong to some other child of this scene, etc. Apparently this does not seem very easy to achieve in SpriteKit and Swift as of 2018-03.
        
        if  let physicsBody = node.physicsBody,
            physicsBody.node != nil && physicsBody.node! != node
        {
            // ⚠️ NOTE: Apparently this will never occur as SpriteKit replaces `physicsBody.node` when the `physicsBody` is added to a new node.
            OKLog.logForErrors.debug("\(node) has a \(physicsBody) that belongs to another node! — \(physicsBody.node!)")
            return
        }
        
        OKLog.logForDebug.debug("\(self) ← \(node)")
        self.addChild(node)
    }
}

// MARK: - OKEntityDelegate Conformance

extension OKEntityDelegate where Self: OKEntityContainer {
    
    /// Registers the new component with the scene's component systems, and if the component was a `NodeComponent` or `GKSKNodeComponent`, adds the node to the scene if the node does not already have a parent.
    /// This assists in cases such as dynamically adding a `NodeComponent` or `GKSKNodeComponent` without knowing which scene or parent to add the node to.
    @inlinable
    public func entity(_ entity: GKEntity, didAddComponent component: GKComponent) {
        guard entities.contains(entity) else {
            OKLog.logForWarnings.debug("\(entity) is not registered with \(self)")
            return
        }
        
        /// Warn about missing systems if the component is `RequiresUpdatesPerFrame` or `TurnBased`
        
        if component is RequiresUpdatesPerFrame
        || component is TurnBased
        {
            let octopusEntity = entity as? OKEntity
            
            if !(octopusEntity?.suppressSystemsAvailabilityCheck ?? false) { // A flag for improving performance by skipping this check for frequently-added entities.
                self.checkSystemAvailability(for: type(of: component), in: entity)
            }
        }
        
        // Register the new component into our systems.
        
        for componentSystem in self.componentSystems {
            if  componentSystem.componentClass == type(of: component) {
                componentSystem.addComponent(component)
            }
        }
        
        /// If the component was a `NodeComponent` or `GKSKNodeComponent` with an orphan node, adopt that node into this scene.
        
        if  component is NodeComponent || component is GKSKNodeComponent {
            (self as? OKEntityContainerNode)?.addChildFromOrphanNodeComponent(in: entity) // CHECK: PERFORMANCE: Any impact from casting?
        }
    }
    
    @inlinable
    public func entity(_ entity: GKEntity, willRemoveComponent component: GKComponent) {
        guard entities.contains(entity) else {
            OKLog.logForWarnings.debug("\(entity) is not registered with \(self)")
            return
        }
        
        for componentSystem in self.componentSystems {
            if  componentSystem.componentClass == type(of: component) {
                #if LOGECSVERBOSE
                OKLog.logForComponents.debug("Removing \(component) from \(componentSystem)")
                #endif
                componentSystem.removeComponent(component)
            }
        }
    }
    
    /// If the entity that sends this event is in the scene's `entities` array, add the newly-spawned entity to the array, and register its components to the default list of systems.
    /// - Returns: `true` if the entity was accepted and added to the scene. `false` if the entity was rejected or otherwise could not be added to the scene.
    @inlinable
    @discardableResult public func entity(_ entity: GKEntity, didSpawn spawnedEntity: GKEntity) -> Bool {
        guard entities.contains(entity) else {
            OKLog.logForWarnings.debug("\(entity) is not registered with \(self)")
            return false
        }
        
        addEntity(spawnedEntity)
        // componentSystems.addComponents(foundIn: spawnedEntity) // NOTE: Not needed here because it should be done in addEntity(_:), for example in case addEntity(_:) cannot or chooses not to add the entity.
        return true
    }
    
    @inlinable
    public func entityDidRequestRemoval(_ entity: GKEntity) {
        // OctopusKit.logForComponents("\(entity)") // Already logging in `removeEntityOnNextUpdate(_:)`
        removeEntityOnNextUpdate(entity)
    }
}
