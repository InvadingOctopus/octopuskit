//
//  SpeedGoalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/12/14.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import GameplayKit

/// Sets a `GKGoal` on the entity's `AgentComponent` component to reach a specified speed.
///
/// **Dependencies:** `AgentComponent`
public final class SpeedGoalComponent: AgentGoalComponent {
    
    /// The speed which the agent will attempt to reach. Specify `0` to "brake" towards a stop.
    ///
    /// To stop/resume movement without modifying this property, use the `brake()` and `unbrake()` methods.
    ///
    /// The final speed may depend on other factors such as the agent's properties and physics.
    ///
    /// When this value is modified, a new goal is created with the new speed.
    public var targetSpeed: Float {
        didSet {
            if  targetSpeed != oldValue { // Avoid redundancy
                recreateAndReapplyGoal()
            }
        }
    }
    
    /// This flag is set by the `brake()` method and cleared by the `unbrake()` method.
    public fileprivate(set) var isBraking: Bool = false
    
    public init(targetSpeed: Float = 10.0,
                goalWeight: Float = 1.0,
                isPaused: Bool = false)
    {
        self.targetSpeed = targetSpeed
        super.init(goalWeight: goalWeight, isPaused: isPaused)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createGoal() -> GKGoal? {
        // If `isBraking`, sets a goal to decrease the agent's speed towards `0`.
        return GKGoal(toReachTargetSpeed: isBraking ? 0 : targetSpeed)
    }
    
    /// Creates a new goal to set agent's target speed to `0` without modifying this component's `targetSpeed` property.
    ///
    /// Sets the `isBraking` flag, and does nothing if that flag is already set or if the component `isPaused`.
    public func brake() {
        guard !isPaused && !isBraking else { return }
        isBraking = true
        recreateAndReapplyGoal()
    }
    
    /// If `isBraking`, creates a new goal to set the agent's speed back to the `targetSpeed` property.
    ///
    /// Clears the `isBraking` flag, and does nothing if that flag is not set or if the component `isPaused`.
    public func unbrake() {
        guard !isPaused && isBraking else { return }
        isBraking = false
        recreateAndReapplyGoal()
    }
}
