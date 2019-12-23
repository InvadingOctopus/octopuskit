//
//  RepeatingClosureComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/25.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// THANKS: eskimo1@apple.com https://forums.developer.apple.com/message/272878

// TODO: Check for strong reference cycles!
// CHECK: Handle integer overflow?

import GameplayKit

/// Executes the supplied closure on every frame update, indefinitely or for a specified number of frames.
///
/// This component calls the supplied closure with a reference to `self`, so that the component's user can refer to the instance properties of this component, such as its entity or co-components, at the calling site before it has finished initialization.
///
/// **Example**
///
///     RepeatingClosureComponent() { $0.entityNode?.zRotation -= 0.01 }
public final class RepeatingClosureComponent: OctopusComponent, OctopusUpdatableComponent {
    
    /// The block of code to be executed every frame by a `RepeatingClosureComponent`.
    ///
    /// - Parameter component: A reference to `self`; the instance of `RepeatingClosureComponent` that this closure will be a property of.
    ///
    ///     You can use this to access the instance properties of this component, such as its associated entity and co-components.
    ///
    ///     **Example:** `component.coComponent(ofType: SpriteKitComponent.self)?.node`
    public typealias ClosureType = (_ component: RepeatingClosureComponent) -> Void
    
    /// The block of code to execute every frame.
    ///
    /// For a description of the closure's signature and parameters, see `RepeatedClosureComponent.ClosureType`.
    public var closure: ClosureType

    /// The number of frames to execute the `closure` for. If `nil`, the `closure` is executed every frame until the `RepeatedClosureComponent` is removed from the entity or the scene's update cycle.
    ///
    /// - NOTE: When this property is modified, the repetition counter is reset to `0`.
    public var framesToStopAfter: UInt64? {
        didSet {
            if  framesToStopAfter != oldValue { // Reset only when the value actually changes.
                self.repetitionCounter = 0
            }
        }
    }
    
    public fileprivate(set) var repetitionCounter: UInt64 = 0
    
    /// - Parameter framesToStopAfter: The number of frames to stop executing this closure after. If `nil`, the closure will be executed every frame until the `RepeatingClosureComponent` is removed from the entity or the scene's update cycle.
    ///
    ///     Frames are counted from when this component is first updated.
    ///
    /// - Parameter closure: The block of code to execute every frame.
    ///
    ///     For a description of the closure's signature and parameters, see `RepeatingClosureComponent.ClosureType`.
    public init(framesToStopAfter: UInt64? = nil,
                closure: @escaping ClosureType)
    {
        self.framesToStopAfter = framesToStopAfter
        self.closure = closure
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        // Have we been specified a limit on the number of repetitions?
        
        if  let framesToStopAfter = self.framesToStopAfter,
            repetitionCounter >= framesToStopAfter
        {
            return
        } else {
            closure(self)
            repetitionCounter += 1
        }
        
    }
    
    /// Resets the repetition counter to `0`. Does not affect anything if `framesToStopAfter` is `nil`.
    public func reset() {
        self.repetitionCounter = 0
    }
}
