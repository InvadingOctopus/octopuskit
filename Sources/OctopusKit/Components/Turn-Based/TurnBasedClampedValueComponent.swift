//
//  TurnBasedClampedValueComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components that represent a single numeric value within a specific range, along with a modifier that increases or decreases the value on each turn of a turn-based game. Changes are reported for subclasses to act upon.
///
/// For example, an `EnergyComponent` may inherit from this component, implement `didChange(from:difference:)` and call a `BubbleEmitterComponent` to display changes in a character's energy.
open class TurnBasedClampedValueComponent <ValueType> : ClampedValueComponent <ValueType>,
    TurnBased
    where ValueType: Numeric & Comparable
{

    /// The amount to increase or decrease `value` by on each `updateTurn(turns:)`.
    open var modifierPerTurn: ValueType
    
    public init(range:              ClosedRange<ValueType>,
                initial:            ValueType,
                modifierPerTurn:    ValueType)
    {
        self.modifierPerTurn = modifierPerTurn
        
        super.init(range:   range,
                   initial: initial)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    /// Applies the `modifierPerTurn` multiplied by the number of `turns`, to the `value`, then clamps the `value` to the `range`.
    @inlinable
    open func updateTurn(delta turns: Int = 1) {
        guard modifierPerTurn != 0 else { return } /// Avoid unnecessary modifications and `didSet` triggers.
        value += self.modifierPerTurn * ValueType(exactly: turns)! /// CHECK: Any way to avoid this `!`?
        // self.clamp() // No need to clamp here as it should be taken care of by the property's `didSet` observer.
    }

    // MARK: - Abstract
    
    /// The following properties and methods are stubs to give the consistency of `override`, as for other subclasses of `OKTurnBasedComponent`, which this component does not inherit from, so it can avoid duplicating all the `didSet` and `didChange` code in `ClampedValueComponent`
    //

    open var disallowBeginTurn  = false
    open var disallowUpdateTurn = false
    open var disallowEndTurn    = false
    
    /// Abstract; override in subclass.
    open func beginTurn (delta turns: Int) {}
    
    /// Abstract; override in subclass.
    open func endTurn   (delta turns: Int) {}
    
}
