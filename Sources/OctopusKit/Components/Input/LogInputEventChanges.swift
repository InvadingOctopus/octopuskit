//
//  InputEventLogger.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/3.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A wrapper which prints a `debugLog` of any changes to the wrapped property if the `LOGINPUTEVENTS` conditional compilation flag is set.
///
/// When you use an additional `didSet` observer on properties which have this wrapper, this wrapper's observer will execute first.
@propertyWrapper
public struct LogInputEventChanges <ValueType: Equatable> {
    
    #if LOGINPUTEVENTS
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
    #else
    public var wrappedValue: ValueType
    #endif
    
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
