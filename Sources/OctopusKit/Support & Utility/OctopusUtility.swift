//
//  OctopusUtility.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-09
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

/// A selection of general helper methods that may be useful in various tasks.
public struct OctopusUtility {
  
    // CHECK: Should some of these be global functions?
    // CHECK: Rename `result...` to `return...`?
    
    /// Calls a function or method with the specified tuple as its arguments.
    ///
    /// This lets you construct and re-use a single tuple of arguments in multiple calls to different functions that accept the same types of arguments.
    ///
    /// **Example**
    ///
    ///     let arguments = ("Drizzt", 100)
    ///     let drizzt = call(Hero.init, with: arguments)
    ///     // Hero(name: "Drizzt", age: 100)
    ///
    /// - NOTE: The tuple members must be of the same types in the same order as the function's expected parameters.
    public static func call<Arguments, ResultType>(
        _ function: (Arguments) -> ResultType,
        with arguments: Arguments)
        -> ResultType
    {
        // CREDIT: https://www.swiftbysundell.com/posts/using-tuples-as-lightweight-types-in-swift
        return function(arguments)
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
    func combineClosure<A, B>(
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
