//
//  OctopusEntityContainer.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/08.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// A protocol for sharing common code between `OctopusScene` and `OctopusSubscene` (or other types which manage entities) via Default Implementation Extensions.
public protocol OctopusEntityContainer: class {
    
    // CHECK: Extract `createEntityFromChildNode(...)` and `addChildFromOrphanSpriteKitComponent(...)` out to an SKNode-specific protocol?
    
    var entities: Set<GKEntity> { get set }
    var entitiesToRemoveOnNextUpdate: Set<GKEntity> { get set }
    var componentSystems: [OctopusComponentSystem] { get set }
    
    // MARK: Entities & Components
    
    func addEntity(_ entity: GKEntity)
    func addEntities(_ entities: [GKEntity])
    
    func addAllComponentsFromAllEntities(to systemsCollection: [OctopusComponentSystem]?)
    
    func entities(withName name: String) -> [OctopusEntity]?
    func renameUnnamedEntitiesToNodeNames()
    
    @discardableResult func removeEntityOnNextUpdate(_ entityToRemove: GKEntity) -> Bool
    @discardableResult func removeEntity(_ entityToRemove: GKEntity) -> Bool
    
    // MARK: Frame Update
    
    func updateSystems(in systemsCollection: [OctopusComponentSystem]?, deltaTime seconds: TimeInterval)
}

/// A protocol for sharing common code between `OctopusScene` and `OctopusSubscene` (or other types which manage entities and nodes) via Default Implementation Extensions.
public protocol OctopusEntityContainerNode: OctopusEntityContainer where Self: SKNode {
    
    @discardableResult func createEntityFromChildNode(
        withName name: String,
        addingComponents components: [GKComponent]?,
        addEntityToScene: Bool)
        -> OctopusEntity?
    
    func addChildFromOrphanSpriteKitComponent(in entity: GKEntity)
}

// MARK: - Default Implementation

public extension OctopusEntityContainer {
    
    // MARK: Entities & Components
    
    /// Adds an entity to the `entities` set, disallowing duplicate entities, and registers its components with the relevant systems.
    ///
    /// If the entity is an `OctopusEntity`, this scene is set as its delegate.
    func addEntity(_ entity: GKEntity) {
        
        guard entities.insert(entity).inserted else {
            OctopusKit.logForWarnings.add("\(entity) is already in \(self) — Not re-adding")
            return
        }
        
        OctopusKit.logForComponents.add("\(entity.debugDescription), entities.count = \(entities.count)")
        
        // If it's an `OctopusEntity` (as opposed to a basic `GKEntity`) set this scene as its delegate.
        
        if let octopusEntity = entity as? OctopusEntity {
            octopusEntity.delegate = self as? OctopusEntityDelegate // CHECK: Is this casting i
        }
        
        // If the entity has as `SpriteKitComponent` or `GKSKNodeComponent` whose node does not belong to any parent, add that node to this scene.
        
        // ℹ️ This lets `OctopusEntityDelegate` methods spawn new visual entities without explicitly specifying the scene, and also lets us conveniently add new entities by simply writing `self.addEntity(OctopusEntity(components: [SpriteKitComponent(node: someSprite)]))`
        
        (self as? OctopusEntityContainerNode)?.addChildFromOrphanSpriteKitComponent(in: entity) // CHECK: PERFORMANCE: Any Impact from casting?
        
        // In case the entity added components to itself before its `OctopusEntityDelegate` was set (which ensures that new components are automatically registered with the scene's component systems), add the entity's components to this scene's systems now to make sure we don't miss any.
        
        self.componentSystems.addComponents(foundIn: entity)
        
        // CHECK: Should we issue a warning if the entity has any components that must be updated every frame to perform their function, but this scene does not have any component systems for them? Or would it hurt performance to do such checks every time an entity is added?
        
    }
    
    /// Adds multiple entities to the `entities` set in the order they are listed in the specified array, disallowing duplicate entities, and registers their components with the relevant systems.
    ///
    /// If an entity is an `OctopusEntity`, this scene is set as its delegate.
    func addEntities(_ entities: [GKEntity]) {
        for entity in entities {
            self.addEntity(entity)
        }
    }
    
    /// Attempts to add all of the components from all entities in the scene, to all of the systems in the specified array that match the types of the components.
    ///
    /// If no `systemsCollection` is specified, then `componentSystems` is used.
    func addAllComponentsFromAllEntities(to systemsCollection: [OctopusComponentSystem]? = nil) {
        
        let systemsCollection = systemsCollection ?? self.componentSystems
        
        OctopusKit.logForFramework.add("systemsCollection = \(systemsCollection)")
        
        for entity in entities {
            systemsCollection.addComponents(foundIn: entity)
        }
    }
    
    /// Returns an array of `OctopusEntity`s containing all the entities matching `name`, or `nil` if none were found.
    func entities(withName name: String) -> [OctopusEntity]? {
        
        let filteredSet = entities.filter {
            
            if let entity = $0 as? OctopusEntity {
                return entity.name == name
            }
            else {
                return false
            }
        }
        
        if
            let filteredArray = Array(filteredSet) as? [OctopusEntity],
            !filteredArray.isEmpty
        {
            return filteredArray
        }
        else {
            return nil
        }
    }
    
    /// Sets the names of all unnamed entities to the name of their `SpriteKitComponent` or `GKSKNodeComponent` nodes.
    func renameUnnamedEntitiesToNodeNames() {
        for case let entity as (OctopusEntity & Nameable) in entities {
            if
                let node = entity.node,
                entity.name == nil
            {
                entity.name = node.name
            }
        }
    }
    
    /// Marks an entity for removal in the next frame, at the beginning of the next call to `update(_:)`.
    ///
    /// - Returns: `true` if the entry was in the `entities` set.
    ///
    /// This ensures that the list of entities is not mutated during a frame update, which would cause an exception/crash because of mutating a collection while it is being enumerated during the update
    @discardableResult func removeEntityOnNextUpdate(_ entityToRemove: GKEntity) -> Bool {
        
        guard entities.contains(entityToRemove) else {
            // CHECK: Warn on missing entry if the entity is going to leave anyway?
            // OctopusKit.logForWarnings.add("\(entity) is not registered with \(self)")
            return false
        }
        
        OctopusKit.logForComponents.add("\(entityToRemove.debugDescription)")
        
        // ℹ️ `entitiesToRemoveOnNextUpdate` is a `Set` which prevents duplicate values.
        
        entitiesToRemoveOnNextUpdate.insert(entityToRemove)
        return true
    }
    
    /// Removes an entity from the scene, and unregisters its components from the default component systems array.
    ///
    /// - Returns: `true` if the entry was in the `entities` set and removed.
    ///
    /// - Important: Attempting to modify the list of entities during a frame update will cause an exception/crash, because of mutating a collection while it is being enumerated. To ensure safe removal, use `removeEntityOnNextUpdate(_:)`.
    @discardableResult func removeEntity(_ entityToRemove: GKEntity) -> Bool {
        
        guard entities.contains(entityToRemove) else {
            // CHECK: Warn on missing entry if the entity is going to leave anyway?
            // OctopusKit.logForWarnings.add("\(entity) is not registered with \(self)")
            return false
        }
        
        // Unregister the entity's components from systems first.
        componentSystems.removeComponents(foundIn: entityToRemove)
        
        // Remove the entity's `SpriteKitComponent` node, if any, from the scene.
        
        if  let nodeToRemove = entityToRemove.node,
            (self as? SKNode)?.children.contains(nodeToRemove) ?? false // If the entity container is not an `SKNode` descendant, then let the entity's node remain in its parent. CHECK: Is this intuitive? PERFORMANCE: Any impact from casting?
        {
            // CHECK: Does `self.children` only include top-level nodes or the entire node tree? Removing only top-level nodes would be the desirable behavior, and removing the entire tree may be unncessary and inefficient (especially if complex node sub-heirarchies may have to be rebuilt later.)
            
            nodeToRemove.removeFromParent()
        }
        
        // CHECK: Should we remove all components from the entity so they can properly dispose of their behavior? e.g. removing a SpriteKit node from the scene.
        // CHECKED: Not removing all components from every entity does NOT prevent the scene from deinit'ing.
        // ⚠️ NOTE: Do not remove components from entities that are not owned by this scene! e.g., the global GameController entity.
        // entityToRemove.removeAllComponents()
        
        // Clear the entity's delegate.
        // CHECK: Should this step be skipped if this scene is not the delegate?
        (entityToRemove as? OctopusEntity)?.delegate = nil
        
        // NOTE: Remove the entity after components have been removed, to avoid the "entity is not registered with scene" warnings and reduce the potential for other unexpected behavior.
        
        if entities.remove(entityToRemove) != nil {
            OctopusKit.logForComponents.add("Removed \(entityToRemove.debugDescription), entities.count = \(entities.count)")
            return true
        }
        else {
            return false
        }
        
    }
    
    // MARK: Frame Update
    
    /// Updates each of the component systems in the order they're listed in the specified array. If no `systemsCollection` is specified, then the scene's `componentSystems` property is used.
    ///
    /// A deterministic order of systems in the component systems array ensures that all components get updated after the other components they depend on.
    func updateSystems(in systemsCollection: [OctopusComponentSystem]? = nil, deltaTime seconds: TimeInterval) {

        let systemsCollection = systemsCollection ?? self.componentSystems

        for componentSystem in systemsCollection {
            componentSystem.update(deltaTime: seconds)
        }
    }
    
}

// MARK: Node-based Container

public extension OctopusEntityContainerNode {
    
    /// Searches the scene for a child node matching the specified name, and creates a new entity associated with it, adding any specified components, and adds the entity to the scene unless choosing not to.
    ///
    /// If more than one child node shares the same name, the first node discovered is used. The entity's name will be set to the node's name.
    ///
    /// Useful for loading scenes and reference nodes built in the Xcode Scene Editor.
    ///
    /// - NOTE: A `SpriteKitComponent` is automatically added to the entity.
    ///
    /// - NOTE: If the node is already associated with an existing entity, it will be re-associated with the new entity.
    ///
    /// - NOTE: For processing multiple entities that share the same name, use `for node in scene[name]`
    ///
    /// - Parameter name: The name to search for. This may be either the literal name of the node or a customized search string. See [Searching the Node Tree](apple-reference-documentation://hsY9-_wZau) in Apple documentation.
    @discardableResult func createEntityFromChildNode(
        withName name: String,
        addingComponents components: [GKComponent]? = nil,
        addEntityToScene: Bool = true)
        -> OctopusEntity?
    {
        // ℹ️ There is no multiple entity version of this method, as the `components` parameter would cause the SAME components to be added to each entity (because they're reference types), leaving them in effect on only the last entity to be created!
        
        guard let node = self.childNode(withName: name) else {
            OctopusKit.logForWarnings.add("No node with name \"\(name)\" in \(self)")
            return nil
        }
        
        let newEntity = OctopusEntity(name: node.name, node: node) // ⚠️ Set the name to the node's name instead of the search string. :)
        
        if let components = components {
            newEntity.addComponents(components)
        }
        
        if addEntityToScene {
            self.addEntity(newEntity)
        }
        
        return newEntity
    }
    
    /// Adds an `entity`'s `SpriteKitComponent` or `GKSKNodeComponent` node to the scene if that node does not currently have a parent.
    ///
    /// This is useful in cases like spawning sub-entities from a master/parent entity without explicitly specifying the scene.
    func addChildFromOrphanSpriteKitComponent(in entity: GKEntity) {
        guard
            let node = entity.node, // Either `SpriteKitComponent` or `GKSKNodeComponent` (in case the Scene Editor was used)
            node != self, // Tricky pitfall to avoid there! "A Node can't parent itself" :P
            node.parent == nil
            else { return }
        
        // TODO: Validate 'physicsBody'
        // ⚠️ Before adding the node, handle cases like the node's 'physicsBody' already belong to some other child of this scene, etc. Apparently this does not seem very easy to achieve in SpriteKit and Swift as of 2018-03.
        
        if
            let physicsBody = node.physicsBody,
            physicsBody.node != nil && physicsBody.node! != node
        {
            // ⚠️ NOTE: Apparently this will never occur as SpriteKit replaces `physicsBody.node` when the `physicsBody` is added to a new node.
            OctopusKit.logForErrors.add("\(node) has a \(physicsBody) that belongs to another node! — \(physicsBody.node!)")
            return
        }
        
        OctopusKit.logForDebug.add("\(self) ← \(node)")
        self.addChild(node)
    }
}

// MARK: - OctopusEntityDelegate Conformance

extension OctopusEntityDelegate where Self: OctopusEntityContainer {
    
    /// Registers the new component with the scene's component systems, and if the component was a `SpriteKitComponent` or `GKSKNodeComponent`, adds the node to the scene if the node does not already have a parent.
    /// This assists in cases such as dynamically adding a `SpriteKitComponent` or `GKSKNodeComponent` without knowing which scene or parent to add the node to.
    public func entity(_ entity: GKEntity, didAddComponent component: GKComponent) {
        guard entities.contains(entity) else {
            OctopusKit.logForWarnings.add("\(entity) is not registered with \(self)")
            return
        }
        
        /// Register the component into our systems.
        
        for componentSystem in self.componentSystems {
            if componentSystem.componentClass == type(of: component) {
                componentSystem.addComponent(component)
            }
        }
        
        // If the component was a `SpriteKitComponent` or `GKSKNodeComponent` with an orphan node, adopt that node into this scene.
        
        if component is SpriteKitComponent || component is GKSKNodeComponent {
           (self as? OctopusEntityContainerNode)?.addChildFromOrphanSpriteKitComponent(in: entity) // CHECK: PERFORMANCE: Any impact from casting?
        }
        
    }
    
    public func entity(_ entity: GKEntity, willRemoveComponent component: GKComponent) {
        guard entities.contains(entity) else {
            OctopusKit.logForWarnings.add("\(entity) is not registered with \(self)")
            return
        }
        
        for componentSystem in self.componentSystems {
            if componentSystem.componentClass == type(of: component) {
                componentSystem.removeComponent(component)
            }
        }
    }
    
    /// If the entity that sends this event is in the scene's `entities` array, add the newly-spawned entity to the array, and register its components to the default list of systems.
    /// - Returns: `true` if the entity was accepted and added to the scene. `false` if the entity was rejected or otherwise could not be added to the scene.
    @discardableResult public func entity(_ entity: GKEntity, didSpawn spawnedEntity: GKEntity) -> Bool {
        guard entities.contains(entity) else {
            OctopusKit.logForWarnings.add("\(entity) is not registered with \(self)")
            return false
        }
        
        addEntity(spawnedEntity)
        // componentSystems.addComponents(foundIn: spawnedEntity) // NOTE: Not needed here because it should be done in addEntity(_:), for example in case addEntity(_:) cannot or chooses not to add the entity.
        return true
    }
    
    public func entityDidRequestRemoval(_ entity: GKEntity) {
        // OctopusKit.logForComponents.add("\(entity)") // Already logging in `removeEntityOnNextUpdate(_:)`
        removeEntityOnNextUpdate(entity)
    }
}
