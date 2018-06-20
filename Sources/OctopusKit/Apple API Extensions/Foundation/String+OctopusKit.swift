//
//  String+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import Foundation

extension String {
    
    /// Creates a `String` containing the `description` of `optional`.
    ///
    /// Produces cleaner string interpolation than the default behavior of printing optionals (sans the "Optional:" text).
    init(optional: Optional<Any>) {
        /// Helps in removing the extremely annoying warning about "String interpolation produces a debug description for an optional value; did you mean to make this explicit?"
        
        // TODO: Remove when it may not be needed in a future Swift version, hopefully.
        switch optional {
        case .some(let value):
            self.init(describing: value)
        case .none:
            self.init(describing: optional)
        }
    }
    
    /// Generates and returns a function that concatenates strings in the order they're sent, with an optional (comma by default) separator.
    public static func createConcatenator(withSeparator separator: String = ", ")
        -> (String?) -> String
    {
        // CHECK: Is this method useful or is it too weird and not compatible with Swift idioms?
        
        var concatenatedString = ""
        
        /// Adds the specified string to all the previous strings passed.
        ///
        /// Returns the string concatenated so far when an empty or missing string is passed as the argument.
        func concatenator(addString stringToAdd: String? = nil) -> String {
            
            if let string = stringToAdd {
                if string == "" {
                    return concatenatedString
                } else {
                    if concatenatedString != "" {
                        concatenatedString += separator
                    }
                    concatenatedString += stringToAdd!
                    
                }
            }
            
            return concatenatedString
        }
        
        return concatenator
    }
    
    /// Generates and returns a function that concatenates strings in the order they're sent, with a separator that may be overriden per each call.
    public static func createConcatenatorWithOverrideableSeparator(withDefaultSeparator defaultSeparator: String = ", ")
        -> (String?, String?) -> String
    {
        // CHECK: Is this method useful or is it too weird and not compatible with Swift idioms?
        
        var concatenatedString = ""
        
        /// Adds the specified string to all the previous strings passed.
        ///
        /// Returns the string concatenated so far when an empty or missing string is passed as the argument.
        func concatenator(addString stringToAdd: String? = nil, overrideSeparator: String? = nil) -> String {
            
            if let string = stringToAdd {
                if string == "" {
                    return concatenatedString
                } else {
                    if concatenatedString != "" {
                        concatenatedString += overrideSeparator ?? defaultSeparator
                    }
                    concatenatedString += stringToAdd!
                    
                }
            }
            
            return concatenatedString
        }
        
        return concatenator
    }
    
}
