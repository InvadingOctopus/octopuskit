//
//  NSGestureRecognizer+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/22.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

#if canImport(AppKit)

import AppKit

extension NSGestureRecognizer {
    
    /// Replaces `target` and `action`.
    ///
    /// Emulates the `UIGestureRecognizer` method to support code shared with iOS.
    open func addTarget(_ target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
    
    /// Removes `target` and `action` if the current properties match the arguments. If an argument is `nil`, then the corresponding property is also set to `nil`.
    ///
    /// Emulates the `UIGestureRecognizer` method to support code shared with iOS.
    open func removeTarget(_ target: AnyObject?, action: Selector?) {
        // https://developer.apple.com/documentation/uikit/uigesturerecognizer/1624226-removetarget
        
        if target == nil { self.target = nil }
        if action == nil { self.action = nil }
        
        if  let target = target,
            let currentTarget = self.target,
            currentTarget === target
        {
            self.target = nil
        }
        
        if  let action = action,
            let currentAction = self.action,
            currentAction == action
        {
            self.action = nil
        }
    }
    
    /// A dummy property on macOS to support code shared with iOS.
    //    open var cancelsTouchesInView: Bool {
    //        get { return true } // To mimic the default on iOS: https://developer.apple.com/documentation/uikit/uigesturerecognizer/1624218-cancelstouchesinview
    //        set {}
    //    }
}

#endif
