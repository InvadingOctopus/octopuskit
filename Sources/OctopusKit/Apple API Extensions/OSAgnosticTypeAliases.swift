//
//  OSAgnosticTypeAliases.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/1.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  Wherever the AppKit (macOS) "NS-" and UIKit (iOS, iPadOS, tvOS) "UI-" variants of an object can be interchanged, OctopusKit uses an OS-agnostic type alias to reduce the amount of duplicated code.

import Foundation

#if canImport(AppKit)

import AppKit

public typealias OSApplication      = NSApplication
public typealias OSFont             = NSFont
public typealias OSImage            = NSImage
public typealias OSViewController   = NSViewController

public typealias OSMouseOrTouchEventComponent = MouseEventComponent

#elseif canImport(UIKit)

import UIKit

public typealias OSApplication      = UIApplication
public typealias OSFont             = UIFont
public typealias OSImage            = UIImage
public typealias OSViewController   = UIViewController

public typealias OSMouseOrTouchEventComponent = TouchEventComponent

#endif
