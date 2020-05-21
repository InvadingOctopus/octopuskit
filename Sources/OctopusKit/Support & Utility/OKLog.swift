//
//  OKLog.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-29-06
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// CHECK: Cocoa Notifications?
// CHECK: Adopt `os_log`?
// CHECK: Adopt `os_signpost`?
// CHECK: PERFORMANCE: Does padding etc. reduce app performance, i.e. during frequent logging?

import Foundation

public typealias OctopusLog = OKLog

public extension OctopusKit {
    
    /// Contains all the entries that are logged to any log. May be used for displaying all entries in a log viewer.
    fileprivate(set) static var unifiedLog = OKLog (title: "🐙")

}

/// An object that keeps a list of log entries, prefixing each entry with a customizable time format and the name of the file and function that added the entry. Designed to optimize readability in the Xcode debug console.
///
/// Use multiple `OKLog`s to separate different concerns, such as warnings from errors, and to selectively enable or disable specific logs.
///
/// The log allows entries with no text, so you can simply log the time and name of function and method calls.
public struct OKLog: Codable {
    
    // MARK: Static properties, methods & global options
        
    /// If `true` then an empty line is printed between each entry in the debug console.
    public static var printEmptyLineBetweenEntries: Bool = false
    
    /// If `true` then an empty line is printed between entries with different frame counts (e.g. F0 and F1).
    public static var printEmptyLineBetweenFrames:  Bool = false
    
    /// If `true` then an entry is printed on at least 2 lines in the debug console, where the time and calling file is on the first line and the text is on the second line.
    public static var printTextOnSecondLine: Bool = false
    
    /// If `true` then debug console output is printed in tab-delimited CSV format, that may then be copied into a spreadsheet table such as Numbers etc.
    ///
    /// The values are: currentTime, currentFrameNumber, title, topic, function, text, suffix.
    public static var printAsCSV: Bool = false
    
    /// The separator to print between values when `printAsCSV` is `true`.
    /// Default is `tab`.
    public static var csvDelimiter: String = "\t"
    
    /// Stores the frame number during the most recent log entry, so we can mark the beginning of a new frame to make logs easier to read.
    public fileprivate(set) static var lastFrameLogged: UInt64 = 0
    
    /// The global time formatter for all OctopusKit logging functions.
    ///
    /// To customize the `dateFormat` property, see the Unicode Technical Standard #35 version tr35-31: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
    public static let timeFormatter: DateFormatter = {
        let timeFormatter           = DateFormatter()
        timeFormatter.locale        = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat    = "HH:mm:ss"
        return timeFormatter
    }()
    
    /// Returns a string with the current time formatted by the global `OKLog.timeFormatter`.
    @inlinable
    public static func currentTimeString() -> String {
        // TODO: A better way to get nanoseconds like `NSLog`
        
        let now         = Date()
        let nanoseconds = "\(Calendar.current.component(.nanosecond, from: now))".prefix(6)
        let time        = OKLog.timeFormatter.string(from: now)
        
        let timeWithNanoseconds = "\(time).\(nanoseconds)"
        
        return timeWithNanoseconds
    }
    
    /// Returns the `currentFrameNumber` of `OctopusKit.shared.currentScene`, if available, otherwise `0`.
    public static var currentFrame: UInt64 {
        // ⚠️ Trying to access `OctopusKit.shared.currentScene` at the very beginning of the application results in an exception like "Simultaneous accesses to 0x100e8f748, but modification requires exclusive access", so we delay it by checking something like `gameCoordinator.didEnterInitialState`
        
        if  OctopusKit.shared?.gameCoordinator.didEnterInitialState ?? false {
            return OctopusKit.shared.currentScene?.currentFrameNumber ?? 0
        } else {
            return 0
        }
    }
    
    /// Returns `true` if the `currentFrame` count is higher than `lastFrameLogged`.
    public static var isNewFrame: Bool {
        self.currentFrame > self.lastFrameLogged
    }
    
    /// Returns a string with the number of the frame being rendered by the current scene, if any.
    public static func currentFrameString() -> String {
        
        // If there is no scene, reset the last frame counter.
        
        if  OctopusKit.shared?.gameCoordinator.didEnterInitialState ?? false
        ||  OctopusKit.shared?.currentScene == nil
        {
            self.lastFrameLogged = 0
        }
        
        let currentFrame = self.currentFrame
        
        if  printEmptyLineBetweenFrames && currentFrame > OKLog.lastFrameLogged {
            // CHECK: Should this be the job of the time function?
            print("")
        }
        
        let currentFrameNumberString = " F" + "\(currentFrame)".paddedWithSpace(toLength: 7) + "\(currentFrame > OKLog.lastFrameLogged ? "•" : " ")"
        
        // Remember the last frame we logged (assuming that the output of this function will be logged) so that we can insert an empty line between future frames if `printEmptyLineBetweenFrames` is set.
        
        lastFrameLogged = currentFrame
        
        return currentFrameNumberString
    }
    
    /// Returns a string with the current time formatted by the global `OKLog.timeFormatter` and the number of the frame being rendered by the current scene, if any.
    @inlinable
    public static func currentTimeAndFrame() -> String {
        currentTimeString() + currentFrameString()
    }
    
    // MARK: Instance properties and methods
    
    /// The title of the log. Appended to the beginning of printed entries.
    public let title: String
    
    public var entries = [OKLogEntry]() // Not private so functions can be @inlinable
    
    /// If `true`, uses `NSLog` to print new entries to the debug console when they are added.
    /// If `false`, prints new entries in a custom format. This is the default.
    public var useNSLog: Bool = false
    
    /// A string to add at the end of all entries. Not printed if using `NSLog`.
    public let suffix: String?
    
    /// If `true` and `useNSLog` is `false`, the log appends the `suffix` string to the end of all printed lines, but not to the saved entry.
    public var printsSuffix: Bool = true
    
    /// If `true` then new entries are ignored and the `add(...)` method is skipped.
    public var disabled: Bool = false
    
    /// Returns the `OKLogEntry` at `index`.
    public subscript(index: Int) -> OKLogEntry {
        // ℹ️ An out-of-bounds index should not crash the game just for logging. :)
        guard index >= 0 && index < entries.count else {
            OctopusKit.logForErrors("Index \(index) out of bounds (\(entries.count) entries) — Returning dummy `OKLogEntry`")
            return OKLogEntry(time: Date())
        }
        
        return entries[index]
    }
    
    /// - Returns: The `description` for the `OKLogEntry` at `index`.
    @inlinable
    public subscript(index: Int) -> String {
        // ℹ️ An out-of-bounds index should not crash the game just for logging. :)
        guard index >= 0 && index < entries.count else {
            OctopusKit.logForErrors("Index \(index) out of bounds (\(entries.count) entries) — Returning empty string")
            return ""
        }
        
        return "\(entries[index])" // Simply return the `OKLogEntry` as it conforms to `CustomStringConvertible`.
    }

    /// - Returns: The `description` of the last entry added to the log, if any.
    @inlinable
    public var lastEntryText: String? {
        entries.last?.text
    }
    
    /// If `true` then a `fatalError` is raised when a new entry is added.
    ///
    /// Useful for logs that display critical errors.
    public var haltApplicationOnNewEntry: Bool = false
    
    // MARK: Initializer
    
    /// Creates a new log for grouping related entries.
    ///
    /// You may create multiple logs, e.g. one for each subsystem such as input, physics, etc.
    /// - Parameters:
    ///   - title:      The title of the log.
    ///   - suffix:     The text to add at the end of each entry's text **when printing only**; not stored in the actual `OKLogEntry`.
    ///   - useNSLog:   If `true`, `NSLog(_:)` is used instead of `print(_:)`. Default: `false`.
    ///   - haltApplicationOnNewEntry: If `true`, a `fatalError()` exception is raised when a new entry is added. This may be useful for logs that report critical errors.
    public init(
        title:                      String  = "OKLog",
        suffix:                     String? = nil,
        useNSLog:                   Bool    = false,
        haltApplicationOnNewEntry:  Bool    = false)
    {
        self.title                          = title
        self.suffix                         = suffix
        self.useNSLog                       = useNSLog
        self.haltApplicationOnNewEntry      = haltApplicationOnNewEntry
    }
    
    // MARK: Add Entry
    
    /// Prints a new entry and adds it to the log.
    /// - Parameters:
    ///   - text:       The content of the entry.
    ///   - topic:      The file name, type name, runtime object, or subsystem from which this entry is logged. Default: The file name.
    ///   - function:   The specific function or task inside the topic from which this entry is logged. Default: The function signature.
    ///   - useNSLog:   If `true`, `NSLog(_:)` is used instead of `print(_:)`. Default: `nil`; this log's `useNSLog` property is used.
    @inlinable
    public mutating func add(_ text:     String  = "",
                             topic:      String  = #file,
                             function:   String  = #function,
                             useNSLog:   Bool?   = nil)
    {
        // CHECK: Cocoa Notifications for log observers etc.?
        
        guard !disabled else { return }
        
        /// Save the time closest to when this method was called, to avoid any "drift" between processing the arguments and saving the actual entry.
        let time = Date()
        
        // Override the `useNSLog` instance property if specified here.
        let useNSLog = useNSLog ?? self.useNSLog
        
        // Trim the path from topic to only include the file name.
        let topic = ((topic as NSString).lastPathComponent as NSString).deletingPathExtension
        
        /// Print the entry to the debug console or `NSLog`.
        
        let consoleText = printEntry(text,
                                     topic:     topic,
                                     function:  function,
                                     useNSLog:  useNSLog)
        
        // Add the entry to the log.
        
        let newEntry = OKLogEntry(title:    self.title,
                                  time:     time,
                                  text:     text,
                                  topic:    topic,
                                  function: function)
        
        entries.append(newEntry)
        
        // Also append the entry to the global unified log. Useful for a log viewer.
        
        OctopusKit.unifiedLog.entries.append(newEntry)
        
        // If this is a log that displays critical errors, halt the program execution by raising a `fatalError`.
        
        if  haltApplicationOnNewEntry {
            fatalError(consoleText)
        }
    }
    
    /// Formats and prints the entry to the runtime debug console or `NSLog`, and returns the formatted string.
    @inlinable @discardableResult
    public func printEntry(_ text:     String  = "",
                           topic:      String  = #file,
                           function:   String  = #function,
                           useNSLog:   Bool    = false)
                        -> String
    {
        // If there is any text to log, insert a space between the log prefix and the text.
        
        var textWithSpacePrefixIfNeeded = text
        
        if !textWithSpacePrefixIfNeeded.isEmpty {
            textWithSpacePrefixIfNeeded = " \(textWithSpacePrefixIfNeeded)"
        }
        
        // Include the suffix, if any, after a space.
        
        let suffix = printsSuffix && self.suffix != nil ? " \(self.suffix!)" : ""
        
        // Duplicate the entry to `NSLog()` if specified, otherwise just `print()` it to the console in our custom format.
        
        var consoleText: String = ""
        
        if  useNSLog {
            NSLog("\(title) \(topic) \(function)\(textWithSpacePrefixIfNeeded)")
            
        } else {
          
            if  OKLog.printAsCSV {
                
                consoleText = [
                    OKLog.currentTimeString(),
                    "\(OctopusKit.shared.currentScene?.currentFrameNumber ?? 0)",
                    #""\#(title)""#,
                    #""\#(topic)""#,
                    #""\#(function)""#,
                    #""\#(text)""#,
                    #""\#(suffix)""#
                ].joined(separator: OKLog.csvDelimiter)
                
            } else {
                // TODO: Truncate filenames with "…"
                
                let paddedTitle = title.paddedWithSpace(toLength: 8)
                let paddedTopic = topic.paddedWithSpace(toLength: 35)
                 
                if  OKLog.printTextOnSecondLine {
                    consoleText = """
                        \(OKLog.currentTimeAndFrame()) \(paddedTitle) \(topic)
                        \(String(repeating: " ", count: 35))\(function)\(textWithSpacePrefixIfNeeded)\(suffix)
                        """
                    
                } else {
                    consoleText = "\(OKLog.currentTimeAndFrame()) \(paddedTitle) \(paddedTopic) \(function)\(textWithSpacePrefixIfNeeded)\(suffix)"
                }
            }
            
            print(consoleText)
            
            // NOTE: We cannot rely on the count of entries to determine whether to print an empty line, as there may be multiple logs printing to the debug console, so just add an empty line after all entries. :)
            
            if OKLog.printEmptyLineBetweenEntries { print() }
        }
        
        return consoleText
    }
    
    /// A convenience for adding entries by simply writing `logName(...)` instead of calling the `.add(...)` method.
    @inlinable
    public mutating func callAsFunction(
        _ text:     String  = "",
        topic:      String  = #file,
        function:   String  = #function,
        useNSLog:   Bool?   = nil)
    {
        self.add(text,
                 topic:     topic,
                 function:  function,
                 useNSLog:  useNSLog)
    }
}
