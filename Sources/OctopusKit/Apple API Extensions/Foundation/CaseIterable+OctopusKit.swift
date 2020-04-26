//
//  CaseIterable+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/26.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension CaseIterable {
    
    @inlinable
    static func randomElement() -> Self? {
        Self.allCases.randomElement()
    }
    
    @inlinable
    static func randomElement<T>(using generator: inout T) -> Self? where T : RandomNumberGenerator {
        Self.allCases.randomElement(using: &generator)
    }
}
