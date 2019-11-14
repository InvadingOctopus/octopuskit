//
//  NoiseMappedGeneratorComponent
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/09.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Documentation.
// TODO: `NoiseComponent` integration.
// BUG: Does not seem to paint edges? Top and top-right corner?

import SpriteKit
import GameplayKit
import simd

/// Executes a supplied `SKNode` generating closure that uses the specified `GKNoiseMap` and draws its output inside the frame of an `SpriteKitComponent`.
///
/// **Dependencies:** `SpriteKitComponent`
public final class NoiseMappedGeneratorComponent: SpriteKitAttachmentComponent<SKNode> {
    
    /// A closure called by a `NoiseMappedGeneratorComponent` to generate a node for the given parameters.
    ///
    /// - Parameter component: A reference to `self`; the instance of `NoiseMappedGeneratorComponent` that this closure will be a property of.
    ///
    ///     You can use this to access the instance properties of this component, such as its associated entity and co-components.
    ///
    ///     **Example:** `component.coComponent(ofType: SpriteKitComponent.self)?.node`
    ///
    /// - Parameter parent: The parent node that the returned node will be placed in.
    /// - Parameter position: The position that the returned node will be placed in.
    /// - Parameter noiseValue: The value in the noise map for the position.
    public typealias GeneratorClosureType = (
        _ component: NoiseMappedGeneratorComponent,
        _ parent: SKNode,
        _ position: CGPoint,
        _ noiseValue: Float)
        -> SKNode?
    
    public override var requiredComponents: [GKComponent.Type]? {
        [SpriteKitComponent.self]
    }
    
    /// The noise field for the nodes generator.
    ///
    /// Resets and regenerates the contents when modified.
    public var noise: GKNoise {
        didSet {
            if  noise != oldValue { // Avoid redundancy.
                recreateAttachmentForCurrentParent()
            }
        }
    }
    
    /// The closure which returns a node for the given parameters. Called for every pixel in the parent node of this component, and provided the value of the noise map at that point.
    ///
    /// Resets and regenerates the contents when set.
    ///
    /// For a description of the closure's signature and parameters, see `NoiseMappedGeneratorComponent.GeneratorClosureType`.
    public var contentNodeGenerator: GeneratorClosureType {
        didSet { recreateAttachmentForCurrentParent() }
    }
    
    public fileprivate(set) var contents: SKNode?
    
    /// - Parameter noise: The noise field from which this component will generate a noise map.
    ///
    /// - Parameter contentNodeGenerator: The closure which returns a node for the given parameters. This closure is called for every pixel in the parent node of this component.
    ///
    ///     For a description of the closure's signature and parameters, see `NoiseMappedGeneratorComponent.GeneratorClosureType`.
    public init(noise: GKNoise,
                contentNodeGenerator: @escaping GeneratorClosureType)
    {
        self.noise = noise
        self.contentNodeGenerator = contentNodeGenerator
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func createAttachment(for parent: SKNode) -> SKNode? {
        return self.contents ?? generateContents(for: parent)
    }
    
    fileprivate func generateContents(for parent: SKNode) -> SKNode? {
        
        // TODO: Test and verify dimensions and positions.
        
        let newContents = SKNode()
        
        // CHECK: Cache the noise map?
        
        let noiseMap = GKNoiseMap(self.noise,
                                  size: vector_double2(Double(parent.frame.width), Double(parent.frame.height)),
                                  origin: vector_double2(Double(parent.frame.minX), Double(parent.frame.minY)),
                                  sampleCount: vector_int2(Int32(parent.frame.width), Int32(parent.frame.height)),
                                  seamless: false)
        
        for x in Int(parent.frame.minX) ... Int(parent.frame.maxX) {
            
            for y in Int(parent.frame.minY) ... Int(parent.frame.maxY) {
                
                let nodePosition = CGPoint(x: x, y: y)
                
                let noiseMapPosition = vector_int2(Int32(x) - Int32(noiseMap.origin.x), Int32(y) - Int32(noiseMap.origin.y)) // Make adjustment for the case of `x` or `y` being negative, as would be the case if `node` has an `anchorValue` of (0.5, 0.5) for example.
                
                // See the initializer description for each parameter of the closure.
                
                let newNode = self.contentNodeGenerator(
                    self,
                    parent,
                    nodePosition,
                    noiseMap.value(at: noiseMapPosition)
                )
                
                if let newNode = newNode {
                    newNode.position = nodePosition // In case the generator did not set it?
                    newContents.addChild(newNode)
                }
                
            }
        }
        
        return newContents
    }
    
}

