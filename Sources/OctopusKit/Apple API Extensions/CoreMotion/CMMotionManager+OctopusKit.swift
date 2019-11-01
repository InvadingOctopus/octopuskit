//
//  CMMotionManager+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/23.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import CoreMotion

#if canImport(UIKit)

extension CMMotionManager {
    
    /// A convenience method that calls all of the "`stop-`" methods.
    open func stopAllUpdates() {
        self.stopDeviceMotionUpdates()
        self.stopAccelerometerUpdates()
        self.stopGyroUpdates()
        self.stopMagnetometerUpdates()
    }
}

#endif
