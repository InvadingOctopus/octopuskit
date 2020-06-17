//
//  OctopusKit+Global.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/03
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

// MARK: Global Helper Functions

/// Runs the supplied closure only if the `DEBUG` compilation flag is set. Marks temporary debugging code for easy removal when no longer needed. Set a single breakpoint inside this function's definition to pause execution on every call.
///
/// **Example**: `💩 { print("some info") }`
///
@inlinable
public func 💩(_ closure: () -> Void) {
    #if DEBUG
    closure()
    #endif
}

/// Runs the supplied closure and returns its optional result only if the `DEBUG` compilation flag is set. Marks temporary debugging code and list members for easy removal when no longer needed. Set a single breakpoint inside this function's definition to pause execution on every call.
///
/// **Example**: `let oddNumbers = [1, 💩{2}!, 3]`
///
@inlinable
public func 💩 <ReturnValue> (_ closure: () -> ReturnValue?) -> ReturnValue? {
    #if DEBUG
    return closure()
    #else
    return nil
    #endif
}

// MARK: NSLog Replacements

#if DEBUG

/// Prints a line to the console with the current time and the name of the calling file and function, followed by an optional string.
///
/// Available in debug configurations (when the `DEBUG` compilation flag is set). A blank function in non-debug configurations.
///
/// - Parameters:
///   - entry:      The text of the entry.
///   - topic:      The file name, type name, runtime object, or subsystem from which this entry is logged. Default: The file name.
///   - function:   The specific function or task inside the topic from which this entry is logged. Default: The function signature.
///   - separator:  The separator to place between time, topic, function and entry. Default: A single space.
@inlinable
public func debugLog(_ entry:   String? = nil,
                     topic:     String  = #file,
                     function:  String  = #function,
                     separator: String  = " ")
{
    // Trim and pad the calling file's name.
    
    let paddedPrefix = "◾️".paddedWithSpace(toLength: OKLog.prefixLength)
    let topic        = ((topic as NSString).lastPathComponent as NSString).deletingPathExtension
    let paddedTopic  = topic.paddedWithSpace(toLength: OKLog.topicLength)
    let entry        = entry ?? ""
    let entryWithSeparatorIfNeeded = entry.isEmpty ? "" : "\(separator)\(entry)"
    
    if  OKLog.printAsCSV {
        
        let csv = [
            OKLog.currentTimeString(),
            OKLog.currentFrameString(),
            #""\#(topic     )""#,
            #""\#(function  )""#,
            #""\#(entry     )""#
        ].joined(separator: OKLog.csvDelimiter)
        
        print(csv)
        
    } else if OKLog.printTextOnSecondLine {
        
        print("""
            \(OKLog.currentTimeAndFrame())\(separator)\(paddedPrefix)\(separator)\(paddedTopic)
            \(function)\(entryWithSeparatorIfNeeded)
            """)
        
    } else {
        
        print("\(OKLog.currentTimeAndFrame())\(separator)\(paddedPrefix)\(separator)\(paddedTopic)\(separator)\(function)\(entryWithSeparatorIfNeeded)")
    }
    
    if OKLog.printEmptyLineBetweenEntries { print() }
    
    // Update the last frame counter (so that the next entry for the same frame doesn't get highlighted as the first entry and so on).
    
    OKLog.lastFrameLogged = OKLog.currentFrame
}

/// Alias for `NSLog(_:_:)` in debug configurations (when the `DEBUG` compilation flag is set). A blank function in non-debug configurations.
@inlinable
public func debugLogWithoutCaller(_ format: String, _ args: CVarArg...) {
    NSLog(format, args)
}

#else

/// A blank function in non-debug configurations (when the `DEBUG` compilation flag is *not* set). Alias for `NSLog(_:_:)` in debug configurations.
@inlinable
public func debugLogWithoutCaller(_ format: String, _ args: CVarArg...) {}

/// A blank function in non-debug configurations (when the `DEBUG` compilation flag is *not* set).
///
/// In debug configurations, prints a line to the console with the current time and the name of the calling file and function, followed by an optional string.
@inlinable
public func debugLog(_ entry: String? = nil, topic: String = #file, function: String = #function, separator: String = " ") {}
    
#endif
