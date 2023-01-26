//
//  CMMotionManager+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/23.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//


#if os(iOS)

import CoreMotion

extension CMMotionManager {
    
    /// A convenience method that calls all of the "`stop-`" methods.
    @inlinable
    public func stopAllUpdates() {
        self.stopDeviceMotionUpdates()
        self.stopAccelerometerUpdates()
        self.stopGyroUpdates()
        self.stopMagnetometerUpdates()
    }
}

#endif
