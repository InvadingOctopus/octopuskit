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
    
    // NOTE: `SKColor` is an OS-dependent typealias for either `NSColor` or `UIColor`.
    
    // CHECK: Does `SpriteKit` correctly support Display-P3?
    
    /// Shorthand for `withAlphaComponent(_:)`
    ///
    /// Useful for chaining calls to `SKColor` initializers.
    open func withAlpha(_ alpha: CGFloat) -> SKColor {
        self.withAlphaComponent(alpha)
    }
    
    /// Returns a random color in the Display-P3 gamut with RGB values within the specified range, where the maximum saturation is `1.0`.
    @inlinable
    public static func randomP3(in range: ClosedRange<CGFloat>) -> SKColor {
        // TODO: Add rounding parameter
        // TODO: Add generator parameter
        let red   = CGFloat.random(in: range)
        let green = CGFloat.random(in: range)
        let blue  = CGFloat.random(in: range)
        return SKColor(displayP3Red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// Returns a random color in the sRGB gamut with RGB values within the specified range, where the maximum saturation is `1.0`.
    @inlinable
    public static func randomSRGB(in range: ClosedRange<CGFloat>) -> SKColor {
        // TODO: Add rounding parameter
        // TODO: Add generator parameter
        let red   = CGFloat.random(in: range)
        let green = CGFloat.random(in: range)
        let blue  = CGFloat.random(in: range)
        
        #if os(macOS)
        return SKColor(srgbRed: red, green: green, blue: blue, alpha: 1.0)
        #else
        return SKColor(red: red, green: green, blue: blue, alpha: 1.0)
        #endif
    }
    
    // MARK: - Custom Color Collections
    
    /// An array consisting of red, green and blue.
    @inlinable
    public static var primaryColors: [SKColor] {
        [.red, .green, .blue]
    }
    
    /// An array consisting of the *system-dependent* red, green and blue.
    @inlinable
    public static var systemPrimaryColors: [SKColor] {
        [.systemRed, .systemGreen, .systemBlue]
    }
    
    /// Each combination of `(1.0, 0.75, 0.5)` and `(1.0, 1.0, 0.25)`.
    @inlinable
    public static var brightRGBValues: [(red: CGFloat, green: CGFloat, blue: CGFloat)] {
        [(1.0,  0.75, 0.5),
         (1.0,  0.5,  0.75),
         
         (0.75, 1.0,  0.5),
         (0.5,  1.0,  0.75),
         
         (0.75, 0.5,  1.0),
         (0.5,  0.75, 1.0),
         
         (1.0,  1.0,  0.25),
         (0.25, 1.0,  1.0),
         (1.0,  0.25, 1.0)]
    }
    
    /// An array of bright colors.
    ///
    /// Uses the `brightRGBValues` property.
    @inlinable
    public static var brightColors: [SKColor] {
        // TODO: Check and return the system-dependent gamut.
        brightColorsP3
    }
    
    /// An array of bright colors in the Display-P3 gamut.
    ///
    /// Uses the `brightRGBValues` property.
    @inlinable
    public static var brightColorsP3: [SKColor] {
        brightRGBValues.map {
            SKColor(displayP3Red: $0.red, green: $0.green, blue: $0.blue, alpha: 1.0)
        }
    }
    
    /// An array of bright colors in the sRGB gamut.
    ///
    /// Uses the `brightRGBValues` property.
    @inlinable
    public static var brightColorsSRGB: [SKColor] {
        brightRGBValues.map {
            #if os(macOS)
            return SKColor(srgbRed: $0.red, green: $0.green, blue: $0.blue, alpha: 1.0)
            #else
            return SKColor(red: $0.red, green: $0.green, blue: $0.blue, alpha: 1.0)
            #endif
        }
    }
}
