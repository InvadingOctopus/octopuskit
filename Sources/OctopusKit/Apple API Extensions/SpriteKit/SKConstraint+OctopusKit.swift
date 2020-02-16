//
//  SKConstraint+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/18.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

extension SKConstraint {
 
    /// Creates a constraint that restricts both coordinates of a node's position inside the specified rectangle.
    @inlinable
    open class func bounds(_ rect: CGRect) -> SKConstraint {
        let xRange = SKRange(lowerLimit: rect.minX, upperLimit: rect.maxX)
        let yRange = SKRange(lowerLimit: rect.minY, upperLimit: rect.maxY)
        return positionX(xRange, y: yRange)
    }
}
