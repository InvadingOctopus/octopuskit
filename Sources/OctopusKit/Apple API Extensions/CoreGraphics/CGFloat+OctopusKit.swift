//
//  CGFloat+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/06.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import CoreGraphics

extension CGFloat {
    
    // MARK: - Random Numbers
    
    /// Returns a random **integer** between the lower and upper bounds, **inclusive**.
    ///
    /// Equivalent to calling `Int.random(from:to:)` (an OctopusKit extension) and converting it to `CGFloat`.
    ///
    /// Uses `arc4random_uniform(_:)`. For GameplayKit-based randomization, use the extensions of `GKRandom`.
    public static func randomInteger(from lowerBound: CGFloat, to upperBound: CGFloat) -> CGFloat {
        // TODO: CHECK: Relevance after Swift 4.2 is released.
        
        // Provided as a convenience to avoid having to explicitly cast from `Int` because working with SpriteKit primarily involves `CGFloat`.
        return CGFloat(Int.random(from: Int(lowerBound), to: Int(upperBound)))
    }
}
