//
//  ValueComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/28.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// A base class for components that represent a single value and report its changes for subclasses to act upon.
///
/// For example, a subclass may call a `BubbleEmitterComponent` to display changes in the value.
open class ValueComponent <ValueType> : OKComponent
    where ValueType: Comparable
{
    
    // CHECK: Should there be a `willChange(to:)` or would that just be unnecessary and reduce performance?
    
    /// The value represented by this component. `didChange(from:)` is called when this property changes to a different value.
    open var value: ValueType {
        didSet {
            if  value != oldValue {
                self.didChange(from: oldValue)
            }
        }
    }
    
    public init(initial: ValueType)
    {
        self.value = initial
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Abstract
    
    /// Abstract; Subclasses may implement this method to respond to changes. Called by the `value` property's `didSet` observer.
    @inlinable
    open func didChange(from oldValue: ValueType) {}
    
}
