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
    
    // DESIGN: The `entities` property was supposed to be read-only with `fileprivate(set)`, but has to be made public so that the default implementation extension for the `OctopusEntityContainer` (which is necessary to avoid duplicating code between `OctopusScene` and `OctopusSubscene`) can modify it.
    
    public lazy var entities = Set<GKEntity>()
    
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
    
    // Most of the entity management code is provided in the default implementation extensions of the `OctopusEntityContainer` protocol.
    
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
