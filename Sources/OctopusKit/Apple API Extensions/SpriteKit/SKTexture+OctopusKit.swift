//
//  SKTexture+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/23.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import OctopusCore
import SpriteKit

public extension SKTexture {
    
    /// Creates a gradient texture.
    convenience init(size: CGSize,
                     startColor: SKColor,
                     endColor:   SKColor,
                     direction:  OKDirection = .up)
    {
        // CREDIT: https://theswiftdev.com/2017/10/24/spritekit-best-practices/
        
        // TODO: Add diagonals
        // TODO: Remove forced unwraps!
        // CHECK: Make init failable?
        
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CILinearGradient")!
        let startVector: CIVector
        let endVector: CIVector
        
        filter.setDefaults()
        
        switch direction {
        case .up:
            startVector = CIVector(x: size.width/2, y: 0)
            endVector   = CIVector(x: size.width/2, y: size.height)
        case .down:
            startVector = CIVector(x: size.width/2, y: size.height)
            endVector   = CIVector(x: size.width/2, y: 0)
        case .left:
            startVector = CIVector(x: size.width, y: size.height/2)
            endVector   = CIVector(x: 0, y: size.height/2)
        case .right:
            startVector = CIVector(x: 0, y: size.height/2)
            endVector   = CIVector(x: size.width, y: size.height/2)
        default:
            OKLog.logForWarnings.debug("Unsupported gradient direction")
            startVector = CIVector(x: 0, y: 0)
            endVector = startVector
        }
        
        filter.setValue(startVector, forKey: "inputPoint0")
        filter.setValue(endVector, forKey: "inputPoint1")
        filter.setValue(CIColor(color: startColor), forKey: "inputColor0")
        filter.setValue(CIColor(color: endColor), forKey: "inputColor1")
        
        let image = context.createCGImage(filter.outputImage!, from: CGRect(origin: .zero, size: size))
        
        self.init(cgImage: image!)
    }
}
