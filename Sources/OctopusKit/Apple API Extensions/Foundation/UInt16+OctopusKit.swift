//
//  UInt16+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/23.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation

public extension UInt16 {
    
    // MARK: NSEvent.keyCode
    
    // TODO: Find a more reliable, platform-independent way! `NSUpArrowFunctionKey` etc. do not match the `NSEvent.keyCode` values :(
    
    static let arrowLeft  = UInt16(123)
    static let arrowRight = UInt16(124)
    static let arrowDown  = UInt16(125)
    static let arrowUp    = UInt16(126)
}
