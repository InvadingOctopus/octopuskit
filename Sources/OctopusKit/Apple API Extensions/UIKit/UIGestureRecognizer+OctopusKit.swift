//
//  UIGestureRecognizer+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/19.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import UIKit

extension UIGestureRecognizer {
    
    /// Specifies whether the recognizer is currently processing a gesture.
    ///
    /// Returns `true` when the gesture recognizer's `state` is `.began` or `.changed`.
    ///
    /// Returns `false` when the `state` is `.possible`, `.cancelled`, `.failed` or `.ended`.
    ///
    /// Use this flag to avoid unncessary processing in gesture-controlled objects.
    public var isHandlingGesture: Bool {
        switch self.state {
            // CHECK: Is this all the correct states?
            
        case .began, .changed: // CHECK: Should this include `.ended?`
            return true
            
        case .possible, .cancelled, .failed, .ended:
            return false
        }
    }
}
