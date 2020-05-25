//
//  OKLogViewer.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020-05-21
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import OctopusUI

// MARK: - Log Binder

/// A container for a collection of logs.
public struct OKLogBinder: View {
    
    let logs: [OKLog]
    
    @Binding var showingLogs:      Bool
    
    @State private var selectedLogIndex  = 0
    @State private var showingShareSheet = false
    
    private var selectedLog: OKLog {
        self.logs[selectedLogIndex]
    }
    
    private var selectedLogJSON: String {
        let encoder = JSONEncoder()
        let data    = try! encoder.encode(logs[selectedLogIndex])
        return String(data: data, encoding: .utf8)!
    }
    
    public init(logs: [OKLog],
                showingLogs: Binding<Bool>)
    {
        self.logs = logs
        self._showingLogs = showingLogs
    }
    
    public var body: some View {
        
        // TODO: Different layout on macOS/tvOS
        
        VStack {
            logChooser
                .padding()
            
            OKLogViewer(logs[selectedLogIndex])
            buttons
                .padding()
        }
        .accentColor(.purple)
    }
    
    var logChooser: some View {
        CollapsableGroup(label: Text("Log: \(selectedLog.title)")) {
            
            HStack() {
                ForEach(0 ..< self.logs.endIndex) { index in
            
                    Text(self.logs[index].prefix)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(self.selectedLogIndex == index ? .accentColor : .clear)
                                .opacity(0.5)
                        )
                        .onTapGesture {
                            self.selectedLogIndex = index
                        }
                }
            }
        }
    }
    
    var buttons: some View {
        HStack {
            
            Button(action: { self.showingLogs.toggle() }) {
                Text("Close")
            }
            
            Spacer()
            
            Button(action: { self.showingShareSheet.toggle() }) {
                Symbol(macOS: "􀈂", iOS: "square.and.arrow.up")
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [self.selectedLogJSON])
            }
        }
    }
    
}

// MARK: - Log Viewer

/// Displays a single log with filtering controls.
public struct OKLogViewer: View {
    
    // TODO: Filtering options
    
    let log: OKLog
    
    public init(_ log: OKLog) {
        self.log = log
    }
    
    public var body: some View {
        // TODO: Filtering controls
        OKLogList(log)
    }
}

// MARK: - Log List

/// Lists all the entries in a log.
public struct OKLogList: View {
    
    let log: OKLog
    
    public init(_ log: OKLog) {
        self.log = log
    }
    
    public var body: some View {
        List(log.entries) { entry in
            OKLogEntryView(entry)
        }
    }
}

// MARK: - Log Entry

/// A persistent flag to changing the color of alternating rows for better readability.
fileprivate var rowColorAlternator: Bool = false

/// Displays a single log entry.
public struct OKLogEntryView: View {
    
    let entry: OKLogEntry
    
    @State private var selected: Bool = false
    
    var rowColor: Color {
        rowColorAlternator.toggle()
        return (rowColorAlternator ? Color(OSColor.systemIndigo) : Color.clear)
    }
    
    var headerColor: Color {
        #if !os(macOS)
        return entry.isNewFrame ? .red
            : self.selected ? Color(OSColor.secondaryLabel)
                : Color(OSColor.tertiaryLabel)
        #else
        return entry.isNewFrame ? .red
            : self.selected ? Color(OSColor.secondaryLabelColor)
                : Color(OSColor.tertiaryLabelColor)
        #endif
    }
    
    public init(_ entry: OKLogEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack(alignment: .firstTextBaseline) { // Header
                
                HStack {
                    title.layoutPriority(0)
                    time .layoutPriority(1)
                }
                .layoutPriority(1)
                
                topic.font(.caption)
                
            }
            .lineLimit(1)
            .padding(2)
            .foregroundColor(headerColor)
            
            entryText
            
        }
        .font(.system(size: 13))
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(self.selected ? .accentColor : self.rowColor)
                .opacity(self.selected ? 0.4 : 0.1)
        )
    }
    
    // MARK: Subviews
    
    /// Log Title
    var title: some View {
        Text(entry.prefix)
            .opacity(self.selected ? 1 : 0.75)
    }
    
    /// Time and Frame
    var time: some View {
        HStack {
            Text("\(entry.time, formatter: OKLog.timeFormatter)")
                .font(.caption)
                .layoutPriority(1)
            
            Text("F\(String(entry.frame).paddedWithSpace(toLength: 5))")
                .font(.caption)
                .layoutPriority(2)
        }
        .lineLimit(1)
        .truncationMode(.head)
    }
    
    /// Topic and Function
    var topic: some View {
        HStack {
            Text(entry.topic)
                .fontWeight(.bold)
                .truncationMode(.head)
            
            Spacer()
            
            Text(entry.function)
                .fontWeight(.bold)
                .truncationMode(.middle)
        }
    }
    
    /// Entry
    var entryText: some View {
        Text(entry.text)
            .font(.system(size: 13, weight: .medium, design: .monospaced))
            .lineLimit(self.selected ? nil : 2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(2)
            .layoutPriority(1)
            .foregroundColor(self.selected ? .primary : .secondary)
            .onTapGesture {
                self.selected.toggle()
            }
    }

    
}

// MARK: -

/*
struct OKLogBinder_Previews: PreviewProvider {
    static var previews: some View {
        let log = try! JSONDecoder().decode(OKLog.self, from: previewLog.data(using: .utf8)! )
        return LogBinder(logs: [log])
    }
}
*/
