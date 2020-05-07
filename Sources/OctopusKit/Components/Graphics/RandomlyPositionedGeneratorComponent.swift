//
//  RandomlyPositionedGeneratorComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Executes a supplied `SKNode` generating closure and draws its output inside the frame of an `NodeComponent`, at random positions generated by a `RandomizationComponent`.
///
/// **Dependencies:** `RandomizationComponent`, `NodeComponent`
public final class RandomlyPositionedGeneratorComponent: SpriteKitAttachmentComponent<SKNode> {
    
    /// A closure called by a `RandomlyPositionedGeneratorComponent` to generate a node for the given parameters.
    ///
    /// - Parameter component: A reference to `self`; the instance of `RandomlyPositionedGeneratorComponent` that this closure will be a property of.
    ///
    ///     You can use this to access the instance properties of this component, such as its associated entity and co-components.
    ///
    ///     **Example:** `component.coComponent(ofType: NodeComponent.self)?.node`
    ///
    /// - Parameter parent: The parent node that the returned node will be placed in.
    /// - Parameter position: The random position that the returned node will be placed in, generated by the entity's `RandomizationComponent`.
    public typealias GeneratorClosureType = (
        _ component: RandomlyPositionedGeneratorComponent,
        _ parent: SKNode,
        _ position: CGPoint)
        -> SKNode?
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         RandomizationComponent.self]
    }
    
    /// The closure which returns a node for the given parameters. Called for a number of times equal to `numberOfNodes`.
    ///
    /// Resets and regenerates the contents when set.
    ///
    /// For a description of the closure's signature and parameters, see `RandomlyPositionedGeneratorComponent.GeneratorClosureType`.
    public var contentNodeGenerator: GeneratorClosureType {
        didSet { recreateAttachmentForCurrentParent() }
    }
    
    /// Resets and regenerates the contents when set.
    public var numberOfNodes: Int {
        didSet {
            if  numberOfNodes != oldValue { // Avoid redundancy.
                recreateAttachmentForCurrentParent()
            }
        }
    }
    
    /// The number of nodes that may cause a negative performance impact. Logs a warning when generating content if `numberOfNodes` exceeds this amount.
    public var numberOfNodesWarningThreshold = 100
    
    public fileprivate(set) var contents: SKNode?
    
    /// - Parameter numberOfNodes: The number of nodes to generate.
    /// - Parameter contentNodeGenerator: The closure which returns a node for the given parameters. This closure is called for a number of times equal to `numberOfNodes`.
    ///
    ///     For a description of the closure's signature and parameters, see `RandomlyPositionedGeneratorComponent.GeneratorClosureType`.
    public init(numberOfNodes: Int,
                contentNodeGenerator: @escaping GeneratorClosureType)
    {
        self.numberOfNodes = numberOfNodes
        self.contentNodeGenerator = contentNodeGenerator
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createAttachment(for parent: SKNode) -> SKNode? {
        return self.contents ?? generateContents(for: parent)
    }
    
    fileprivate func generateContents(for parent: SKNode) -> SKNode? {
        
        // TODO: Fix anchorPoint positioning etc.
        
        guard self.numberOfNodes > 0 else {
            OctopusKit.logForWarnings("numberOfNodes \(numberOfNodes) < 1")
            return nil
        }
        
        guard let randomizationSource = coComponent(RandomizationComponent.self)?.source else {
            OctopusKit.logForWarnings("\(String(describing: self.entity)) missing RandomizationSourceComponent")
            return nil
        }
        
        if numberOfNodes > numberOfNodesWarningThreshold {
            OctopusKit.logForWarnings("numberOfNodes \(numberOfNodes) > numberOfNodesWarningThreshold \(numberOfNodesWarningThreshold) — Potential performance degradation")
        }
        
        let newContents = SKNode()
        
        for _ in 1 ... self.numberOfNodes {
            
            let maxX = Int(parent.frame.width)
            let maxY = Int(parent.frame.height)
            
            let nodePosition = CGPoint(x: CGFloat(randomizationSource.nextInt(upperBound: maxX)),
                                       y: CGFloat(randomizationSource.nextInt(upperBound: maxY)))
            
            // See the initializer description for each parameter of the closure.
            
            let newNode = self.contentNodeGenerator(
                self,
                parent,
                nodePosition
            )
            
            if let newNode = newNode {
                newNode.position = nodePosition // In case the generator did not set it?
                newContents.addChild(newNode)
            }
            
        }
        
        return newContents
    }
    
}

