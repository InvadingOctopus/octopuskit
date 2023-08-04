//
//  OKConfiguration.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020-03-31
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import OctopusCore

public struct OKConfiguration {
    
    #if os(macOS)
    
    /// If `true` (default), the application's default menu bar is modified to have menu names and items suitable for games.
    ///
    /// This setting is read when `OKViewController` presents its view.
    public var modifyDefaultMenuBar: Bool = true
    
    #endif
    
    /// A dictionary of flags for SpriteKit, mainly for debugging.
    ///
    /// `debugDrawStats_SKContextType`: When `true`, prints "Metal" or "OpenGL" in the corner of the `SKView` depending on which renderer is active.
    ///
    /// See Apple Technical Note TN2451: SpriteKit Debugging Guide: https://developer.apple.com/library/archive/technotes/tn2451/_index.html#//apple_ref/doc/uid/DTS40017609-CH1-SHADERCOMPILATION
    @OKUserDefault(key: "SKDefaults", defaultValue: [:])
    public static var flagsForSpriteKit: [String: Any]
    
}
