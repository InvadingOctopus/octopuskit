//
//  ValueDisplayComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/19.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Method for adding values.
// TODO: Make it an ordered list?

import SpriteKit
import GameplayKit

/// Displays a list of labels and values over the entity's `NodeComponent` node. Useful for displaying live debugging information.
///
/// - NOTE: The order in which the labels are displayed is not deterministic. This is because the collection type used to store the label:value pairs is a `Dictionary`, which is unordered.
///
/// **Dependencies:** `NodeComponent`
public final class ValueDisplayComponent: NodeAttachmentComponent<SKLabelNode>, RequiresUpdatesPerFrame {
    
    // MARK: - Properties
    
    public static let defaultFont = OKFont(name: "Menlo-Regular",
                                         size: 12,
                                         color: .white)
    
    public let label: SKLabelNode
    
    private let initialMaximumLines: Int
    private let initialLineBreakMode: NSLineBreakMode
    
    /// The dictionary of labels and their values to display.
    ///
    /// A value can be a closure which returns a `String` (`() -> String`), which you can use to display the dynamically-updated value of a value type, e.g. structs, such as the `CGPoint` position of a sprite.
    ///
    /// **Example**
    ///
    ///     valueDisplayComponent["sprite.position"] = { [unowned sprite] in return "\(sprite.position)" }
    public var data: [String: Any] = [:]
    
    public subscript(key: String) -> Any? {
        get { return data[key] }
        set { data[key] = newValue }
    }
    
    // MARK: - Life Cycle
    
    public init(font: OKFont = ValueDisplayComponent.defaultFont,
                maximumLines: Int = 10,
                lineBreakMode: NSLineBreakMode = .byTruncatingTail,
                parentOverride: SKNode? = nil,
                positionOffset: CGPoint? = nil,
                zPositionOverride: CGFloat = 1000)
    {
        self.label = SKLabelNode(font: font)
        self.initialMaximumLines = maximumLines
        self.initialLineBreakMode = lineBreakMode
        
        super.init(parentOverride: parentOverride,
                   positionOffset: positionOffset,
                   zPositionOverride: zPositionOverride)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createAttachment(for parent: SKNode) -> SKLabelNode? {
        
        let parentSize = (parent as? SKNodeWithDimensions)?.size ?? parent.frame.size
        
        if parentSize.width < 1 || parentSize.height < 1 {
            OctopusKit.logForWarnings("\(parent) is too small: \(parent.frame)")
        }
        
        // Position the text at the top-left corner, filling the width of the parent, and set it to display multiple wrapped lines.
        
        label.position = CGPoint(x: -(parentSize.width / 2), y: parentSize.height / 2)
        label.alignment = (.left, .top)
        
        label.numberOfLines = initialMaximumLines
        label.lineBreakMode = self.initialLineBreakMode
        label.preferredMaxLayoutWidth = parentSize.width
        
        return label
    }
    
    public override func didAddToEntity(withNode node: SKNode) {
        super.didAddToEntity(withNode: node)
        
        // Position the label into the safe area.
        label.insetPositionBySafeArea(at: .top)
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        
        guard !data.isEmpty else { return }
        
        var text = ""
        
        // Add each label and the value it represents to the text.
        
        for (label, value) in data {
            
            // If the value is a closure which returns a `String`, run it and display its output. This may be used for displaying dynamicaly-updated value types, e.g. structs, such as the `CGPoint` position of a sprite.
            
            if let closure = value as? (() -> String) {
                text += "\(label) = \(closure())\n"
            }
            else {
                text += "\(label) = \(value)\n"
            }
            
        }
        
        label.text = text
    }
    
    public override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        
        // Remove all references.
        // CHECK: Necessary?
        self.data.removeAll()
    }
}

