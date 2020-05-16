//
//  ClampedValueComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components that represent a single numeric value within a specific range.
open class ClampedValueComponent <ValueType> : OKComponent
    where ValueType: Numeric & Comparable
{
    /// The value represented by this component. Setting this property will clamp it to `range`.
    open var value: ValueType {
        didSet { if value != oldValue { clamp() } }
    }
    
    /// The permitted range for `value`.
    open var range: ClosedRange<ValueType>
    
    public init(range:      ClosedRange<ValueType>,
                initial:    ValueType)
    {
        self.range = range
        self.value = initial.clamped(to: range)
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public func clamp() {
        value.clamp(to: range)
    }
    
}
