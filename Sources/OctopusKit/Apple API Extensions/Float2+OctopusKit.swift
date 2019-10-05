//
//  Float2+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/27.
//  Copyright © 2018 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import CoreGraphics
import simd

extension SIMD2 where Scalar == Float {
    
    // MARK: - Initializers
    
    /// Converts a `CGPoint` to `SIMD2<Float>`.
    init(_ point: CGPoint) {
        self.init(x: Float(point.x),
                  y: Float(point.y))
    }
    
    /// Converts a `CGVector` to `SIMD2<Float>`.
    init(_ vector: CGVector) {
        self.init(x: Float(vector.dx),
                  y: Float(vector.dy))
    }
    
    // MARK: - Common Tasks
    
    /// Returns the nearest point to this point on a line from `startPoint` to `endPoint`.
    func nearestPointOnLineSegment(lineSegment: (startPoint: SIMD2<Float>, endPoint: SIMD2<Float>)) -> SIMD2<Float> {
        // CREDIT: Apple DemoBots Sample
        
        // A vector from this point to the line start.
        let vectorFromStartToLine = self - lineSegment.startPoint
        
        // The vector that represents the line segment.
        let lineSegmentVector = lineSegment.endPoint - lineSegment.startPoint
        
        // The length of the line squared.
        let lineLengthSquared = distance_squared(lineSegment.startPoint, lineSegment.endPoint)
        
        // The amount of the vector from this point that lies along the line.
        let projectionAlongSegment = dot(vectorFromStartToLine, lineSegmentVector)
        
        // Component of the vector from the point that lies along the line.
        let componentInSegment = projectionAlongSegment / lineLengthSquared
        
        // Clamps the component between [0 - 1].
        let fractionOfComponent = Float.maximum(0, Float.minimum(1, componentInSegment)) // max(0, min(1, componentInSegment))
        
        return lineSegment.startPoint + lineSegmentVector * fractionOfComponent
    }
    
}
