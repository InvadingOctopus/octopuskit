//
//  OctopusSubscene.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/08.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Should subscenes have their own input subsystem? Wouldn't it be more efficient to give a subscene the `TouchEventComponent` of the parent scene, to update in the subscene's component systems?

import SpriteKit
import GameplayKit

/// A protocol for types that display an `OctopusSubscene`.
public protocol OctopusSubsceneDelegate: class {
    func subsceneWillAppear(_ subscene: OctopusSubscene, on parentNode: SKNode)
    func subsceneDidFinish(_ subscene: OctopusSubscene, withResult result: OctopusSubsceneResultType?)
}

/// A list of possible results produced by the player's interaction with a subscene.
public enum OctopusSubsceneResultType {
    /// A result
    case yes
    case no
    case cancelled
    case success
    case failure
    
    case finishScene
    case nextGameState
    case previousGameState
    
    case showSubsceneClass(OctopusSubscene.Type)
    
    case data(Any)
}

/// Base class for special nodes that may contain entities and component subsystems of their own, to implement self-contained "pseudoscenes" inside the parent scene, such as paused-state overlays, modal dialogs, cutscenes or minigames.
public class OctopusSubscene: SKNode,
    OctopusEntityContainer,
    OctopusEntityDelegate,
    TouchEventComponentCompatible
{
    
    // ℹ️ NOTE: This class currently contains a lot of duplicate code from `OctopusScene`. The `OctopusEntityContainer` protocol is meant to reduce code duplication in the future but cannot be elegantly implemented currently because of the issues associated with Default Implementations (via Extensions) and inheritance. 2018-05-08
    
    // MARK: - Properties
    
    public fileprivate(set) lazy var entities = Set<GKEntity>()
    
    /// Used for deferring the removal of entities, since modifying the list of entities during a frame update may cause an exception/crash, because of mutating the entities collection while it is being enumerated during the update.
    ///
    /// Since this is a `Set`, it prevents entities from being added more than once.
    public var entitiesToRemoveOnNextUpdate = Set<GKEntity>()
    
    /// The primary array of component systems for this scene. Determines the order in which components of all entities must be updated every frame.
    ///
    /// Component systems are in an `Array` instead of a `Set` because a deterministic order of updates is important for proper game functionality. Further arrays may be created by subclass if more groupings of related systems are required. The `Array+OctopusComponentSystem` extension contains helper methods to assist with managing arrays of systems.
    ///
    /// - Important: `OctopusScene` does not update component systems by default, as each game may have its specific logic for updating systems in relation to the paused/unpaused state, etc.
    ///
    /// - Important: The `OctopusScene` subclass must call `updateSystems(in:deltaTime:)` at some point in the `update(_ currentTime: TimeInterval)` method, usually after handling pause/unpause logic.
    ///
    /// - Important: Adding a system does not automatically register the components from any of the scene's existing entities. Call either `self.componentSystems.addComponents(foundIn:)` to register components from a single entity, or `addAllComponentsFromAllEntities(to:)` to register components from all entities.
    public lazy var componentSystems = [OctopusComponentSystem]()
    
    /// Set to `true` after `createContents()` is called.
    public fileprivate(set) var didCreateContents = false
    
    public weak var delegate: OctopusSubsceneDelegate?
    
    // MARK: - Life Cycle
    
    public required init(name: String = "Subscene") {
        
        super.init()
        
        self.name = name
        
        // Create an entity to represent the primary node itself.
        
        let subsceneEntity = OctopusEntity(name: self.name, node: self) // NOTE: `node: self` adds a `SpriteKitComponent`.
        self.entity = subsceneEntity
        addEntity(subsceneEntity)
        
        // Enable user-interaction so that the node can directly handle touch input.
        
        self.isUserInteractionEnabled = true
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    /// Abstract method that subclasses can override to prepare their contents for the parent node that the subscene will be presented in.
    ///
    /// - Important: The overriding implementation must call `createContents(for: parentNode)` for `OctopusSubscene` to notify the delegate.
    public func createContents(for parent: SKNode) {
        OctopusKit.logForFramework.add()
        delegate?.subsceneWillAppear(self, on: parent)
        didCreateContents = true
    }
    
    // MARK: - Entities & Components
    
    /// Adds an entity to the `entities` set, disallowing duplicate entities, and registers its components with the relevant systems.
    ///
    /// If the entity is an `OctopusEntity`, this scene is set as its delegate.
    public func addEntity(_ entity: GKEntity) {
        
        guard entities.insert(entity).inserted else {
            OctopusKit.logForWarnings.add("\(entity) is already in \(self) — Not re-adding")
            return
        }
        
        OctopusKit.logForComponents.add("\(entity.debugDescription), entities.count = \(entities.count)")
        
        // If it's an `OctopusEntity` (as opposed to a basic `GKEntity`) set this scene as its delegate.
        
        if let octopusEntity = entity as? OctopusEntity {
            octopusEntity.delegate = self
        }
        
        // If the entity has as `SpriteKitComponent` or `GKSKNodeComponent` whose node does not belong to any parent, add that node to this scene.
        
        // ℹ️ This lets `OctopusEntityDelegate` methods spawn new visual entities without explicitly specifying the scene, and also lets us conveniently add new entities by simply writing `self.addEntity(OctopusEntity(components: [SpriteKitComponent(node: someSprite)]))`
        
        addChildFromOrphanSpriteKitComponent(in: entity)
        
        // In case the entity added components to itself before its `OctopusEntityDelegate` was set (which ensures that new components are automatically registered with the scene's component systems), add the entity's components to this scene's systems now to make sure we don't miss any.
        
        self.componentSystems.addComponents(foundIn: entity)
        
        // CHECK: Should we issue a warning if the entity has any components that must be updated every frame to perform their function, but this scene does not have any component systems for them? Or would it hurt performance to do such checks every time an entity is added?
        
    }
    
    /// Adds multiple entities to the `entities` set in the order they are listed in the specified array, disallowing duplicate entities, and registers their components with the relevant systems.
    ///
    /// If an entity is an `OctopusEntity`, this scene is set as its delegate.
    public func addEntities(_ entities: [GKEntity]) {
        for entity in entities {
            self.addEntity(entity)
        }
    }
    
    /// Searches the scene for a child node matching the specified name, and creates a new entity associated with it, adding any specified components, and adds the entity to the scene unless disallowed.
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
    @discardableResult public func createEntityFromChildNode(
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
    
    /// Attempts to add all of the components from all entities in the scene, to all of the systems in the specified array that match the types of the components.
    ///
    /// If no `systemsCollection` is specified, then `componentSystems` is used.
    public func addAllComponentsFromAllEntities(to systemsCollection: [OctopusComponentSystem]? = nil) {
        
        let systemsCollection = systemsCollection ?? self.componentSystems
        
        OctopusKit.logForFramework.add("systemsCollection = \(systemsCollection)")
        
        for entity in entities {
            systemsCollection.addComponents(foundIn: entity)
        }
    }
    
    /// Adds an `entity`'s `SpriteKitComponent` or `GKSKNodeComponent` node to the scene if that node does not currently have a parent.
    ///
    /// This is useful in cases like spawning sub-entities from a master/parent entity without explicitly specifying the scene.
    public func addChildFromOrphanSpriteKitComponent(in entity: GKEntity) {
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
    
    /// Returns an array of `OctopusEntity`s containing all the entities matching `name`, or `nil` if none were found.
    public func entities(withName name: String) -> [OctopusEntity]? {
        
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
    public func renameUnnamedEntitiesToNodeNames() {
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
    @discardableResult public func removeEntityOnNextUpdate(_ entityToRemove: GKEntity) -> Bool {
        
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
    @discardableResult public func removeEntity(_ entityToRemove: GKEntity) -> Bool {
        
        guard entities.contains(entityToRemove) else {
            // CHECK: Warn on missing entry if the entity is going to leave anyway?
            // OctopusKit.logForWarnings.add("\(entity) is not registered with \(self)")
            return false
        }
        
        // Unregister the entity's components from systems first.
        componentSystems.removeComponents(foundIn: entityToRemove)
        
        // Remove all components from the entity so they can properly dispose of their behavior, e.g. removing a SpriteKit node from the scene.
        entityToRemove.removeAllComponents()
        
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
    
    // MARK: OctopusEntityDelegate
    
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
            addChildFromOrphanSpriteKitComponent(in: entity)
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
    
    // MARK: - Frame Update
    
    /// Performs any scene-specific updates that need to occur before scene actions are evaluated. This method is the point for updating components, preferably via component systems.
    ///
    /// - Important: `super.update(currentTime)` *must* be called for correct functionality (before any other code in most cases.)
    public func update(deltaTime seconds: TimeInterval) {
        
        // MARK: Entity Removal
        
        // First of all, if any entities were marked for removal since the last update, remove them now.
        // This delayed removal is done to avoid mutating the entities collection while it is being enumerated within the same frame update.
        
        for entityToRemove in entitiesToRemoveOnNextUpdate {
            removeEntity(entityToRemove)
        }
        
        entitiesToRemoveOnNextUpdate.removeAll()
        
        // MARK: Components Update
        
        // NOTE: The subclass's implementation must also handle the `isPaused` flag.
        
        guard !isPaused else { return }
        
        updateSystems(in: componentSystems, deltaTime: seconds)
        
    }
    
    /// Updates each of the component systems in the order they're listed in the specified array. If no `systemsCollection` is specified, then the scene's `componentSystems` property is used.
    ///
    /// A deterministic order of systems in the component systems array ensures that all components get updated after the other components they depend on.
    public func updateSystems(in systemsCollection: [OctopusComponentSystem]? = nil, deltaTime seconds: TimeInterval) {
        
        let systemsCollection = systemsCollection ?? self.componentSystems
        
        for componentSystem in systemsCollection {
            componentSystem.update(deltaTime: seconds)
        }
    }
    
    // MARK: - Player Input (iOS)
    
    #if os(iOS) // CHECK: Include tvOS?
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUT
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesBegan = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUT
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesMoved = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUT
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesCancelled = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        #if LOGINPUT
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesEnded = TouchEventComponent.TouchEvent(touches: touches, event: event, node: self)
        }
    }
    
    /// Relays touch-input events to the scene's `TouchEventComponent`.
    public override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        
        #if LOGINPUT
        debugLog()
        #endif
        
        if let inputComponent = self.entity?.componentOrRelay(ofType: TouchEventComponent.self) {
            inputComponent.touchesEstimatedPropertiesUpdated = TouchEventComponent.TouchEvent(touches: touches, event: nil, node: self)
        }
    }
    
    #endif
}
