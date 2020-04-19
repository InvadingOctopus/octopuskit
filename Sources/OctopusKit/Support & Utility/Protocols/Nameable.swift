//
//  Nameable.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/22.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import SpriteKit

/// A protocol for types that have a `name` property.
public protocol Nameable {
    var name: String? { get }
}

extension OKEntity:    Nameable {}
extension SKNode:      Nameable {}
extension SKTileGroup: Nameable {}

public extension Collection where Element: Nameable {
    
    /// Returns all elements matching `name`, otherwise an empty array if none are found.
    subscript(name: String) -> [Element] {
        return self.filter { $0.name == name }
    }
}
