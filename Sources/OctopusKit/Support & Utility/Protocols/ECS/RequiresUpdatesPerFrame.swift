//
//  RequiresUpdatesPerFrame.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

public typealias OctopusUpdatableComponent  = RequiresUpdatesPerFrame
public typealias OKUpdatableComponent       = RequiresUpdatesPerFrame

/// A protocol for components that must be updated every frame to correctly perform their functions.
///
/// The component must be updated every frame during the scene's `update(_:)` method, by directly calling the component's `update(deltaTime:)` method, updating the component's entity, or updating the component system which this component is registered with.
///
/// When a component with this protocol is added to a scene but the scene does not the relevant component system, a warning is logged to help reduce bugs and incorrect behaviors that result from missing systems.
public protocol RequiresUpdatesPerFrame { // CHECK: Add UpdatablePerFrame?
    func update(deltaTime seconds: TimeInterval)
}
