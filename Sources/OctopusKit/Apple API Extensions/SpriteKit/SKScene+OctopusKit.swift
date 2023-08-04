//
//  SKScene+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/26.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import OctopusCore
import SpriteKit

extension SKScene {

    // MARK: - Properties
    
    /// Returns the ratio of the scene's width to the view's width, or `0` if the scene is not part of a view.
    @inlinable
    public var xSizeToViewRatio: CGFloat {
        guard let view = self.view else { return 0 }
        return self.frame.size.width / view.frame.size.width // CHECK: Should it be `self.frame` or `self.size`?
    }
    
    /// Returns the ratio of the scene's height to the view's height, or `0` if the scene is not part of a view.
    @inlinable
    public var ySizeToViewRatio: CGFloat {
        guard let view = self.view else { return 0 }
        return self.frame.size.height / view.frame.size.height // CHECK: Should it be `self.frame` or `self.size`?
    }
    
    /// Returns the scene's frame inset by the view's `safeAreaInsets`, or a zero-sized rectangle if the scene is not part of a view.
    @inlinable
    public var safeAreaFrame: CGRect {
        #if os(iOS)
        
        // TODO: Test & confirm correctness
        
        guard let view = self.view else { return CGRect.zero }
        
        let origin = CGPoint(x: self.frame.origin.x + view.safeAreaInsets.left,
                             y: self.frame.origin.y + view.safeAreaInsets.bottom)
        
        let size = CGSize(
            width: self.frame.width - (view.safeAreaInsets.left + view.safeAreaInsets.right),
            height: self.frame.height - (view.safeAreaInsets.bottom + view.safeAreaInsets.top))
        
        return CGRect(origin: origin, size: size)
        
        #else
        
        OctopusKit.logForDebug("Only applicable on iOS!")
        return self.frame
        
        #endif
    }
    
    /// Returns the `CGRect` for the scene's `camera`, if any, or its `view` modified by the scaling ratio. If the scene has no camera and no view, returns a zero-sized `CGRect`.
    @inlinable
    public var viewport: CGRect {
        
        // TODO: Account for `anchorPoint` and scaling.
        
        var rect: CGRect
        
        if  let view = self.view {
            rect = view.frame
        } else {
            rect = self.frame
        }
        
        if  let camera = self.camera {
            rect.origin = camera.position
            rect.size.width *= camera.xScale
            rect.size.height *= camera.yScale
        }
        
        return CGRect(x: rect.origin.x,
                      y: rect.origin.y,
                      width: rect.size.width,
                      height: rect.size.height)
    }
}
