//
//  TurnCounterComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/04.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// ⚠️ Prototype; Incomplete.

import GameplayKit

public final class TurnCounterComponent: OKTurnBasedComponent {
    
    public fileprivate(set) var currentTurn: Int = 0
    public fileprivate(set) var turnsElapsed: Int = 0
    
    public override func didBeginTurn() {
        super.didBeginTurn()
        currentTurn += 1
    }
    
    public override func executeTurn() {
        super.executeTurn()
    }
    
    public override func didEndTurn() {
        super.didEndTurn()
        turnsElapsed += 1
    }
    
}

