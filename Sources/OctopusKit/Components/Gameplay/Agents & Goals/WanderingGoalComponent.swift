//
//  WanderingGoalComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/31.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Add stopping behavior?

import GameplayKit

/// Sets a `GKGoal` on the entity's `OKAgent2D` component to wander around.
///
/// **Dependencies:** `OKAgent2D`
public final class WanderingGoalComponent: OKAgentGoalComponent {
    
    /// The forward speed for the agent to maintain while turning at random.
    ///
    /// When this value is modified, a new goal is created with the new speed.
    public var speedToMaintain: Float {
        didSet {
            if  speedToMaintain != oldValue { // Avoid redundancy
                recreateAndReapplyGoal()
            }
        }
    }

    public init(speedToMaintain: Float = 5.0,
                goalWeight: Float = 1.0,
                isPaused: Bool = false)
    {
        self.speedToMaintain = speedToMaintain
        super.init(goalWeight: goalWeight, isPaused: isPaused)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createGoal() -> GKGoal? {
        return GKGoal(toWander: speedToMaintain)
    }
}
