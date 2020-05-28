//
//  LogChanges.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/4.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A wrapper which prints a `debugLog` of any changes to the wrapped property. **Requires** the `LOGCHANGES` conditional compilation flag to be set, otherwise this wrapper will have no useful effect.
@propertyWrapper
public struct LogChanges <ValueType: Equatable> {
    
    /// CHECK: Should we observe `willSet` instead of `didSet`, for more precise logging i.e. at the exact moment of assignment?
    //
    
    #if LOGCHANGES
    public var wrappedValue: ValueType {
        didSet {
            if  wrappedValue != oldValue {
                var text = ""
                
                if  omitOldValue {
                    text = "= \(wrappedValue)"
                } else {
                    text = "= \(oldValue) → \(wrappedValue)"
                }
                
                debugLog(text,
                         topic:     propertyName.components(separatedBy: ".").first ?? propertyName,
                         function:  propertyName.components(separatedBy: ".").last ?? "")
            }
        }
    }
    #else
    public var wrappedValue: ValueType
    #endif
    
    private let propertyName: String
    
    /// When `true`, the old (previous) value of properties is not printed when logging their changes.
    private let omitOldValue: Bool
    
    // ⚠️🐞
    // TODO: FIX: BUG 20191113A: APPLEBUG: Cannot use #file and #function in a property wrapper init, so we can't automatically set the name. :(
    // Many other bugs with overloaded `init`s and default arguments.
    // https://forums.swift.org/t/compiler-segmentation-fault-when-using-property-wrappers-to-log-changes-to-a-value/30732/2
    
    /*
    public init(wrappedValue: ValueType,
                omitOldValue: Bool = false,
                _ callerFile: String = #file,
                _ callerFunction: String = #function)
    {
        self.wrappedValue = wrappedValue
        self.omitOldValue = omitOldValue
        self.name = "\(callerFile) \(callerFunction)"
    }
    */
 
    public init(wrappedValue: ValueType,
                propertyName: String,
                omitOldValue: Bool)
    {
        self.wrappedValue = wrappedValue
        self.propertyName = propertyName
        self.omitOldValue = omitOldValue
    }
    
    public init(wrappedValue: ValueType,
                propertyName: String)
    {
        self.wrappedValue = wrappedValue
        self.propertyName = propertyName
        self.omitOldValue = false
    }
}
