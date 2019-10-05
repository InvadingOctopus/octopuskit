//
//  SKColor+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Choice between sRGB and Display P3 color gamuts.
// TODO: More color collections

import SpriteKit

extension SKColor {
    
    // Extend `SKColor` so it applies to both `UIColor` and `CGColor`.
    
    /// Shorthand for `withAlphaComponent(_:)`
    ///
    /// Useful for chaining calls to `SKColor` initializers.
    open func withAlpha(_ alpha: CGFloat) -> SKColor {
        return self.withAlphaComponent(alpha)
    }
    
    // MARK: - Custom Color Collections
    
    /// A collection consisting of red, green and blue.
    public static var primaryColors: [SKColor] {
        return [.red, .green, .blue]
    }
    
    /// A collection of bright colors in the Display-P3 gamut.
    public static var brightColors: [SKColor] {
        // CHECK: Does `SpriteKit` correctly support Display-P3?
        return [SKColor(displayP3Red: 1.0, green: 0.75, blue: 0.5, alpha: 1.0),
                SKColor(displayP3Red: 0.5, green: 1.0, blue: 0.75, alpha: 1.0),
                SKColor(displayP3Red: 0.75, green: 0.5, blue: 1.0, alpha: 1.0),
                SKColor(displayP3Red: 1.0, green: 1.0, blue: 0.25, alpha: 1.0),
                SKColor(displayP3Red: 0.25, green: 1.0, blue: 1.0, alpha: 1.0),
                SKColor(displayP3Red: 1.0, green: 0.25, blue: 1.0, alpha: 1.0)
        ]
    }
    
}
