//
//  TurnBasedClampedValueComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components that represent a single numeric value within a specific range, along with a modifier that increases or decreases the value on each turn of a turn-based game.
open class TurnBasedClampedValueComponent <ValueType> : OKTurnBasedComponent
    where ValueType: Numeric & Comparable
{
    /// The value represented by this component. Setting this property will clamp it to `range`.
    open var value: ValueType {
        didSet { if value != oldValue { clamp() } }
    }
    
    /// The acceptable range for `value`.
    open var range: ClosedRange<ValueType>
    
    /// The amount to increase or decrease `value` by on each `updateTurn(turns:)`.
    open var modifierPerTurn: ValueType
    
    public init(range:              ClosedRange<ValueType>,
                initial:            ValueType,
                modifierPerTurn:    ValueType)
    {
        self.range              = range
        self.value              = initial.clamped(to: range)
        self.modifierPerTurn    = modifierPerTurn
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public func clamp() {
        value.clamp(to: range)
    }
    
    @inlinable
    open override func updateTurn(delta turns: Int = 1) {
        value += self.modifierPerTurn * ValueType(exactly: turns)! // CHECK: Any way to avoid this `!`?
        // self.clamp() // No need to clamp here as it should be taken care of by the property's `didSet` observer.
    }
    
}
