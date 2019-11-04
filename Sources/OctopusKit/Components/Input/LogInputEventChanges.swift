//
//  InputEventLogger.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/3.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A wrapper which prints a `debugLog` of any changes to the wrapped property if the `LOGINPUTEVENTS` conditional compilation flag is set.
@propertyWrapper
public struct LogInputEventChanges <ValueType: Equatable> {
    
    public var wrappedValue: ValueType {
        didSet {
            #if LOGINPUTEVENTS
            if wrappedValue != oldValue {
                debugLog("= \(String(optional: wrappedValue))")
            }
            #endif
        }
    }
    
    public init(wrappedValue: ValueType) {
        self.wrappedValue = wrappedValue
    }
}
