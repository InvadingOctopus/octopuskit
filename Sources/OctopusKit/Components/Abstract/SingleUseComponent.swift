//
//  SingleUseComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/02.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// An abstract base class for components that perform their task only once at the moment when they're added to an entity, and then remove themselves from their entity.
///
/// - Important: Subclasses must call `super.didAddToEntity()` or `super.didAddToEntity(withNode:)` *after* they hve performed their task in their override of those methods.
open class SingleUseComponent: OctopusComponent {
    
    open override func didAddToEntity() {
        super.didAddToEntity() // Will also call `didAddToEntity(withNode:)` on the subclass.
        self.entity?.removeComponent(ofType: type(of: self))
    }
    
}
