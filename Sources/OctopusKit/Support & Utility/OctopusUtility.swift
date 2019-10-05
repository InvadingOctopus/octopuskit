//
//  OctopusUtility.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-09
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A selection of general helper methods that may be useful in various tasks.
public struct OctopusUtility {
  
    // CHECK: Should some of these be global functions?
    // CHECK: Rename `result...` to `return...`?
    
    /// Calls a function or method with the specified argument.
    ///
    /// This may be used with a single tuple of multiple values, in multiple calls to different functions which accept the same set of arguments.
    ///
    /// **Example**
    ///
    ///     let arguments = ("Drizzt", 100)
    ///     let drizzt = call(Hero.init, with: arguments)
    ///     // Hero(name: "Drizzt", age: 100)
    ///
    /// - Note: If a tuple is used, its members must be of the same types and in the same order as the function's parameters.
    public static func call<ArgumentType, ResultType>(
        _ function: (ArgumentType) -> ResultType,
        with argument: ArgumentType)
        -> ResultType
    {
        // CREDIT: https://www.swiftbysundell.com/posts/using-tuples-as-lightweight-types-in-swift
        // CREDIT: https://twitter.com/johnsundell/status/930103466294435840
        return function(argument)
    }
    
    /// Repeats the supplied function for the specified number of times, and returns an array of the results.
    public static func repeatFunction<ResultType>(function: () -> ResultType, times: Int) -> [ResultType]? {
        
        guard times > 0 else { return nil }
        
        if times == 1 {
            return [function()]
        }
        
        // CHECK: Handle exceptions that may be raised in 'function'?
        
        var results: [ResultType] = []
        
        for _ in 0 ..< times {
            results.append(function())
        }
        
        return results
    }
    
    /// Creates a closure combined with the supplied argument, which you can then call without passing any arguments, and without capturing `self`.
    ///
    /// - Warning: The argument's value is captured when the closure is created. When the returned closure is called, it will use that captured value, and may not have the latest expected value even if the original variable is changed.
    public func combineClosure<A, B>(
        with argument: A,
        closure: @escaping (A) -> B)
        -> () -> B
    {
        // CREDIT: https://github.com/JohnSundell/SwiftTips
        // CREDIT: https://twitter.com/johnsundell/status/1055562781070684162
        
        // CHECK: Use and test, especially for leaks and the value of the argument when called, as mentioned at https://twitter.com/sprynmr/status/1055565658811973633
        
        return { closure(argument) }
    }
    
}
