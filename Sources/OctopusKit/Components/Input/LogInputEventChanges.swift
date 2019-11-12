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
            if wrappedValue != oldValue {
                debugLog("= \(oldValue) → \(wrappedValue)")
            }
        }
    }
    #else
    public var wrappedValue: ValueType
    #endif
    
    public init(wrappedValue: ValueType) {
        self.wrappedValue = wrappedValue
    }
}
