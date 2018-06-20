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
    
}
