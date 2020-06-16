//
//  OKLogEntry.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-29-06
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public typealias OctopusLogEntry = OKLogEntry

/// An entry in an `OKLog`.
public struct OKLogEntry: Identifiable, Hashable, CustomStringConvertible {
    
    // MARK: - Properties
    
    /// The prefix of the log, if any, in which this entry was logged. Used for distinguishing entries from different logs. May be emojis or symbols.
    public let prefix:      String
    
    public let time:        Date
    
    /// The number of the scene frame during which this entry was logged. May be `0` if there was no active scene.
    public let frame:       UInt64
   
    /// Specifies whether this entry was logged at the beginning of a new frame of a scene, if any. Used for highlighting new frames in a list of entries.
    public let isNewFrame:  Bool /// CHECK: Rename to `isHighlighted` or `isFirstEntryOfNewFrame`? :p
    
    /// The file name, type name, or subsystem from which this entry was logged.
    public let topic:       String
    
    /// The specific function or task inside the topic from which this entry is logged.
    public let function:    String
    
    /// The runtime object *from which* this entry was logged (not necessarily the object for which this entry is about, which may be mentioned in the `text`).
    public let object:      String
    
    /// The actual event or message that was logged.
    public let text:        String
    
    /// A unique identifier for compatibility with SwiftUI lists.
    public let id         = UUID()
    
    // MARK: - Computed Properties
    
    @inlinable
    public var description: String {
        let text = self.text // CHECK: Trim whitespace?
        
        return ("\(OKLog.formattedTimeString(time: self.time))\(text.isEmpty ? "" : " ")\(text)")
    }
    
    /// Returns a string with the entry's recorded time as formatted by the global `OKLog.timeFormatter`.
    @inlinable
    public var timeString: String {
        OKLog.formattedTimeString(time: self.time)
    }
    
    /// Returns a string with the number of the frame for which this entry was recorded, with an optional marker if this was the first entry for that frame.
    @inlinable
    public var frameString: String {
        "F" + "\(frame)".paddedWithSpace(toLength: OKLog.framePaddingLength) + "\(isNewFrame ? "•" : " ")"
    }
    
    /// Returns a concatenation of `timeString` and `frameString`.
    @inlinable
    public var timeAndFrameString: String {
        timeString + " " + frameString
    }

    /// Returns this entry as a row of CSV-formatted values, that may then be copied into a spreadsheet table such as Numbers. The values are, in order: time, frame, prefix, topic, function, object, text. Separated by `OKLog.csvDelimiter`.
    @inlinable
    public var csv: String {
        let csv = [
            timeString,
            String(frame), // DESIGN: Use a more compact string instead of the formatted `frameString`
            #""\#(prefix    )""#,
            #""\#(topic     )""#,
            #""\#(function  )""#,
            #""\#(object    )""#,
            #""\#(text      )""#,
        ].joined(separator: OKLog.csvDelimiter)
        
        return csv
    }
    
    // MARK: - Initializer
    
    /// Creates a new log entry.
    /// - Parameters:
    ///   - prefix:     The prefix of the log, if any, in which this entry was logged. May be emojis or symbols for distinguishing entries from different logs.
    ///   - time:       The date and time at which this entry is logged.
    ///   - frame:      The current frame count of the current scene, if any, otherwise `0`.
    ///   - isNewFrame: `true` if the entry is logged at the beginning of a new frame in the current scene, if any. Used for highlighting new frames.
    ///   - text:       The content of the entry.
    ///   - topic:      The file name, type name, or subsystem from which this entry is logged. Default: The file name.
    ///   - function:   The specific function or task inside the topic from which this entry is logged. Default: The function signature.
    ///   - object:     The runtime object from which this entry is logged. Default: empty.
    public init(
        prefix:     String  = "",
        time:       Date    = Date(),
        frame:      UInt64  = OKLog.currentFrame,
        isNewFrame: Bool    = OKLog.isNewFrame,
        text:       String  = "",
        topic:      String  = #file,
        function:   String  = #function,
        object:     String  = "")
    {
        self.prefix     = prefix
        self.time       = time
        self.frame      = frame
        self.isNewFrame = isNewFrame
        
        self.text       = text
        self.topic      = topic
        self.function   = function
        self.object     = object
    }
    
    // MARK: - Methods
    
    /// Formats and prints the entry to the runtime debug console or `NSLog`, and returns the formatted string.
    ///
    /// - Parameters:
    ///
    ///   - suffix: The `String` to append to the end of the printed `text`. Omitted if `useNSLog` or `asCSV` is `true`. Default: `nil`
    ///
    ///   - asCSV: If `true` then the entry is printed as a CSV row.
    ///
    ///   See the `OKEntry.csv` property for a list of the values i.e. columns. Does not apply if `useNSLog` is `true`. Default: `false`
    ///
    ///   - useNSLog: If `true`, `NSLog(_:)` is used instead of `print(_:)`. Default: `false`
    ///
    /// - Returns: The `String` that was printed.
    @inlinable @discardableResult
    public func print(suffix:   String? = nil,
                      asCSV:    Bool    = false,
                      useNSLog: Bool    = false) -> String
    {
        // TODO: Print `object`
     
        /// NOTE: Have to disambiguate `Swift.print(...)` in this method. :)
        
        // If there is any text to log, insert a space between the log prefix and the text.
        
        let text: String = self.text.isEmpty ? "" : " \(self.text)"
        
        // Include the suffix, if any, after a space.
        
        let suffix = (suffix != nil) ? " \(suffix!)" : ""
        
        // Duplicate the entry to `NSLog()` if specified, otherwise just `print()` it to the console in our custom format.
        
        var printedText: String = ""
        
        if  useNSLog {
            NSLog("\(prefix) \(topic) \(function)\(text)")
            
        } else {
          
            if  asCSV {
                printedText = self.csv
                
            } else {
                // TODO: Truncate filenames with "…"
                
                if  OKLog.printEmptyLineBetweenFrames && isNewFrame {
                    Swift.print("")
                }
                
                let paddedTitle = prefix.paddedWithSpace(toLength: 8)
                let paddedTopic = topic .paddedWithSpace(toLength: 35)
                 
                if  OKLog.printTextOnSecondLine {
                    printedText = """
                    \(self.timeAndFrameString) \(paddedTitle) \(topic)
                    \(String(repeating: " ", count: 35))\(function)\(text)\(suffix)
                    """
                    
                } else {
                    printedText = "\(self.timeAndFrameString) \(paddedTitle) \(paddedTopic) \(function)\(text)\(suffix)"
                }
            }
        
            Swift.print(printedText)
            
            // NOTE: We cannot rely on the count of entries to determine whether to print an empty line, as there may be multiple logs printing to the debug console, so just add an empty line after all entries. :)
            
            if OKLog.printEmptyLineBetweenEntries { Swift.print() }
        }
        
        return printedText
    }
}

// MARK: - Codable

extension OKLogEntry: Codable {
    enum CodingKeys: String, CodingKey {
        /// ℹ️ Exclude the long and unnecessary `id` strings.
        case prefix, time, frame, isNewFrame
        case topic, function, object, text
    }
}
