//
//  Component.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import GameplayKit

public protocol Component: class, UpdatablePerFrame {
    
    // ℹ️ Not currently in use; This is mostly preparation for future independence from GameplayKit, if needed.
    
    // MARK: Properties
    
    var entity:             Entity?             { get }
    var requiredComponents: [Component.Type]?   { get }
    
    var componentType:      Component.Type      { get }
    
//    var entityName:         String?             { get }
//    var entityNode:         SKNode?             { get }
//    var entityScene:        OKScene?            { get }
//    var entityPhysicsBody:  SKPhysicsBody?      { get }
//    var entityState:        OKEntityState?      { get }
//    var entityDelegate:     OKEntityDelegate?   { get }
    
    var shouldRemoveFromEntityOnDeinit:    Bool { get set }
    var shouldWarnIfDeinitWithoutRemoving: Bool { get set }
    var disableDependencyChecks:           Bool { get set }
    
    // MARK: Life Cycle
    
    init()
    
    func disableDependencyChecks(_ newValue: Bool)
    
    func didAddToEntity()
    func didAddToEntity(withNode node: SKNode)
    
    func removeFromEntity()
    
    func willRemoveFromEntity()
    func willRemoveFromEntity(withNode node: SKNode)
    
    // MARK: Queries

    func coComponent <ComponentType> (
        ofType componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool)
        -> ComponentType? where ComponentType: Component
    
    func coComponent <ComponentType> (
        _ componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool)
        -> ComponentType? where ComponentType: Component
    
    func checkEntityForRequiredComponents()
}
