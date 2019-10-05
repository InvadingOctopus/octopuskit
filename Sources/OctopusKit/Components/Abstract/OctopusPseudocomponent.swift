//
//  OctopusPseudocomponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/12/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A protocol for types that can perform per-frame updates and hold a reference to an `OctopusEntity`. Such types may be used as the properties of a component, but otherwise cannot be added to an entity or component system.
public protocol OctopusPseudocomponent {
    var entity: OctopusEntity? { get }
    func update(deltaTime seconds: TimeInterval)
}
