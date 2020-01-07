//
//  Nameable.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/22.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import SpriteKit

/// A protocol for types that have a `name` property.
public protocol Nameable {
    var name: String? { get }
}

extension OKEntity: Nameable {}
extension SKNode: Nameable {}

extension Array where Array.Element: Nameable {
    
    /// Returns the first element with matching `name`.
    public subscript(name: String) -> Element? {
        return self.first {
            return $0.name == name
        }
    }
    
}
