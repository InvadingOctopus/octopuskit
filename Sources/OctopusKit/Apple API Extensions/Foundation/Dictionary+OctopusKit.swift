//
//  Dictionary+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/12/18.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension Dictionary {
    
    /// Returns the value for the specified key. If none exists, adds the result of the supplied closure as the value for that key.
    @inlinable
    mutating func getOrSetValue(for key: Key,
                                with valueClosure: @autoclosure () -> Value)
                                -> Value
    {
        // CREDIT: https://twitter.com/johnsundell/status/822097067648700418
        // CREDIT: https://github.com/JohnSundell/SwiftTips
            
        if  let existingValue = self[key] {
            return existingValue
        
        } else {
            let newValue = valueClosure()
            self[key] = newValue
            return newValue
        }
    }
    
}
