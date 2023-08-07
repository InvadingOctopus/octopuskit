//
//  TimeComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/27.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import GameplayKit

/// Tracks the number of seconds elapsed since adding to an entity and provides other timekeeping.
open class TimeComponent: OKComponent, RequiresUpdatesPerFrame {
    
    /// Represents the time elapsed in seconds since the component was added to an entity.
    ///
    /// Not updated when the `isPaused` is set to `true`. The validity of this value may depend on the `update(_:)` method of the parent scene.
    public fileprivate(set) var secondsElapsed: TimeInterval = 0
    
    public fileprivate(set) var secondsElapsedRounded: Int = 0 // CHECK: Does this actually help with performance, not having to cast to Int every time it's needed as one?
    
    /// Represents the fraction of a second elapsed since the component recorded a full second.
    public fileprivate(set) var secondsElapsedSincePreviousSecond: TimeInterval = 0
    
    /// Set to `true` for *one frame* after the component has recorded a full second.
    ///
    /// This flag is always set to `false` on the next frame, whether `isPaused` is `true` or not.
    public fileprivate(set) var hasNewSecondElapsed: Bool = false
    
    /// When `true`, prevents the timekeeping properties from being updated every frame.
    public var isPaused = false
    
    public override init() {
        super.init()
    }
    
    /// Creates a `TimeComponent` with a preset value for `secondsElapsed`.
    ///
    /// Useful for syncing with other clocks.
    public init(secondsElapsed: TimeInterval) {
        
        if  secondsElapsed < 0 {
            OKLog.logForWarnings.debug("secondsElapsed = \(secondsElapsed), negative")
        }
        
        self.secondsElapsed = secondsElapsed
        self.secondsElapsedRounded = self.secondsElapsed > 1 ? Int(self.secondsElapsed) : 0
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func update(deltaTime seconds: TimeInterval) {
        
        hasNewSecondElapsed = false
        
        guard !isPaused else { return }
        
        // Count the seconds.
        
        secondsElapsed += seconds
        secondsElapsedSincePreviousSecond += seconds
        
        if  secondsElapsedSincePreviousSecond >= 1.0 {
            secondsElapsedRounded += 1
            secondsElapsedSincePreviousSecond = 0
            hasNewSecondElapsed = true
        }

    }
    
    /// Sets the elapsed duration to `0` and clears the `isPaused` flag.
    public func reset() {
        secondsElapsed = 0
        secondsElapsedRounded = 0
        secondsElapsedSincePreviousSecond = 0
        hasNewSecondElapsed = false
        isPaused = false
    }
    
    deinit {
        OKLog.logForDeinits.debug("secondsElapsed = \(secondsElapsed)")
    }
}

// MARK: - TimeComponentRecord

/// Provides a log for the users of a `TimeComponent` to keep track of whether they executed any actions during a given second.
///
/// This may be necessary since the `TimeComponent.secondsElapsedRounded` value will remain unchanged as the `update(deltaTime:)` method is called many times in a single second. This helper object reduces the boilerplate code required to execute a specific set of actions only once during a specific second in time.
public struct TimeComponentRecord {
    
    // TODO: Improve naming and descriptions.
    
    /// A dictionary that should record `true` for a value representing a given second, if any tasks was executed during that second.
    public var record: [Int : Bool] = [:]
    
    public init() {}
    
    @inlinable
    public func didExecuteActions(duringSecond second: Int) -> Bool {
        record[second] == true
    }
    
    /// Checks a `timeComponent` for a specific time and sets a `true` flag for the specified time in the record, to indicate not to perform the same actions again during that second. Call this method in an `if` conditional statement during an `update(deltaTime:)` method to execute specific actions once at specific times.
    /// - Important: If a task fails and/or has to be performed again during the same second, set `record` to `false` for that time after calling this method.
    /// - Returns: `true` if the number of seconds elapsed in the `timeComponent` are equal to `secondsElapsed` and there are no actions recorded for that second.
    public mutating func checkTimeAndSetFlag(forSecondsElapsed seconds: Int, in timeComponent: TimeComponent) -> Bool {
        if  record[seconds] != true
            && timeComponent.secondsElapsedRounded == seconds
        {
            record[seconds] = true
            return true
        } else {
            return false
        }
    }
    
}
