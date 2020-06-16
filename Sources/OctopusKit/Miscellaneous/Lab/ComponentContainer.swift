//
//  ComponentContainer.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import GameplayKit

#if UseNewProtocols // ℹ️ Not currently in use; This is mostly preparation for future independence from GameplayKit, if needed.

public protocol ComponentContainer: class {
    
    // MARK: Properties
    
    var components: [Component]   { get }
    
    var state:      OKEntityState?  { get }
    var scene:      SKScene?        { get }
    var node:       SKNode?         { get }
    var sprite:     SKSpriteNode?   { get }
    var physicsBody: SKPhysicsBody? { get }
    
    @inlinable
    subscript <ComponentType> (componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: Component { get }

    var suppressSystemsAvailabilityCheck: Bool { get }
    
    // MARK: Life Cycle
        
//    init()
    
//    init(components: [Component])
    
//    init(name: String?,
//         components: [Component])
    
//    init(node: SKNode,
//         addToNode parentNode: SKNode?)
   
//    init(name: String?,
//         node: SKNode,
//         addToNode parentNode: SKNode?)
    
    // MARK: Component Management
    
    func addComponent (_ component:   Component)
    func addComponent (_ component:   Component?)

    func addComponents(_ components: [Component])
    func addComponents(_ components: [Component?])

    func removeComponent <ComponentType> (ofType componentClass: ComponentType.Type)
        where ComponentType: Component

    func removeComponents(ofTypes componentClasses: [Component.Type])
    func removeAllComponents()
    
    // MARK: Queries
    
    func component <ComponentType> (ofType componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: Component

    func componentOrRelay <ComponentType> (ofType componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType: Component
    
}

public extension ComponentContainer {

    // MARK: - Operators

    /// Adds a component to the entity.
    @inlinable
    static func += (container: Self, component: Component?) {
        container.addComponent(component)
    }

    /// Adds an array of components to the entity.
    @inlinable
    static func += (container: Self, components: [Component]) {
        container.addComponents(components)
    }

    /// Adds an array of components to the entity.
    @inlinable
    static func += (container: Self, components: [Component?]) {
        container.addComponents(components)
    }

    /// Removes the component of the specified type from the entity.
    @inlinable
    static func -= <ComponentType> (container: Self, componentClass: ComponentType.Type)
        where ComponentType: Component
    {
        container.removeComponent(ofType: componentClass)
    }

    /// Removes components of the specified types from the entity.
    @inlinable
    static func -= (container: Self, componentClasses: [Component.Type]) {
        container.removeComponents(ofTypes: componentClasses)
    }
}

#endif
