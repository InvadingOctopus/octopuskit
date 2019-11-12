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
                if  omitOldValue {
                    debugLog("= \(wrappedValue)")
                } else {
                    debugLog("= \(oldValue) → \(wrappedValue)")
                }
            }
        }
    }
    
    /// When `true`, the old (previous) value of properties is not printed when logging their changes.
    let omitOldValue: Bool
    
    /// Adds a `didSet` observer which calls `debugLog(_:)` to print the new value and `oldValue` of the wrapped property when it changes.
    /// - Parameters:
    ///   - wrappedValue: The value to log changes for.
    ///   - omitOldValue: Set this to `true` for properties whose old value does not matter when logging their changes.
    public init(wrappedValue: ValueType, omitOldValue: Bool = false) {
        self.wrappedValue = wrappedValue
        self.omitOldValue = omitOldValue
    }
    
    /// Adds a `didSet` observer which calls `debugLog(_:)` to print the new value and `oldValue` of the wrapped property when it changes.
    public init(wrappedValue: ValueType) {
        self.wrappedValue = wrappedValue
        self.omitOldValue = false
    }
}
