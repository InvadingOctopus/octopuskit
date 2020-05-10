//
//  OctopusKit+Global.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/03
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

// MARK: Global Helper Functions

/// Runs the supplied closure only if the `DEBUG` compilation flag is set. Marks temporary debugging code for easy removal when no longer needed. Set a single breakpoint inside this function's definition to pause execution on every call.
///
/// **Example**: `💩 { print("some info") }`
///
@inlinable
public func 💩(_ closure: () -> Void) {
    #if DEBUG
    closure()
    #endif
}

// MARK: SpriteKit Flags

public extension OctopusKit {

    /// A dictionary of flags for SpriteKit, mainly for debugging.
    ///
    /// `debugDrawStats_SKContextType`: When `true`, prints "Metal" or "OpenGL" in the corner of the `SKView` depending on which renderer is active.
    ///
    /// See Apple Technical Note TN2451: SpriteKit Debugging Guide: https://developer.apple.com/library/archive/technotes/tn2451/_index.html#//apple_ref/doc/uid/DTS40017609-CH1-SHADERCOMPILATION
    @OKUserDefault(key: "SKDefaults", defaultValue: [:]) var flagsForSpriteKit: [String: Any]

}
