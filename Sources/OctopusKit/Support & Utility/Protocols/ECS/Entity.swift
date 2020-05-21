//
//  Entity.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import GameplayKit

public protocol Entity:
    /// class, // Already on `ComponentContainer`
    Nameable,
    ComponentContainer,
    UpdatablePerFrame
{
    // ℹ️ Not currently in use; This is mostly preparation for future independence from GameplayKit, if needed.
    
    var delegate: OKEntityDelegate? { get }
    
    init()
    
}

public extension Entity {

    var delegate: OKEntityDelegate? { nil }
    
}

extension Entity where Self: Nameable {
    public var name: String? { nil }
}

/*
extension GKEntity: Entity {
    
    @inlinable
    public var components: [Component] {
        self.components as [Component]
    }
    
    @inlinable
    public func addComponent(_ component: Component) {
        self.addComponent(component)
    }
    
    @inlinable
    public func component<ComponentType>(ofType componentClass: ComponentType.Type) -> ComponentType?
        where ComponentType : Component
    {
        self.component(ofType: componentClass)
    }
    
    @inlinable
    public func removeComponent<ComponentType>(ofType componentClass: ComponentType.Type)
        where ComponentType : Component
    {
        self.removeComponent(ofType: componentClass)
    }
}
*/
