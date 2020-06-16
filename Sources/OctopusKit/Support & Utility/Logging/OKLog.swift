//
//  OKLog.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-29-06
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

/// 💡 SEE ALSO: `debugLog(...)` in `OctopusKit+Global.swift`

import Foundation

public typealias OctopusLog = OKLog

public extension OctopusKit {
    
    /// Contains all the entries that are logged to any log. May be used for displaying all entries in a log viewer.
    fileprivate(set) static var unifiedLog = OKLog (title: "Combined Logs", prefix: "🐙")

}

/// An object that keeps a list of log entries, prefixing each entry with a customizable time format and the name of the file and function that added the entry. Designed to optimize readability in the Xcode debug console.
///
/// Use multiple `OKLog`s to separate different concerns, such as warnings from errors, and to selectively enable or disable specific logs.
///
/// The log allows entries with no text, so you can simply log the time and name of function and method calls.
public struct OKLog {
    
    // CHECK: Cocoa Notifications?
    // CHECK: Adopt `os_log`?
    // CHECK: Adopt `os_signpost`?
    // CHECK: PERFORMANCE: Does padding etc. reduce app performance, i.e. during frequent logging?

    // MARK: - Global Settings
    
    /// If `true` then an empty line is printed between each entry in the debug console.
    public static var printEmptyLineBetweenEntries: Bool = false
    
    /// If `true` then an empty line is printed between entries with different frame counts (e.g. F0 and F1).
    public static var printEmptyLineBetweenFrames:  Bool = false
    
    /// If `true` then an entry is printed on at least 2 lines in the debug console, where the time and calling file is on the first line and the text is on the second line.
    public static var printTextOnSecondLine: Bool = false
    
    /// If `true` then debug console output is printed in CSV format, that may then be copied into a spreadsheet table such as Numbers etc.
    ///
    /// See the `OKEntry.csv` property for a list of the values i.e. columns.
    public static var printAsCSV: Bool = false
    
    /// The separator to print between values when `printAsCSV` is `true`. Default: `tab`
    public static var csvDelimiter: String = "\t"
    
    // MARK: Padding
    
    // The number of characters to pad values to when printing entries.
    // DESIGN: PERFORMANCE: Making them `let` instead of `var` may be faster.
    
    public static let framePadding:     Int = 8
    public static let prefixPadding:    Int = 8
    public static let topicPadding:     Int = 35
    
    // MARK: Static Properties
    
    /// Stores the frame number during the most recent log entry, so we can mark the beginning of a new frame to make logs easier to read.
    public static var lastFrameLogged: UInt64 = 0 // Not fileprivate(set) so functions can be @inlinable
    
    /// Returns the `currentFrameNumber` of `OctopusKit.shared.currentScene`, if available, otherwise `0`.
    @inlinable
    public static var currentFrame: UInt64 {
        // ⚠️ Trying to access `OctopusKit.shared.currentScene` at the very beginning of the application results in an exception like "Simultaneous accesses to 0x100e8f748, but modification requires exclusive access", so we delay it by checking something like `gameCoordinator.didEnterInitialState`
        
        if  OctopusKit.shared?.gameCoordinator.didEnterInitialState ?? false {
            return OctopusKit.shared.currentScene?.currentFrameNumber ?? 0
        } else {
            return 0
        }
    }
    
    /// Returns `true` if the `currentFrame` count is higher than `lastFrameLogged`.
    @inlinable
    public static var isNewFrame: Bool {
        self.currentFrame > self.lastFrameLogged
    }
    
    // MARK: - Formatting
    
    /// The global time formatter for all OctopusKit logging functions.
    ///
    /// To customize the `dateFormat` property, see the Unicode Technical Standard #35 version tr35-31: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
    public static let timeFormatter: DateFormatter = {
        let timeFormatter           = DateFormatter()
        timeFormatter.locale        = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat    = "HH:mm:ss"
        return timeFormatter
    }()
    
    /// Returns a string with the specified time as formatted by the global `OKLog.timeFormatter`.
    @inlinable
    public static func formattedTimeString(time: Date) -> String {
        // TODO: A better way to get nanoseconds like `NSLog`
        
        let nanoseconds = "\(Calendar.current.component(.nanosecond, from: time))".prefix(6)
        let time        = OKLog.timeFormatter.string(from: time)
        
        let timeWithNanoseconds = "\(time).\(nanoseconds)"
        
        return timeWithNanoseconds
    }
    
    /// Returns a string with the current time as formatted by the global `OKLog.timeFormatter`.
    @inlinable
    public static func currentTimeString() -> String {
        formattedTimeString(time: Date())
    }
    
    /// Returns a string with the number of the frame being rendered by the current scene, if any.
    @inlinable
    public static func currentFrameString() -> String {
        
        let currentFrame = self.currentFrame // PERFORMANCE: Don't query the scene repeatedly via properties.
        
        /// If the `lastFrameLogged` is higher than the `currentFrame`, then it may mean the active scene has changed and we should reset the last-frame counter.
        
        if  self.lastFrameLogged > currentFrame {
            self.lastFrameLogged = 0
        }
        
        let isNewFrame = (currentFrame > self.lastFrameLogged) // PERFORMANCE: Again, don't query the properties.
        
        if  printEmptyLineBetweenFrames && isNewFrame {
            // CHECK: Should this be the job of the time function?
            print("")
        }
        
        let currentFrameNumberString = " F" + "\(currentFrame)".paddedWithSpace(toLength: framePadding) + "\(isNewFrame ? "•" : " ")"
        
        /// BUG FIXED: Set `lastFrameLogged` in `OKLog.add(...)` instead of here, so that `OKLogEntry.init(...)` has a chance to check `isNewFrame` correctly.
        
        return currentFrameNumberString
    }
    
    /// Returns a string with the current time formatted by the global `OKLog.timeFormatter` and the number of the frame being rendered by the current scene, if any.
    @inlinable
    public static func currentTimeAndFrame() -> String {
        currentTimeString() + currentFrameString()
    }
    
    // MARK: - Instance Properties
    
    /// The descriptive title of the log. Not printed or saved in entries.
    public let title:  String
    
    /// The prefix appended to the beginning of printed entries. May be emojis or symbols.
    public let prefix: String
    
    public var entries = [OKLogEntry]() // Not private so functions can be @inlinable
    
    /// If `true`, uses `NSLog` to print new entries to the debug console when they are added.
    /// If `false`, prints new entries in a custom format. This is the default.
    public var useNSLog:    Bool = false
    
    /// A string to append to the end of an entry's text when printing. **Not** added to saved entries. Not printed when using `NSLog`.
    public let suffix:      String?
    
    /// If `true` then new entries are ignored and the `add(...)` method is skipped.
    public var isDisabled:  Bool = false
    
    /// Returns the `OKLogEntry` at `index`.
    @inlinable
    public subscript(index: Int) -> OKLogEntry {
        // ℹ️ An out-of-bounds index should not crash the game just for logging. :)
        guard index >= 0 && index < entries.count else {
            OctopusKit.logForErrors("Index \(index) out of bounds (\(entries.count) entries) — Returning dummy `OKLogEntry`")
            return OKLogEntry(time: Date())
        }
        
        return entries[index]
    }
    
    /// Returns the `description` for the `OKLogEntry` at `index`.
    @inlinable
    public subscript(index: Int) -> String {
        // ℹ️ An out-of-bounds index should not crash the game just for logging. :)
        guard index >= 0 && index < entries.count else {
            OctopusKit.logForErrors("Index \(index) out of bounds (\(entries.count) entries) — Returning empty string")
            return ""
        }
        
        return "\(entries[index])" // Simply return the `OKLogEntry` as it conforms to `CustomStringConvertible`.
    }

    /// Returns the `description` of the last entry added to the log, if any.
    @inlinable
    public var lastEntryText: String? {
        entries.last?.text
    }
    
    /// If `true` then a breakpoint is triggered after a new entry is added. Ignored if the `DEBUG` conditional compilation flag is not set.
    ///
    /// Calls `raise(SIGINT)`. Useful for logs that display warnings or other events which may cause incorrect or undesired behavior. Application execution may be resumed if running within Xcode.
    public var breakpointOnNewEntry: Bool = false
    
    /// If `true` then a `fatalError` is raised after a new entry is added.
    ///
    /// Useful for logs which display critical errors.
    public var haltApplicationOnNewEntry: Bool = false
    
    /// A unique identifier for compatibility with SwiftUI lists.
    public let id = UUID()
    
    // MARK: - Initializer
    
    /// Creates a new log for grouping related entries.
    ///
    /// You may create multiple logs, e.g. one for each subsystem such as input, physics, etc.
    /// - Parameters:
    ///   - title:      The descriptive title of the log.
    ///   - prefix:     A prefix appended to the beginning of printed entries, to distinguish entries from different logs. May be emojis or symbols.
    ///   - suffix:     The text to add at the end of each entry's text **when printing only**; not stored in the actual `OKLogEntry`.
    ///   - useNSLog:   If `true`, `NSLog(_:)` is used instead of `print(_:)`. Default: `false`.
    ///   - breakpointOnNewEntry: If `true` and if the `DEBUG` conditional compilation flag is set, a breakpoint is triggered after a new entry is added. Application execution may be resumed if running within Xcode.
    ///   - haltApplicationOnNewEntry: If `true`, a `fatalError()` exception is raised after a new entry is added. This may be useful for logs that report critical errors.
    public init(
        title:                      String  = "Log",
        prefix:                     String  = "•",
        suffix:                     String? = nil,
        useNSLog:                   Bool    = false,
        breakpointOnNewEntry:       Bool    = false,
        haltApplicationOnNewEntry:  Bool    = false)
    {
        self.title                      = title
        self.prefix                     = prefix
        self.suffix                     = suffix
        
        self.useNSLog                   = useNSLog
        self.breakpointOnNewEntry       = breakpointOnNewEntry
        self.haltApplicationOnNewEntry  = haltApplicationOnNewEntry
    }
    
    // MARK: - Methods
    
    // MARK: Add Entry
    
    /// Prints a new entry and adds it to the log.
    /// - Parameters:
    ///   - text:       The content of the entry.
    ///   - topic:      The file name, type name, or subsystem from which this entry is logged. Default: The file name.
    ///   - function:   The specific function or task inside the topic from which this entry is logged. Default: The function signature.
    ///   - object:     The runtime object *from which* this entry is logged, which may not necessarily be the object for which this entry is *about* (that would go in the `text`). Default: empty.
    ///   - useNSLog:   If `true`, `NSLog(_:)` is used instead of `print(_:)`. Default: `nil`; this log's `useNSLog` property is used.
    @inlinable
    public mutating func add(_ text:    String  = "",
                             topic:     String  = #file,
                             function:  String  = #function,
                             object:    String  = "",
                             useNSLog:  Bool?   = nil)
    {
        // CHECK: Cocoa Notifications for log observers etc.?
        
        guard !isDisabled else { return }
        
        /// Save the time closest to when this method was called, to avoid any "drift" between processing the arguments and saving the actual entry.
        let time = Date()
        
        // Override the `useNSLog` instance property if specified here.
        let useNSLog = useNSLog ?? self.useNSLog
        
        // Trim the path from topic to only include the file name.
        let topic = ((topic as NSString).lastPathComponent as NSString).deletingPathExtension
        
        // Add the entry to the log.
        
        let newEntry = OKLogEntry(prefix:   self.prefix,
                                  time:     time,
                                  text:     text,
                                  topic:    topic,
                                  function: function,
                                  object:   object)
        
        entries.append(newEntry)
        
        /// Print the entry to the debug console or `NSLog`. Save the printed output to repeat in case of a `fatalError` ahead.
        
        let consoleText = newEntry.print(suffix:    self.suffix,
                                         asCSV:     OKLog.printAsCSV,
                                         useNSLog:  useNSLog)
        
        // Also append the entry to the global unified log. Useful for a log viewer.
        
        OctopusKit.unifiedLog.entries.append(newEntry)
        
        /// Remember the last frame we logged, so that we can highlight the first entries logged during a frame, and insert an empty line between future frames if `printEmptyLineBetweenFrames` is set.
        
        OKLog.lastFrameLogged = OKLog.currentFrame
        
        /// If the `breakpointOnNewEntry` flag is set and we're running in `DEBUG` mode, create a breakpoint programmatically.
        
        #if DEBUG
        if  breakpointOnNewEntry {
            raise(SIGINT)
        }
        #endif
        
        /// If this is a log that displays critical errors, halt the program execution by raising a `fatalError`.
        
        if  haltApplicationOnNewEntry {
            fatalError(consoleText)
        }
        
    }
    
    /// A convenience for adding entries by simply writing `logName(...)` instead of calling the `.add(...)` method.
    @inlinable
    public mutating func callAsFunction(
        _ text:     String  = "",
        topic:      String  = #file,
        function:   String  = #function,
        object:     String  = "",
        useNSLog:   Bool?   = nil)
    {
        self.add(text,
                 topic:     topic,
                 function:  function,
                 object:    object,
                 useNSLog:  useNSLog)
    }
    
    /// Returns a string containing all entries, e.g. for exporting.
    @inlinable
    public func dumpAllEntries(asCSV: Bool = OKLog.printAsCSV) -> String
    {
        var dump: String = ""
        
        if  asCSV { // PERFORMANCE: Check once; not in every iteration.
            for entry in self.entries {
                dump.append("\(entry.description)\n")
            }
        } else {
            for entry in self.entries {
                dump.append("\(entry.csv)\n")
            }
        }
        
        return dump
    }
}

// MARK: - Codable

extension OKLog: Codable {
    enum CodingKeys: String, CodingKey {
        /// ℹ️ Exclude the long and unnecessary `id` strings.
        case title, prefix, suffix
        case useNSLog, isDisabled
        case entries
    }
}
