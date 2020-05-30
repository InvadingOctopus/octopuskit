//
//  SKNode+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/07.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit

public extension SKNode {
    
    // MARK: - Type Methods
    
    /// Attempts to unarchive the specified "sks" file from the main application bundle and returns it.
    @inlinable
    final class func nodeWithName<T>(name: String) -> T? {
        // CREDIT: Apple Adventure Sample
        
        // TODO: Verify the functionality of this Swift 4.2/iOS 12 update.
        return (try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [SKNode.self],
                                                        from: Data(contentsOf: Bundle.main.url(forResource: name, withExtension: "sks")!))) as? T
    }
        
    // MARK: - Initializers
    
    /// Creates a new node with the specified `position` and `zPosition`.
    ///
    /// Useful for quickly creating nodes on a specific "layer."
    convenience init(zPosition: CGFloat) {
        self.init()
        self.zPosition = zPosition
    }
    
    /// Creates a new node and adds the specified children to it.
    convenience init(children: [SKNode]) {
        self.init()
        self.addChildren(children)
    }
    
    // MARK: - Modifiers
    // As in SwiftUI.
    
    /// Returns this node after setting its transparency.
    @inlinable
    final func alpha(_ a: CGFloat) -> Self {
        self.alpha = a
        return self
    }
    
    /// Returns this node after setting its scale.
    @inlinable
    final func scale(_ scale: CGFloat) -> Self {
        self.setScale(scale)
        return self
    }
    
    /// Returns this node after setting its scale.
    @inlinable
    final func scale(x: CGFloat, y: CGFloat) -> Self {
        self.xScale = xScale
        self.yScale = yScale
        return self
    }
    
    /// Returns this node after setting its position.
    @inlinable
    final func position(_ newPosition: CGPoint) -> Self {
        self.position = newPosition
        return self
    }
    
    /// Returns this node after setting its position.
    @inlinable
    final func position(x: CGFloat, y: CGFloat) -> Self {
        self.position = CGPoint(x: x, y: y)
        return self
    }
    
    /// Returns this node after setting its z position.
    @inlinable
    final func zPosition(_ z: CGFloat) -> Self {
        self.zPosition = z
        return self
    }
    
    /// Returns this node after setting its rotation.
    @inlinable
    final func zRotation(_ radians: CGFloat) -> Self {
        self.zRotation = radians
        return self
    }
    
    // MARK: - Common Tasks
    
    /// Convenient shorthand for multiple `addChild(_:)` calls.
    @inlinable
    final func addChildren(_ children: [SKNode]) {
        for child in children {
            self.addChild(child)
        }
    }
    
    /// Convenient shorthand for multiple `addChild(_:)` calls.
    @inlinable
    final func addChildren(_ children: SKNode...) {
        self.addChildren(children)
    }
    
    /// Adds a node at the specified position, to the end of the receiver's list of child nodes.
    @inlinable
    final func addChild(_ node: SKNode, at position: CGPoint) {
        self.addChild(node)
        node.position = position
    }
    
    /// Returns this node's position in the coordinate system of another node in the node tree.
    @inlinable
    final func position(in node: SKNode) -> CGPoint {
        return convert(position, to: node)
    }
        
    /// Converts a point from the coordinate system of this node's parent to the coordinate system of this node.
    ///
    /// Returns unconverted point if parent is `nil`.
    @inlinable
    final func convertPointFromParent(_ point: CGPoint) -> CGPoint {
        if  let parent = self.parent {
            return convert(point, from: parent)
        } else {
            return point
        }
    }
    
    /// Converts a point in this node's coordinate system to the coordinate system of this node's parent.
    ///
    /// Returns unconverted point if parent is `nil`.
    @inlinable
    final func convertPointToParent(point: CGPoint) -> CGPoint {
        if  let parent = self.parent {
            return convert(point, to: parent)
        } else {
            return point
        }
    }
    
    /// Returns the radians between this node's `zRotation` and the target angle in radians.
    @inlinable
    final func deltaBetweenRotation(and targetAngle: CGFloat) -> CGFloat {
        self.zRotation.deltaBetweenAngle(targetAngle)
    }
    
    /// Removes a node and adds this node to the former parent of the removed node.
    ///
    /// This does not copy any attributes over from the placeholder node.
    @inlinable
    final func replaceNode(_ placeholder: SKNode) {
        
        if  let placeholderParent = placeholder.parent {
            placeholder.removeAllActions() // CHECK: Is this necessary even with `removeFromParent()`?
            placeholder.removeFromParent()
            
            if  self.parent != placeholderParent {
                self.removeFromParent()
                placeholderParent.addChild(self)
            }
        }
    }
    
    /// Searches a node for a child with the specified name, then removes that child node and adds this node to the former parent of the removed child node.
    ///
    /// This does not copy any attributes over from the placeholder node.
    @inlinable
    final func replaceNode(named name: String, in placeholderParent: SKNode) {
        if  let placeholder = placeholderParent.childNode(withName: name) {
            self.replaceNode(placeholder)
        }
    }
    
    /// Removes this node from its parent *only if* the node is a child of the specified parent.
    /// - Returns: `true` if the node is removed from the specified parent or if the node had no parent. `false` if the node has a different parent.
    @inlinable @discardableResult
    final func removeFromParent(ifParentIs parent: SKNode) -> Bool {
        if  self.parent == nil {
            return true
        } else if self.parent! != parent {
            return false
        } else {
            self.removeFromParent()
            return true
        }
    }
    
    /// Returns the point at the specified edge or corner *in this node's coordinate space*. If this node is of a type that has a zero-sized frame, such as `SKNode`, then `calculateAccumulatedFrame()` is used to determine its extents, including all its children. If an invalid direction is specified then `(0,0)` will be returned.
    @inlinable
    final func point(at direction: OKDirection) -> CGPoint {
        
        // TODO:  Tests
        // CHECK: with scaling
        
        let size: CGSize
        
        if  let nodeWithSize = self as? SKNodeWithDimensions {
            size = nodeWithSize.size
        } else if !self.frame.isEmpty {
            size = self.frame.size
        } else {
            size = self.calculateAccumulatedFrame().size
        }
        
        // Extracting the size reduces clutter and might improves performance.
        let width  = size.width
        let height = size.height
        
        // Account for the anchor point.
        // An anchor of (0.5, 0.5) means child nodes with a position of (0,0) will be placed at this node's center, and children at (width, height) would be outside this node, so the actual maxX/maxY would be half the width/height, and minX/minY would be negative, and so on.
        
        let maxX, maxY,
            midX, midY,
            minX, minY: CGFloat
        
        if  let nodeWithAnchor  = self as? SKNodeWithAnchor {
            
            let anchor          = nodeWithAnchor.anchorPoint
            let anchorWidth     = (width  * anchor.x)
            let anchorHeight    = (height * anchor.y)
                
            maxX = width        - anchorWidth
            maxY = height       - anchorHeight
            
            minX = 0            - anchorWidth
            minY = 0            - anchorHeight
            
            midX = (width  / 2) - anchorWidth
            midY = (height / 2) - anchorHeight
            
        } else {
            (maxX, maxY) = (width,      height)
            (midX, midY) = (width / 2,  height / 2)
            (minX, minY) = (0,          0)
        }
        
        // Set and return the point
        
        var (x, y) = (midX, midY) // Default to the center.
        
        switch direction {
        // TODO: Verify, especially in iOS vs. macOS coordinate spaces where Y is the inverse of each other.
        case .north,        .top:           y = maxY
        case .northEast,    .topRight:      x = maxX; y = maxY
        case .east,         .right:         x = maxX
        case .southEast,    .bottomRight:   x = maxX; y = minY
        case .south,        .bottom:        y = minY
        case .southWest,    .bottomLeft:    x = minX; y = minY
        case .west,         .left:          x = minX;
        case .northWest,    .topLeft:       x = minX; y = maxY
        case .center:       break
        default:
            OctopusKit.logForErrors("Invalid direction: \(direction)") // CHECK: Should this be an error?
            x = 0; y = 0
        }
        
        return CGPoint(x: x, y: y)
    }
    
    /// Offsets the `position` by the `safeAreaInsets` of the parent scene's view. May be necessary for correct placement of visual elements on iPhone X and other devices where the edges of the display are not uniformly visible.
    ///
    /// - Important: This method should generally be called after this node is added to a scene, as it uses the scene's `view` property. If a node needs to be offset before it's added to a scene, then provide the optional `forView` argument. It may be convenient to use `OctopusKit.shared.gameCoordinatorView`.
    ///
    /// - Important: This method simply performs an addition or subtraction on the `x` or `y` value; to properly ensure that the node is within the `safeAreaInsets`, use the `insetWithinSafeArea(edge:)` method.
    ///
    /// - Returns: The `safeAreaInsets` value at the corresponding `edge`
    @inlinable @discardableResult
    final func insetPositionBySafeArea(
        at edge: OKDirection,
        forView view: SKView? = nil)
        -> CGFloat
    {
        // CHECK: Should the return value be modified by the [scene] scaling?
        
        // TODO: Account for camera scaling
        
        guard let view = view ?? self.scene?.view else {
            OctopusKit.logForWarnings("\(self) missing `scene.view` and no `view` argument provided.")
            return 0
        }
        
        #if os(iOS)
        
        let xSizeToViewRatio = self.scene?.xSizeToViewRatio ?? 1
        let ySizeToViewRatio = self.scene?.ySizeToViewRatio ?? 1
        
            switch edge {
            case .top:
                self.position.y -= view.safeAreaInsets.top * ySizeToViewRatio
                return view.safeAreaInsets.top
            case .bottom:
                self.position.y += view.safeAreaInsets.bottom * ySizeToViewRatio
                return view.safeAreaInsets.bottom
            case .left:
                self.position.x += view.safeAreaInsets.left * xSizeToViewRatio
                return view.safeAreaInsets.left
            case .right:
                self.position.x -= view.safeAreaInsets.right * xSizeToViewRatio
                return view.safeAreaInsets.right
            default:
                OctopusKit.logForErrors("Invalid OKDirection: \(edge)")
                return 0
            }
            
        #else
        
            OctopusKit.logForDebug("Only applicable on iOS.")
            return 0
            
        #endif
    }
    
}
