//
//  DelayedClosureComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/31.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// THANKS: eskimo1@apple.com https://forums.developer.apple.com/message/272878

// TODO: Check for strong reference cycles!

import GameplayKit

/// Executes the supplied closure once, after the specified seconds have passed.
///
/// To reuse, call `reset()`.
///
/// This component calls the supplied closure with a reference to `self`, so that the component's user can refer to the instance properties of this component, such as its entity or co-components, at the calling site before it has finished initialization.
///
/// **Example**
///
///     DelayedClosureComponent(executionDelay: 60.0) {
///         $0.coComponent(ofType: SpriteKitComponent.self)?.node
///     }
class DelayedClosureComponent: OctopusComponent, OctopusUpdatableComponent {
    
    /// The block of code to be executed by a `DelayedClosureComponent`.
    ///
    /// - Parameter component: A reference to `self`; the instance of `DelayedClosureComponent` that this closure will be a property of.
    ///
    ///     You can use this to access the instance properties of this component, such as its associated entity and co-components.
    ///
    ///     **Example:** `component.coComponent(ofType: SpriteKitComponent.self)?.node`
    public typealias ClosureType = (_ component: DelayedClosureComponent) -> Void
    
    /// The block of code to execute after the time specified by `executionDelay` has passed.
    ///
    /// The closure is executed only once. It may be repeated by calling `reset()`.
    ///
     /// For a description of the closure's signature and parameters, see `DelayedCustomClosureComponent.ClosureType`.
    public var closure: ClosureType
    
    // The duration in seconds to wait before executing the closure.
    public var executionDelay: TimeInterval
    
    public fileprivate(set) var secondsElapsed: TimeInterval = 0
    public fileprivate(set) var didExecuteClosure = false
    
    /// - Parameter executionDelay: The duration in seconds (or fractions of seconds) to wait before executing the closure.
    /// - Parameter closure: The block of code to execute after the time specified by `executionDelay` has passed.
    ///
    ///     For a description of the closure's signature and parameters, see `DelayedClosureComponent.ClosureType`.
    public init(executionDelay: TimeInterval,
                closure: @escaping ClosureType)
    {
        self.executionDelay = executionDelay
        self.closure = closure
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func update(deltaTime seconds: TimeInterval) {

        guard !didExecuteClosure else { return }
        
        secondsElapsed += seconds
        
        if secondsElapsed >= executionDelay {
            closure(self)
            didExecuteClosure = true
            // CHECK: Remove this component from entity after execution?
        }
    }
    
    /// Resets the component's timer so that it executes the closure again after its specified delay.
    open func reset() {
        self.secondsElapsed = 0
        self.didExecuteClosure = false
    }
}
