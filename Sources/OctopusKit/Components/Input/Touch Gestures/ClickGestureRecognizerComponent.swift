//
//  ClickGestureRecognizerComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/12/22.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

#if canImport(AppKit)

/// Creates a `NSClickGestureRecognizer` and attaches it to the `SceneComponent` `SKView` when this component is added to the scene entity.
///
/// - Important: The player must click the specified mouse button the required number of times without dragging the mouse for the gesture to be recognized.
///
/// **Dependencies:** `SceneComponent`
@available(macOS 10.15, *)
public final class ClickGestureRecognizerComponent: OKGestureRecognizerComponent<NSClickGestureRecognizer> {
    
    // https://developer.apple.com/documentation/appkit/nsclickgesturerecognizer
    
    public init(numberOfClicksRequired:  Int  = 1,
                numberOfTouchesRequired: Int  = 1,
                buttonMask:              Int  = 0x1)
    {
        super.init()
        self.gestureRecognizer.numberOfClicksRequired  = numberOfClicksRequired
        self.gestureRecognizer.numberOfTouchesRequired = numberOfTouchesRequired
        self.gestureRecognizer.buttonMask              = buttonMask
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#endif

#if os(iOS)
@available(iOS, unavailable, message: "Use TapGestureRecognizerComponent")
public final class ClickGestureRecognizerComponent: macOSExclusiveComponent {}
#endif
