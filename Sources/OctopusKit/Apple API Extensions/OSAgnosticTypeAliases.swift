//
//  OSAgnosticTypeAliases.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/1.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  Wherever the AppKit (macOS) "NS-" and UIKit (iOS, iPadOS, tvOS) "UI-" variants of an object can be interchanged, OctopusKit uses an OS-agnostic type alias to reduce the amount of duplicated code.

// TODO: Check with Catalyst.
// TODO: Use `GCEventViewController` for game controller input.

import Foundation

#if canImport(AppKit)

import AppKit

public typealias OSMouseOrTouchEventComponent           = MouseEventComponent
public typealias OSClickOrTapGestureRecognizerComponent = ClickGestureRecognizerComponent

#elseif canImport(UIKit)

import UIKit

public typealias OSMouseOrTouchEventComponent   = TouchEventComponent

#endif

#if os(iOS) // Not available on tvOS

public typealias OSClickOrTapGestureRecognizerComponent = TapGestureRecognizerComponent

#endif
