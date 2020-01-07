//
//  MotionManagerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/13.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

#if os(iOS) // CHECK: Include tvOS?

import CoreMotion

/// Retains a reference to a `CMMotionManager` to be used by other components.
public final class MotionManagerComponent: OKComponent {

    public var motionManager: CMMotionManager? // CHECK: Should this be weak?
    
    /// If the `motionManager` argument is `nil` then `OctopusKit.motionManager` will be used.
    ///
    /// - Important: As per Apple documentation: An app should create only a single instance of the `CMMotionManager` class, as multiple instances of this class can affect the rate at which data is received from the accelerometer and gyroscope.
    public init(motionManager: CMMotionManager? = nil) {
        self.motionManager = motionManager ?? OctopusKit.motionManager
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

#else
    
public final class MotionManagerComponent: iOSExclusiveComponent {}
    
#endif
