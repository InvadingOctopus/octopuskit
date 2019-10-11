//
//  OctopusLog.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-29-06
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Cocoa Notifications?
// CHECK: Adopt `os_log`?
// CHECK: Adopt `os_signpost`?
// CHECK: PERFORMANCE: Does padding etc. reduce app performance, i.e. during frequent logging?

import Foundation

public typealias OKLog = OctopusLog
public typealias OKLogEntry = OctopusLogEntry

// MARK: - NSLog Replacements

#if DEBUG

/// Prints a line to the console with the current time and the name of the calling file and function, followed by an optional string.
///
/// Available in debug configurations, but a blank function in non-debug configurations.
public func debugLog(
    _ entry: String? = nil,
    _ callerFile: String = #file,
    _ callerFunction: String = #function,
    separator: String = " ")
{
    // Trim and pad the calling file's name.
    
    let callerFile = ((callerFile as NSString).lastPathComponent as NSString).deletingPathExtension // ((callerFile as NSString).lastPathComponent as NSString).deletingPathExtension
    let paddedFile = callerFile.padding(toLength: 35, withPad: " ", startingAt: 0)
    
    print("\(OctopusLog.currentTimeAndFrame())\(separator)\(paddedFile)\(separator)\(callerFunction)\(entry == nil || entry!.isEmpty ? "" : "\(separator)\(entry!)")")
}

/// Alias for `NSLog(_:_:)` in debug configurations, but a blank function in non-debug configurations.
public func debugLogWithoutCaller(_ format: String, _ args: CVarArg...) {
    NSLog(format, args)
}

#else

/// A blank function in non-debug configurations. Alias for `NSLog(_:_:)` in debug configurations.
open func debugLogWithoutCaller(_ format: String, _ args: CVarArg...) {}

/// A blank function in non-debug configurations.
///
/// Prints a line to the console with the current time and the name of the calling file and function, followed by an optional string.
open func debugLog(_ entry: String? = nil, _ callerFile: String = #file, _ callerFunction: String = #function, separator: String = " ") {}
    
#endif

// MARK: - OctopusLog

/// An entry in an `OctopusLog`.
public struct OctopusLogEntry: CustomStringConvertible {
    public let time: Date
    public let text: String?
    public let addedFromFile: String?
    public let addedFromFunction: String?
    
    public init(
        time: Date = Date(),
        text: String? = nil,
        addedFromFile: String = #file,
        addedFromFunction: String = #function)
    {
        self.time = time
        self.text = text
        self.addedFromFile = addedFromFile
        self.addedFromFunction = addedFromFunction
    }
    
    public var description: String {
        let text = self.text ?? "" // CHECK: Trim whitespace?
        
        return ("\(OctopusLog.timeFormatter.string(from: self.time))\(text.isEmpty ? "" : " ")\(text)")
    }
}

/// An object that keeps a list of log entries, prefixing each entry with a customizable time format and the name of the file and function that added the entry.
///
/// Use multiple `OctopusLog`s to separate different concerns, such as warnings from errors, and to selectively enable or disable specific logs.
///
/// The log allows entries with no text, so you can simply log the time and name of function and method calls.
public struct OctopusLog {
    
    // MARK: Static properties & methods
    
    public static var printEmptyLineBetweenFrames: Bool = false
    
    /// Stores the frame number during the most recent log entry, so we can mark the beginning of a new frame to make logs easier to read.
    public fileprivate(set) static var lastFrameLogged: UInt64 = 0
    
    /// The global time formatter for all OctopusKit logging functions.
    ///
    /// To customize the `dateFormat` property, see the Unicode Technical Standard #35 version tr35-31: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
    public static let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "HH:mm:ss"
        return timeFormatter
    }()
    
    /// Returns a string with the current time formatted by the global `OctopusLog.timeFormatter` and the number of the frame being rendered by the current scene, if any.
    public static func currentTimeAndFrame() -> String {
        // TODO: A better way to get nanoseconds like `NSLog`
        
        let now = Date()
        let nanoseconds = "\(Calendar.current.component(.nanosecond, from: now))".prefix(6)
        let time = OctopusLog.timeFormatter.string(from: now)
        
        let timeWithNanoseconds = "\(time).\(nanoseconds)"
        
        // Add the number of the current frame being rendered, if any.
        
        var currentFrameNumber: UInt64 = 0
        
        // ⚠️ Trying to access `OctopusKit.shared.currentScene` at the very beginning of the application results in an exception like "Simultaneous accesses to 0x100e8f748, but modification requires exclusive access", so we delay it by checking something like `gameController.didEnterInitialState`
        
        if OctopusKit.shared?.gameController.didEnterInitialState ?? false {
            currentFrameNumber = OctopusKit.shared?.currentScene?.currentFrameNumber ?? 0
        }
        else {
            lastFrameLogged = 0
        }
        
        if printEmptyLineBetweenFrames && currentFrameNumber > OctopusLog.lastFrameLogged {
            // CHECK: Should this be the job of the time function?
            print("")
        }
        
        let currentFrameNumberString = " F" + "\(currentFrameNumber)".padding(toLength: 7, withPad: " ", startingAt: 0) + "\(currentFrameNumber > OctopusLog.lastFrameLogged ? "•" : " ")"
        
        lastFrameLogged = currentFrameNumber
        
        return timeWithNanoseconds + currentFrameNumberString
    }
    
    // MARK: Instance properties and methods
    
    /// The title of the log. Appended to the beginning of printed entries.
    public let title: String
    public fileprivate(set) var entries = [OctopusLogEntry]()
    
    #if DEBUG
    /// If `true`, uses `NSLog` to print new entries when they are logged. If `false`, prints new entries in a custom format.
    public var copiesToNSLog: Bool = false // CHECK: Should this be true?
    #else
    /// If `true`, uses `NSLog` to print new entries when they are logged. If `false`, prints new entries in a custom format.
    public var copiesToNSLog: Bool = false
    #endif
    
    /// A string to add at the end of all entries. Not printed if using `NSLog`.
    public let suffix: String?
    
    /// If `true` and `copiesToNSLog` is `false`, the log appends the `suffix` string to the end of all printed entries.
    public var printsSuffix: Bool = true
    
    /// If `true` then new log entries are ignored.
    public var isDisabled: Bool = false
    
    /// - Returns: The `OctopusLogEntry` at `index`.
    public subscript(index: Int) -> OctopusLogEntry {
        // ℹ️ An out-of-bounds index should not crash the game just for logging. :)
        guard index >= 0 && index < entries.count else {
            OctopusKit.logForErrors.add("Index \(index) out of bounds (\(entries.count) entries) — Returning dummy `OctopusLogEntry`")
            return OctopusLogEntry(time: Date(), text: nil)
        }
        return entries[index]
    }
    
    /// - Returns: The `description` for the `OctopusLogEntry` at `index`.
    public subscript(index: Int) -> String {
        // ℹ️ An out-of-bounds index should not crash the game just for logging. :)
        guard index >= 0 && index < entries.count else {
            OctopusKit.logForErrors.add("Index \(index) out of bounds (\(entries.count) entries) — Returning empty string")
            return ""
        }
        return "\(entries[index])" // Simply return the `OctopusLogEntry` as it conforms to `CustomStringConvertible`.
    }

    /// - Returns: The `description` of the last entry added to the log, if any.
    public var lastEntryText: String? {
        return entries.last?.description
    }
    
    public init(
        title: String = "OctopusLog",
        suffix: String? = nil,
        copiesToNSLog: Bool = false)
    {
        self.title = title
        self.suffix = suffix
        self.copiesToNSLog = copiesToNSLog
    }
    
    /// Prints a new entry and adds it to the log.
    public mutating func add(
        _ text: String? = nil,
        _ callerFile: String = #file,
        _ callerFunction: String = #function,
        copyingToNSLog: Bool? = nil)
    {
        // CHECK: Cocoa Notifications for log observers etc.?
        
        guard !isDisabled else { return }
        
        // Override the `copyToNSLog` property if specified here.
        let copyToNSLog = copyingToNSLog ?? self.copiesToNSLog
        
        let callerFile = ((callerFile as NSString).lastPathComponent as NSString).deletingPathExtension
        
        // If there is any text to log, insert a space between the log prefix and the text.
        
        var textWithSpacePrefixIfNeeded = text ?? ""
        
        if !textWithSpacePrefixIfNeeded.isEmpty {
            textWithSpacePrefixIfNeeded = " \(textWithSpacePrefixIfNeeded)"
        }
        
        // Include the suffix, if any, after a space.
        
        let suffix = printsSuffix && self.suffix != nil ? " \(self.suffix!)" : ""
        
        // Duplicate the entry to `NSLog()` if specified, otherwise just `print()` it to the console in our custom format.
        
        if copyToNSLog {
            NSLog("\(title) \(callerFile) \(callerFunction)\(textWithSpacePrefixIfNeeded)")
        }
        else {
            
            // TODO: Truncate filenames with "…"
            
            let paddedFile = callerFile.padding(toLength: 35, withPad: " ", startingAt: 0)
            let paddedTitle = title.padding(toLength: 5, withPad: "0", startingAt: 0)
            
            print("\(OctopusLog.currentTimeAndFrame()) \(paddedTitle)\t \(paddedFile) \(callerFunction)\(textWithSpacePrefixIfNeeded)\(suffix)")
        }
        
        // Add the entry to the log.
        
        entries.append(OctopusLogEntry(time: Date(),
                                       text: text,
                                       addedFromFile: callerFile,
                                       addedFromFunction: callerFunction))
    }
}
