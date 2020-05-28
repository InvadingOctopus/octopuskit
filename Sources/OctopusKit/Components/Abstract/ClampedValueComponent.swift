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
    /// DESIGN: This is not a subclass of `ValueComponent` to simplify `didSet` semantics and order of execution, and possibly also improve performance.
    
    // CHECK: Should there be a `willChange(to:)` or would that just be unnecessary and reduce performance?
    
    /// The value represented by this component. Setting this property will clamp it to `range`, then `didChange(from:)` will be called *only if* the final result is different from the previous value.
    open var value: ValueType {
        didSet {
            /// ❕ NOTE: `didChange(from:)` must be called **only if** there is no change in the value **after** clamping.
            
            // #1: First, see if there is any difference at all in the new value assigned to the property.
            
            if  value != oldValue {
                
                // #2: Next, check if the new value be outside the range.
                
                /// ❕ NOTE: We perform the checks and clamping inside this observer, as calling out to other functions to perform the clamping may trigger multiple `didSet` and `didChange(from:)` events.
                
                // See comments in `clamp()`
                
                if !range.contains(value) {
                    value = min(max(value, range.lowerBound), range.upperBound)
                }
                
                // #3: Finally, let any subclasses handle the change, *if* there has actually been any change after the clamping.
                
                if  value != oldValue {
                    self.didChange(from: oldValue)
                }
            }
        }
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
    
    /// Clamp the `value` to the `range`, if needed. If the value gets modified as a result of the clamping, `didChange(from:)` will be called.
    @inlinable
    public func clamp() {
        
        /// 🐛 TODO: REPORT: BUG? 20200528A: APPLEBUG? If we call `value.clamp(to: range)`, which is a mutating function extension for `Comparable`, then the `didSet` property observer may be called multiple times, **even if** `Comparable.clamp(to:)` returns without modifying anything!
        
        /// To avoid that, we replicate the implementation of `Comparable.clamp(to:)` here. Who knows, this may even improve performance :P
        
        if !range.contains(value) {
            value = min(max(value, range.lowerBound), range.upperBound)
        }
    }
    
    // MARK: - Abstract

    /// Abstract; Subclasses may implement this method to respond to changes. Called by the `value` property's `didSet` observer.
    @inlinable
    open func didChange(from oldValue: ValueType) {}
    
}

