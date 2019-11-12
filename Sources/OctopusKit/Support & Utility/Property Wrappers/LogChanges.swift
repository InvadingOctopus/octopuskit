//
//  LogChanges.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/4.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A wrapper which prints a `debugLog` of any changes to the wrapped property.
@propertyWrapper
public struct LogChanges <ValueType: Equatable> {
    
    public var wrappedValue: ValueType {
        didSet {
            if  wrappedValue != oldValue {
                debugLog("= \(oldValue) → \(wrappedValue)")
            }
        }
    }
    
    public init(wrappedValue: ValueType) {
        self.wrappedValue = wrappedValue
    }
}
