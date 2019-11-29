//
//  OctopusDirection.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/7/7.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Support for degrees?
// CHECK: Internationalization for string representations?

import SpriteKit

public typealias OKDirection = OctopusDirection

public enum OctopusDirection: String, CustomStringConvertible, CaseIterable {
    
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest

    case up
    case down
    case left
    case right

    case top
    case bottom
    
    case front
    case forward
    case back
    case backward
    
    case fore
    case aft
    case port
    case starboard
    
    case clockwise
    case counterClockwise
    
    case inside
    case outside
    
    /// An array of directions moving counter-clockwise from east to southeast, compatible with SpriteKit's rotation notation (where 0 radians is east.)
    public static let compassDirections: [OctopusDirection] = [
        .east,
        .northEast,
        .north,
        .northWest,
        .west,
        .southWest,
        .south,
        .southEast]
    
    /// Returns the opposite direction.
    public var opposite: OctopusDirection {
        switch self {
        case .north:            return .south
        case .northEast:        return .southWest
        case .east:             return .west
        case .southEast:        return .northWest
        case .south:            return .north
        case .southWest:        return .northEast
        case .west:             return .east
        case .northWest:        return .southEast
        case .up:               return .down
        case .down:             return .up
        case .left:             return .right
        case .right:            return .left
        case .top:              return .bottom
        case .bottom:           return .top
        case .fore:             return .aft
        case .aft:              return .fore
        case .port:             return .starboard
        case .starboard:        return .port
        case .front:            return .back
        case .forward:          return .backward
        case .back:             return .front
        case .backward:         return .forward
        case .clockwise:        return .counterClockwise
        case .counterClockwise: return .clockwise
        case .inside:           return .outside
        case .outside:          return .inside
        }
    }

    /// Returns an angle in radians corresponding to a compass direction, with east being 0 radians and increasing counter-clockwise, and as such is compatible with SpriteKit's rotation notation.
    ///
    /// Returns `nil` if the direction is not a compass direction.
    public var angle: CGFloat? {
        // CHECK: Does this need better formulas?
        switch self {
        case .east:             return 0
        case .northEast:        return CGFloat.pi / 4
        case .north:            return CGFloat.pi / 2
        case .northWest:        return CGFloat.pi - (CGFloat.pi / 4)
        case .west:             return CGFloat.pi
        case .southWest:        return CGFloat.pi + (CGFloat.pi / 4)
        case .south:            return CGFloat.pi + (CGFloat.pi / 2)
        case .southEast:        return (CGFloat.pi * 2) - (CGFloat.pi / 2)
        default:                return nil
        }
    }
    
    /// Retuns a unit vector for the direction, anchored at (0,0).
    public var vector: CGVector {
        switch self {
        case .north:            return CGVector(dx:  0.0, dy:  1.0)
        case .northEast:        return CGVector(dx:  1.0, dy:  1.0)
        case .east:             return CGVector(dx:  1.0, dy:  0.0)
        case .southEast:        return CGVector(dx:  1.0, dy: -1.0)
        case .south:            return CGVector(dx:  0.0, dy: -1.0)
        case .southWest:        return CGVector(dx: -1.0, dy: -1.0)
        case .west:             return CGVector(dx: -1.0, dy:  0.0)
        case .northWest:        return CGVector(dx: -1.0, dy:  1.0)
        default:                return CGVector.zero
        }
    }

    /// Returns an angle in radians representing rotation to a direction, with positive values representing a counter-clockwise rotation, and as such is compatible with SpriteKit's rotation notation.
    ///
    /// Returns `nil` if the direction cannot be represented as a change in a node's `zRotation`.
    public var rotation: CGFloat? {
        // CHECK: Does this need better formulas?
        switch self {
        case .forward,  .fore, .front:  return 0
        case .backward, .aft,  .back:   return CGFloat.pi
        case .left,     .port:          return +(CGFloat.pi / 2)
        case .right,    .starboard:     return -(CGFloat.pi / 2)
        default:                        return nil
        }
    }
    
    public var description: String {
        return rawValue
    }

    /// Creates a new `FacingDirection` for a given `zRotation` in radians.
    init(zRotation: CGFloat) {
        // CREDIT: Apple DemoBots Sample. (C) 2016 Apple Inc. All Rights Reserved. TODO: Note the license.
        // TODO: Test
        
        let twoPi = Double.pi * 2
        
        // Normalize the node's rotation.
        let rotation = (Double(zRotation) + twoPi).truncatingRemainder(dividingBy: twoPi)
        
        // Convert the rotation of the node to a percentage of a circle.
        let orientation = rotation / twoPi
        
        // Scale the percentage to a value between 0 and 7 (the count of elements in the `compassDirection` array.)
        let rawFacingValue = round(orientation * 8.0).truncatingRemainder(dividingBy: 8.0)
        
        // Select the appropriate `OctopusDirection` from the `compassDirection` member at the index equal to `rawFacingValue`.
        self = OctopusDirection.compassDirections[Int(rawFacingValue)]
    }
}

// MARK: - Orientations

public enum OctopusOrientation {
    case horizontal
    case vertical
}

public enum OctopusHorizontalOrientation {
    case left
    case right
}

public enum OctopusVerticalOrientation {
    case up
    case down   
}
