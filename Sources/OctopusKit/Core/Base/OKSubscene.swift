//
//  OKSubscene.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/08.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Should subscenes have their own input subsystem? Wouldn't it be more efficient to give a subscene the `TouchEventComponent` of the parent scene, to update in the subscene's component systems?

import SpriteKit
import GameplayKit

/// A protocol for types that display an `OKSubscene`.
public protocol OKSubsceneDelegate: AnyObject {
    func subsceneWillAppear (_ subscene: OKSubscene, on parentNode: SKNode)
    func subsceneDidFinish  (_ subscene: OKSubscene, withResult result: OKSubsceneResultType?)
}

/// A list of possible results produced by the player's interaction with a subscene.
public enum OKSubsceneResultType {
    
    case yes
    case no
    case cancelled
    case success
    case failure
    
    case finishScene
    case nextGameState
    case previousGameState
    
    case showSubsceneClass(OKSubscene.Type)
    
    case data(Any)
}

public typealias OctopusSubscene = OKSubscene

/// A base class for special nodes that may contain entities and component systems of their own, to implement self-contained "pseudoscenes" inside the parent scene, such as paused-state or inventory overlays, cutscenes or minigames.
open class OKSubscene: SKNode,
                       OKEntityContainerNode,
                       OKEntityDelegate
{
    
    // ℹ️ NOTE: This class currently contains a lot of duplicate code from `OKScene`. The `OKEntityContainer` protocol is meant to reduce code duplication in the future but cannot be elegantly implemented currently because of the issues associated with Default Implementations (via Extensions) and inheritance. 2018-05-08
    
    // MARK: - Properties
    
    // DESIGN: The `entities` property was supposed to be read-only with `fileprivate(set)`, but has to be made public so that the default implementation extension for the `OKEntityContainer` (which is necessary to avoid duplicating code between `OKScene` and `OKSubscene`) can modify it.
    
    public lazy var entities = Set<GKEntity>()
    
    /// Used for deferring the removal of entities, since modifying the list of entities during a frame update may cause an exception/crash, because of mutating the entities collection while it is being enumerated during the update.
    ///
    /// Since this is a `Set`, it prevents entities from being added more than once.
    public var entitiesToRemoveOnNextUpdate = Set<GKEntity>()
    
    /// The primary array of component systems for this scene. Determines the order in which components of all entities must be updated every frame.
    ///
    /// Component systems are in an `Array` instead of a `Set` because a deterministic order of updates is important for proper game functionality. Further arrays may be created by subclass if more groupings of related systems are required. The `Array+OKComponentSystem` extension contains helper methods to assist with managing arrays of systems.
    ///
    /// - Important: `OKScene` does not update component systems by default, as each game may have its specific logic for updating systems in relation to the paused/unpaused state, etc.
    ///
    /// - Important: The `OKScene` subclass must call `updateSystems(in:deltaTime:)` at some point in the `update(_ currentTime: TimeInterval)` method, usually after handling pause/unpause logic.
    ///
    /// - Important: Adding a system does not automatically register the components from any of the scene's existing entities. Call either `self.componentSystems.addComponents(foundIn:)` to register components from a single entity, or `addAllComponentsFromAllEntities(to:)` to register components from all entities.
    public lazy var componentSystems = [OKComponentSystem]()
    
    /// Set to `true` after `createContents()` is called.
    public fileprivate(set) var didCreateContents = false
    
    public weak var delegate: OKSubsceneDelegate?
    
    // MARK: - Life Cycle
    
    public required init(name: String = "Subscene") {
        
        super.init()
        
        self.name = name
        
        // Create an entity to represent the primary node itself.
        
        let subsceneEntity = OKEntity(name: self.name, node: self) // NOTE: `node: self` adds a `NodeComponent`.
        self.entity = subsceneEntity
        addEntity(subsceneEntity)
        
        // Enable user-interaction so that the node can directly handle touch input.
        
        self.isUserInteractionEnabled = true
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    /// Abstract method that subclasses can override to prepare their contents for the parent node that the subscene will be presented in.
    ///
    /// - Important: The overriding implementation must call `createContents(for: parentNode)` for `OKSubscene` to notify the delegate.
    open func createContents(for parent: SKNode) {
        OKLog.logForFramework.debug("\(📜())")
        delegate?.subsceneWillAppear(self, on: parent)
        didCreateContents = true
    }
    
    // MARK: - Entities & Components
    
    // Most of the entity management code as well as `OKEntityDelegate` conformance is provided by the default implementation extensions of the `OKEntityContainer` protocol.
    
    // MARK: - Frame Update
    
    /// Performs any scene-specific updates that need to occur before scene actions are evaluated. This method is the point for updating components, preferably via component systems.
    ///
    /// - Important: `super.update(currentTime)` *must* be called for correct functionality (before any other code in most cases.)
    open func update(deltaTime seconds: TimeInterval) {
        
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
    
}

