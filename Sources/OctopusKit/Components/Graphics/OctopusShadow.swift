//
//  OctopusShadow.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-11-28
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Test
// TODO: Improve
// TODO: macOS support

import SpriteKit

public struct OctopusCShadow {
    // CHECK: struct or class?
    
    public var shadowColor: CGColor?
    public var shadowOpacity: Float?
    public var shadowOffset: CGSize?
    public var shadowPath: CGPath?
    public var shadowRadius: CGFloat?
    
    public init(shadowColor: CGColor? = nil,
                shadowOpacity: Float? = nil,
                shadowOffset: CGSize? = nil,
                shadowPath: CGPath? = nil,
                shadowRadius: CGFloat? = nil) {
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowOffset = shadowOffset
        self.shadowPath = shadowPath
        self.shadowRadius = shadowRadius
    }
    
    public init(fromLayer layer: CALayer) {
        self.init(shadowColor: layer.shadowColor,
                  shadowOpacity: layer.shadowOpacity,
                  shadowOffset: layer.shadowOffset,
                  shadowPath: layer.shadowPath,
                  shadowRadius: layer.shadowRadius)
    }
    
//    public func apply(toView view: NSView) {
//        apply(toLayer: view.layer)
//    }
    
    #if os(iOS)
    
    public func apply(toView view: UIView) {
        apply(toLayer: view.layer)
    }
    
    #endif
    
    public func apply(toLayer layer: CALayer) {
        // nil-able properties...
        layer.shadowColor = shadowColor
        layer.shadowPath = shadowPath
        
        // Non-nil properties.
        if let shadowOpacity = self.shadowOpacity { layer.shadowOpacity = shadowOpacity }
        if let shadowOffset = self.shadowOffset { layer.shadowOffset = shadowOffset }
        if let shadowRadius = self.shadowRadius { layer.shadowRadius = shadowRadius }
    }
    
    public mutating func copy(fromLayer layer: CALayer) {
        shadowColor = layer.shadowColor
        shadowOpacity = layer.shadowOpacity
        shadowOffset = layer.shadowOffset
        shadowPath = layer.shadowPath
        shadowRadius = layer.shadowRadius
    }
}



