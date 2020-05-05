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
    
    /// - Type Methods
    
    /// Attempts to unarchive the specified "sks" file from the main application bundle and returns it.
    @inlinable
    final class func nodeWithName<T>(name: String) -> T? {
        // CREDIT: Apple Adventure Sample
        
        // TODO: Verify the functionality of this Swift 4.2/iOS 12 update.
        return (try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [SKNode.self],
                                                        from: Data(contentsOf: Bundle.main.url(forResource: name, withExtension: "sks")!))) as? T
    }
    
    /// MARK: - Initializers
    
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
    
    /// Returns this node after setting its transparency.
    @inlinable
    final func alpha(_ a: CGFloat) -> Self {
        self.alpha = a
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
