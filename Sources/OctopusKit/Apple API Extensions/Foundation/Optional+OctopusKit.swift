//
//  Optional+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/12/18.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension Optional {
    
    /// Returns the value of the optional if non-`nil`, otherwise throws the specified error expression.
    ///
    /// **Example**
    ///
    ///     try checkOptional(value).orThrow(SomeError())
    @inlinable
    func orThrow(_ errorExpression: @autoclosure () -> Error)
                 throws -> Wrapped
    {
        
        // CREDIT: https://twitter.com/johnsundell/status/1047232852113412098
        // CREDIT: https://github.com/JohnSundell/SwiftTips
        
        switch self {
        case .some(let value):  return value
        case .none:             throw errorExpression()
        }
    }
    
}
