//
//  CGSize+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import CoreGraphics

public extension CGSize {
    
    // MARK: - Initializers
    
    init(widthAndHeight: CGFloat) {
        self.init(width: widthAndHeight, height: widthAndHeight)
    }
    
    init(widthAndHeight: Int) {
        self.init(width: widthAndHeight, height: widthAndHeight)
    }
    
    // MARK: - Common Tasks
    
    /// Returns a `CGSize` equal to the half of this size.
    @inlinable
    var halved: CGSize {
        CGSize(width:  width  / 2,
               height: height / 2)
    }
    
    /// Returns a `CGPoint` with a position equal to half the width and height of this size.
    @inlinable
    var center: CGPoint {
        CGPoint(x: width  / 2,
                y: height / 2)
    }
    
    /// Returns a new `CGSize` that is equivalent to this size scaled by the specified factors.
    @inlinable
    func scaled(byX xScale: CGFloat, y yScale: CGFloat) -> CGSize {
        CGSize(width:  self.width  * xScale,
               height: self.height * yScale)
    }
    
    /// Scales this size by the specified factors.
    @inlinable
    mutating func scale(byX xScale: CGFloat, y yScale: CGFloat) {
        self = self.scaled(byX: xScale,
                           y:   yScale)
    }
    
    // MARK: - iOS Device Dimensions
    
    /// Represents the screen resolution of an iOS device in each orientation.
    ///
    /// The resolution is assumed to be in absolute pixels, not points.
    struct OrientationDependentSize {
        public let portrait:  CGSize
        public let landscape: CGSize
        
        public init (portrait: CGSize, landscape: CGSize) {
            self.portrait  = portrait
            self.landscape = landscape
        }
        
        public init (portraitWidth: CGFloat, portraitHeight: CGFloat) {
            self.portrait  = CGSize(width: portraitWidth,  height: portraitHeight)
            self.landscape = CGSize(width: portraitHeight, height: portraitWidth)
        }
        
        public init (landscapeWidth: CGFloat, landscapeHeight: CGFloat) {
            self.landscape = CGSize(width: landscapeWidth,  height: landscapeHeight)
            self.portrait  = CGSize(width: landscapeHeight, height: landscapeWidth)
        }
    }
    
    /// A list of screen resolutions, in pixels, of iOS devices supported by OctopusKit.
    struct IOSDevice {
        // TODO: Pick a better place for these?
        
        /*
         12.9" iPad Pro      2048px × 2732px     2732px × 2048px
         10.5" iPad Pro      1668px × 2224px     2224px × 1668px
         9.7" iPad           1536px × 2048px     2048px × 1536px
         7.9" iPad mini 4    1536px × 2048px     2048px × 1536px
         iPhone X            1125px × 2436px     2436px × 1125px
         iPhone 8 Plus       1242px × 2208px     2208px × 1242px
         iPhone 8            750px × 1334px      1334px × 750px
         iPhone 7 Plus       1242px × 2208px     2208px × 1242px
         iPhone 7            750px × 1334px      1334px × 750px
         iPhone 6s Plus      1242px × 2208px     2208px × 1242px
         iPhone 6s           750px × 1334px      1334px × 750px
         iPhone SE           640px × 1136px      1136px × 640px
         */
        
        public static let iPhoneSE      = OrientationDependentSize(portraitWidth: 640, portraitHeight: 1136)
        
        public static let iPhone5       = iPhoneSE
        
        public static let iPhone6s      = OrientationDependentSize(portraitWidth: 750, portraitHeight: 1334)
        public static let iPhone6sPlus  = OrientationDependentSize(portraitWidth: 1242, portraitHeight: 2208)
        public static let iPhoneX       = OrientationDependentSize(portraitWidth: 1125, portraitHeight: 2436)
        
        public static let iPhone7       = iPhone6s
        public static let iPhone7Plus   = iPhone6sPlus
        public static let iPhone8Plus   = iPhone6sPlus
        
        public static let iPadPro9point7inch  = OrientationDependentSize(portraitWidth: 1536, portraitHeight: 2048)
        public static let iPadPro10point5inch = OrientationDependentSize(portraitWidth: 1668, portraitHeight: 2224)
        public static let iPadPro12point9inch = OrientationDependentSize(portraitWidth: 2048, portraitHeight: 2732)
        
        public static let iPad9point7inch = iPadPro9point7inch
        public static let iPadMini4 = iPad9point7inch
        
    }
    
    // MARK: - Operators
    
    // MARK: CGSize with CGSize
    
    @inlinable
    static func + (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width:  left.width  + right.width,
               height: left.height + right.height)
    }
    
    @inlinable
    static func - (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width:  left.width  - right.width,
               height: left.height - right.height)
    }
    
    // MARK: CGSize with CGFloat
    
    @inlinable
    static func + (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width:  left.width  + right,
               height: left.height + right)
    }
    
    @inlinable
    static func += (left: inout CGSize, right: CGFloat) {
        left.width  += right
        left.height += right
    }
    
    @inlinable
    static func - (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width:  left.width  - right,
               height: left.height - right)
    }
    
    @inlinable
    static func -= (left: inout CGSize, right: CGFloat) {
        left.width  -= right
        left.height -= right
    }
    
    @inlinable
    static func * (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width:  left.width  * right,
               height: left.height * right)
    }
    
    @inlinable
    static func *= (left: inout CGSize, right: CGFloat) {
        left.width  *= right
        left.height *= right
    }
    
    @inlinable
    static func / (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width:  left.width  / right,
               height: left.height / right)
    }
    
    @inlinable
    static func /= (left: inout CGSize, right: CGFloat) {
        left.width  /= right
        left.height /= right
    }

}
