//
//  String+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import Foundation

public extension String {
    
    /// Creates a `String` containing the `description` of the `optional` value.
    ///
    /// Produces cleaner string interpolation than the default behavior of printing optionals by omitting the `"Optional(...)"` text.
    init(optional: Optional<Any>) {
        /// Helps in removing the warning about "String interpolation produces a debug description for an optional value; did you mean to make this explicit?"
        
        switch optional {
        case .some(let value):  self.init(describing: value)
        case .none:             self.init(describing: optional)
        }
    }
    
    // MARK: - Type Methods
    
    /// Generates and returns a function that concatenates strings in the order they're sent, with an optional (comma by default) separator.
    @inlinable
    static func createConcatenator(withSeparator separator: String = ", ")
        -> (String?) -> String
    {
        // CHECK: Is this method useful or is it too weird and not compatible with Swift idioms?
        
        var concatenatedString = ""
        
        /// Adds the specified string to all the previous strings passed.
        ///
        /// Returns the string concatenated so far when an empty or missing string is passed as the argument.
        func concatenator(addString stringToAdd: String? = nil) -> String {
            
            if  let string = stringToAdd {
                
                if  string == "" {
                    return concatenatedString
                
                }   else {
                
                    if  concatenatedString != "" {
                        concatenatedString += separator
                    }
                    
                    concatenatedString += stringToAdd!
                }
            }
            
            return concatenatedString
        }
        
        return concatenator
    }
    
    /// Generates and returns a function that concatenates strings in the order they're sent, with a separator that may be overridden per each call.
    @inlinable
    static func createConcatenatorWithOverridableSeparator(withDefaultSeparator defaultSeparator: String = ", ")
        -> (String?, String?) -> String
    {
        // CHECK: Is this method useful or is it too weird and not compatible with Swift idioms?
        
        var concatenatedString = ""
        
        /// Adds the specified string to all the previous strings passed.
        ///
        /// Returns the string concatenated so far when an empty or missing string is passed as the argument.
        func concatenator(addString stringToAdd: String? = nil, overrideSeparator: String? = nil) -> String {
            
            if  let string = stringToAdd {
                
                if  string == "" {
                    return concatenatedString
                    
                } else {
                    
                    if  concatenatedString != "" {
                        concatenatedString += overrideSeparator ?? defaultSeparator
                    }
                    
                    concatenatedString += stringToAdd!
                }
            }
            
            return concatenatedString
        }
        
        return concatenator
    }
    
    // MARK: - Common Tasks
    
    /// Shortcut for `padding(toLength:withPad:startingAt:)`.
    func paddedWithSpace(toLength newLength: Int) -> Self {
        return self.padding(toLength: newLength, withPad: " ", startingAt: 0)
    }
    
}

extension DefaultStringInterpolation {
    
    /// Fixes the warnings about "String interpolation produces a debug description for an optional value; did you mean to make this explicit?"
    ///
    /// When a debug description for an optional value is needed, use `String(describing:)`
    @inlinable
    public mutating func appendInterpolation <T> (optional optionalValue: T?) {
        appendInterpolation(String(optional: optionalValue))
    }
    
    /// Shorthand for `"\(optional: someValue)"`
    @inlinable
    public mutating func appendInterpolation <T> (_ optionalValue: T?) {
        appendInterpolation(String(optional: optionalValue))
    }
    
}

