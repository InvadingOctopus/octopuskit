//
//  TimeDependentClosureComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/23.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Executes the supplied closure on every frame update, passing the total time and the delta time between updates to the closure.
///
/// This component calls the supplied closure with a reference to `self`, so that the component's user can refer to the instance properties of this component, such as its entity or co-components, at the calling site before it has finished initialization.
///
/// **Example**
///
///     TimeDependentClosureComponent() { component, totalTime, deltaTime in
///         component.entityNode?.position  =  CGPoint(x: 50 * sin(totalTime), y: 50 * cos(totalTime))
///     }
public final class TimeDependentClosureComponent: OKComponent, RequiresUpdatesPerFrame {
    
    /// The block of code to be executed every frame by a `TimeDependentClosureComponent`.
    ///
    /// - Parameter component: A reference to `self`; the instance of `TimeDependentClosureComponent` that this closure will be a property of.
    ///
    ///     You can use this to access the instance properties of this component, such as its associated entity and co-components.
    ///
    ///     **Example:** `component.coComponent(ofType: NodeComponent.self)?.node`
    ///
    /// - Parameter totalTime: The seconds elapsed since this component was initialized.
    ///
    /// - Parameter deltaTime: The seconds between this update and the previous update.
    public typealias ClosureType = (_ component: TimeDependentClosureComponent,
                                    _ totalTime: TimeInterval,
                                    _ deltaTime: TimeInterval) -> Void
    
    /// The block of code to execute every frame.
    ///
    /// For a description of the closure's signature and parameters, see `TimeDependentClosureComponent.ClosureType`.
    public var closure: ClosureType

    /// The seconds elapsed since this component was initialized.
    public fileprivate(set) var totalTime: TimeInterval = 0
    
    public var isPaused: Bool = false
    
    /// - Parameter closure: The block of code to execute every frame.
    ///
    ///     For a description of the closure's signature and parameters, see `TimeDependentClosureComponent.ClosureType`.
    public init(_ closure: @escaping ClosureType) {
        self.closure = closure
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func update(deltaTime seconds: TimeInterval) {
        guard !isPaused else { return }
        totalTime += seconds
        closure(self, totalTime, seconds)
    }
    
}
