//
//  ClosureComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/06.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Executes the supplied closures once, when this component is added to an entity and when this component is removed from an entity.
///
/// This component calls the closures with a reference to `self`, so that the component's user can refer to the instance properties of this component, such as its entity or co-components, at the calling site before it has finished initialization.
///
/// **Example**
///
///     ClosureComponent(whenAdded:   { $0.entityNode?.setScale(2.0) },
///                      whenRemoved: { $0.entityNode?.setScale(1.0) })
///
public final class ClosureComponent: SingleUseComponent {
    
    // CHECK: Add an execution delay?
    
    /// The block of code to be executed by a `ClosureComponent`.
    ///
    /// - Parameter component: A reference to `self`; the instance of `ClosureComponent` that this closure will be a property of.
    ///
    ///     You can use this to access the instance properties of this component, such as its associated entity and co-components.
    ///
    ///     **Example:** `component.coComponent(ofType: SpriteKitComponent.self)?.node`
    public typealias ClosureType = (_ component: ClosureComponent) -> Void
    
    /// The block of code to execute when this component is added to an entity.
    ///
    /// For a description of the closure's signature and parameters, see `ClosureComponent.ClosureType`.
    public var closureOnAddingToEntity: ClosureType?
    
    /// The block of code to execute when this component is removed from an entity.
    ///
    /// The component removal may be implicit, such as when a scene's entity destruction process includes automatically removing all its components.
    ///
    /// For a description of the closure's signature and parameters, see `ClosureComponent.ClosureType`.
    public var closureOnRemovingFromEntity: ClosureType?
    
    /// - Parameter whenAdded: The block of code to execute when this component is added to an entity.
    ///
    ///     For a description of the closure's signature and parameters, see `ClosureComponent.ClosureType`.
    public convenience init(whenAdded closureOnAddingToEntity: @escaping ClosureType)
    {
        self.init(whenAdded:   closureOnAddingToEntity,
                  whenRemoved: nil)
    }
    
    /// - Parameter whenRemoved: The block of code to execute when this component is removed from an entity.
    ///
    ///     For a description of the closure's signature and parameters, see `ClosureComponent.ClosureType`.
    public convenience init(whenRemoved closureOnRemovingFromEntity: @escaping ClosureType)
    {
        self.init(whenAdded:   nil,
                  whenRemoved: closureOnRemovingFromEntity)
    }
    
    /// Creates a component that executes the specified closures at specific moments.
    ///
    /// For a description of each closure's signature and parameters, see `ClosureComponent.ClosureType`.
    ///
    /// - Parameter whenAdded: The block of code to execute when this component is added to an entity.
    ///
    /// - Parameter whenRemoved: The block of code to execute when this component is removed from an entity.
    public init(whenAdded   closureOnAddingToEntity:     ClosureType?,
                whenRemoved closureOnRemovingFromEntity: ClosureType?)
    {
        self.closureOnAddingToEntity     = closureOnAddingToEntity
        self.closureOnRemovingFromEntity = closureOnRemovingFromEntity
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func didAddToEntity() {
        closureOnAddingToEntity?(self)
    }
    
    public override func willRemoveFromEntity() {
        closureOnRemovingFromEntity?(self)
    }
}

