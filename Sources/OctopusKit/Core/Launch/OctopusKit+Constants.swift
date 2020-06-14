//
//  OctopusKit+Constants.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/15.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

extension OctopusKit {
    
    /// Encapsulates global constants that may be used by various parts of the OctopusKit.
    public enum Constants {
        
        /// A collection of strings for the names of entities etc., to avoid hard-coding text and prevent typos during searches or comparisons etc.
        public enum Strings {
            public static let gameCoordinatorEntityName = "Game Coordinator Entity"
        }
        
        /// Various timings and durations.
        public enum Time {
            /// Represents the ideal time (in fractions of a second) per frame, in a 60 frames-per-second system: `1 / 60 = 0.01666666667`
            public static let timePerFrameIn60FPS: TimeInterval = 0.01666666667 // 1 / 60
        }
    }
}
