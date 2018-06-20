//
//  OctopusHighScoreChart.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-18.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Test
// TODO: Improve
// TODO: Complete support for more than 10 entries.

import UIKit
import CoreData

public struct OctopusHighScore: Equatable, Comparable {
    
    public let name: String
    public let score: Int
    
    /// The date and time of achievement.
    public let date: Date // CHECK: Should this be optional?
    
    public init (name: String, score: Int, date: Date) {
        self.name = name
        self.score = score
        self.date = date
    }
    
    public init(name: String, score: Int) {
        self.init(name: name, score: score, date: Date())
    }
    
    /// Equatable
    public static func == (left: OctopusHighScore, right: OctopusHighScore) -> Bool {
        return (left.name == right.name
            && left.score == right.score
            && left.date == right.date)
    }
 
    /// Comparable
    public static func < (left: OctopusHighScore, right: OctopusHighScore) -> Bool {
        return left.score < right.score
    }
    
}

public final class OctopusHighScoreChart {
    
    public fileprivate(set) var entries: [OctopusHighScore]
    
    public let maxEntries: Int
    public static var maxEntriesDefault = 10
    
    public final class var defaultLocalEntries: [OctopusHighScore] {
        return [
            OctopusHighScore(name: "MSA", score: 100000, date: Date()),
            OctopusHighScore(name: "GSA", score: 90000, date: Date.distantPast),
            OctopusHighScore(name: "MAF", score: 80000, date: Date.distantPast),
            OctopusHighScore(name: "DWJ", score: 70000, date: Date.distantPast),
            OctopusHighScore(name: "EK7", score: 60000, date: Date.distantPast),
            OctopusHighScore(name: "AKN", score: 50000, date: Date.distantPast),
            OctopusHighScore(name: "KAI", score: 40000, date: Date.distantPast),
            OctopusHighScore(name: "SAI", score: 30000, date: Date.distantPast),
            OctopusHighScore(name: "RFA", score: 20000, date: Date.distantPast),
            OctopusHighScore(name: "RVN", score: 10000, date: Date.distantPast)
        ]
    }

    // MARK: -
    
    public var latestEntry: OctopusHighScore? {
        guard entries.count > 0 else { return nil }
        let sortedChart = entries.sorted() { $0.date.compare($1.date) == ComparisonResult.orderedDescending }
        return sortedChart[0]
    }
    
    // MARK: - Factory
    
    public class func resetLocalChartToDefaultHighScores() {
        let defaultChart = OctopusHighScoreChart(entries: defaultLocalEntries)
        defaultChart.saveEntriesToLocalChart()
    }
    
    public class func loadLocalChart() -> OctopusHighScoreChart {
        
        guard let managedObjectContext = OctopusKit.shared?.managedObjectContext else {
            fatalError()
        }
        
        var loadedEntries = [HighScore]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HighScore")
        
        do {
            
            loadedEntries = try managedObjectContext.fetch(fetchRequest) as! [HighScore]
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let entries = loadedEntries.map { OctopusHighScore(name: $0.name!, score: Int($0.score), date: $0.date!) }
        
        let sortedEntries = entries.sorted(by: >)
        
        return OctopusHighScoreChart(entries: sortedEntries)
    }
    
    // MARK: -
    
    public init(maxEntries: Int = OctopusHighScoreChart.maxEntriesDefault) {
        self.entries = []
        self.maxEntries = maxEntries
        
        // Populate the list with the default chart, up to the maximum applicable amount of entries.
        self.entries += OctopusHighScoreChart.defaultLocalEntries.prefix(min(OctopusHighScoreChart.defaultLocalEntries.count, self.maxEntries)).sorted(by: >)
    }
    
    /// Entries will be sorted in descending order.
    public init(entries: [OctopusHighScore]) {
        self.entries = entries.sorted(by: >)
        self.maxEntries = entries.count
    }
    
    // MARK: Chart Management
    
    /// Returns the position the score achieved on the local high score chart, or 'nil' if it was ineligible.
    public func addEntry(_ entry: OctopusHighScore) -> Int? {
        
        if let position = checkChartPosition(for: entry.score) {
            
            entries.insert(entry, at: position - 1)
            
            // Remove the entry that got pushed out of the bottom.
            
            if entries.count > maxEntries {
                for _ in 0..<(entries.count - maxEntries) {
                    entries.remove(at: maxEntries)
                }
            }
            
            saveEntriesToLocalChart(entries)
            return position + 1 // Account for zero-indexing.
        }
        return nil
    }
    
    /// Returns position (not the array index) if the score is eligible to appear on the local high score chart.
    public func checkChartPosition(for score: Int) -> Int? {
        // TODO: Swift 4
        
        for position in 0..<entries.count {
            if score > entries[position].score {
                return position + 1 // Account for zero-indexing.
            }
        }
        return nil
    }
    
    // MARK: - Storage
    
    public func saveEntriesToLocalChart() {
        saveEntriesToLocalChart(self.entries)
    }
    
    public func saveEntriesToLocalChart(_ entries: [OctopusHighScore]) {
        // TODO: Add error checking and maybe a counter for total number of entries.
        
        deleteLocalChart()
        
        guard let managedObjectContext = OctopusKit.shared?.managedObjectContext else { return }
        
        for entry in entries {
            
            if let entryToSave = NSEntityDescription.insertNewObject(forEntityName: "HighScore", into: managedObjectContext) as? HighScore {
                
                //            let entity = NSEntityDescription.entityForName("HighScore", inManagedObjectContext: managedObjectContext)
                //            let highScore = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
                
                entryToSave.name = entry.name
                entryToSave.score = Int64(entry.score)
                entryToSave.date = entry.date
                
            }
            
        }
        
        do {
            try OctopusKit.shared?.managedObjectContext?.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
    public func deleteLocalChart() {
        // TODO: Duplicate-entry removal should be handled more gracefully than this! Instead, try to retreive entries by position and then overwriting them in the save fucntions.
        
        guard let managedObjectContext = OctopusKit.shared?.managedObjectContext else { return }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"HighScore")
        
        if let results = (try? managedObjectContext.fetch(fetchRequest)) as? [HighScore] {
            for entry in results {
                managedObjectContext.delete(entry)
            }
        }
    }
}
