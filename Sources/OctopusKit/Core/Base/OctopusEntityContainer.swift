//
//  OctopusEntityContainer.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/08.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// A placeholder protocol for sharing common code between `OctopusScene` and `OctopusSubscene` via an Extension. Currently cannot be elegantly implemented because of the limitations and issues with Default Implementations and inheritance. 2018-05-08
public protocol OctopusEntityContainer: class {
    
    var entities: Set<GKEntity> { get }
    var entitiesToRemoveOnNextUpdate: Set<GKEntity> { get set }
    var componentSystems: [OctopusComponentSystem] { get }
    
    func addEntity(_ entity: GKEntity)
    func addEntities(_ entities: [GKEntity])
    
    func addAllComponentsFromAllEntities(to systemsCollection: [OctopusComponentSystem]?)
    func addChildFromOrphanSpriteKitComponent(in entity: GKEntity)
    
    func entities(withName name: String) -> [OctopusEntity]?
    func renameUnnamedEntitiesToNodeNames()
    
    func removeEntityOnNextUpdate(_ entityToRemove: GKEntity) -> Bool
    func removeEntity(_ entityToRemove: GKEntity) -> Bool
    
}

extension OctopusEntityContainer where Self: OctopusScene {
    
    // TODO: Implement
    // CHECK: Test and verify calls to `super` and other functionality in subclasses of `OctopusScene`.
    
}
