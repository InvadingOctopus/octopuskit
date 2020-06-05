//
//  Pseudocomponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/12/10.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

public typealias OKPseudocomponent = Pseudocomponent

/// A protocol for types that hold a reference to an `OKEntity` and can perform per-frame updates. Such types may be used as the properties of a component, but otherwise cannot be added to an entity or component system.
public protocol Pseudocomponent: UpdatablePerFrame {
    var entity: OKEntity? { get }
    func update(deltaTime seconds: TimeInterval)
}
