//
//  NoiseMapComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/04/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Encapsulates a `GKNoiseMap` object which uses a `GKNoise` field from a `NoiseComponent`.
///
/// **Dependencies:** `NoiseComponent`
open class NoiseMapComponent: OKComponent {

    // ℹ️ Hierarchy: Noise Source » Noise » Noise Map
    // https://developer.apple.com/documentation/gameplaykit/gknoisesource
    // https://developer.apple.com/documentation/gameplaykit/gknoise
    // https://developer.apple.com/documentation/gameplaykit/gknoisemap
    
    open override var requiredComponents: [GKComponent.Type]? {
        [NoiseComponent.self]
    }
    
    /// A noise map, created when this component is added to an entity with a `NoiseComponent`.
    open var noiseMap: GKNoiseMap? {
        didSet { // Update this component's properties to match the noise map's properties.
            // CHECK: Will this be the expected behavior?
            if  let noiseMap = noiseMap {
                self.size           = noiseMap.size
                self.origin         = noiseMap.origin
                self.sampleCount    = noiseMap.sampleCount
                self.isSeamless     = noiseMap.isSeamless
            }
        }
    }
    
    /// The size of the “slice” of noise samples contained in the noise map relative to the unit coordinate space of the noise object it was created from. Regenerates the noise map when modified.
    public var size: vector_double2 {
        didSet {
            if  noiseMap != nil,
                size     != oldValue
            {
                generateNoiseMap()
            }
        }
    }
    
    /// The position of the “slice” of noise samples contained in the noise map relative to the unit coordinate space of the noise object it was created from. Regenerates the noise map when modified.
    public var origin: vector_double2 {
        didSet {
            if  noiseMap != nil,
                origin   != oldValue
            {
                generateNoiseMap()
            }
        }
    }
    
    /// The width and height of integer grid for which the noise map contains sampled noise values. Regenerates the noise map when modified.
    public var sampleCount: vector_int2 {
           didSet {
               if  noiseMap    != nil,
                   sampleCount != oldValue
               {
                   generateNoiseMap()
               }
           }
       }
    
    /// Indicates whether the noise map’s output can repeat seamlessly in all directions. Regenerates the noise map when modified.
    public var isSeamless: Bool {
           didSet {
               if  noiseMap   != nil,
                   isSeamless != oldValue
               {
                   generateNoiseMap()
               }
           }
       }
    
    open override func didAddToEntity() {
        generateNoiseMap()
    }
    
    
    /// Initializes a `NoiseMapComponent` with the parameters for creating a `GKNoiseMap` when this component is added to an entity with a `NoiseComponent`.
    /// - Parameters:
    ///   - size: The size of 2D “slice” to take from the unit coordinate space of the noise object.
    ///   If you later generate a texture image from the noise map with the `SKTexture` class, this size is also the pixel dimensions of the texture to generate. Default: `(1,0, 1.0)`
    ///   - origin: The position of the 2D “slice” to take from the unit coordinate space of the noise object. Default: `(0, 0)`
    ///   - sampleCount: The width and height of integer grid for sampling noise values from the noise object. Default: `(100.0, 100.0)`
    ///   - seamless: `true` to adjust samples taken from the noise object so that generated texture images can be tiled without visible seams; `false` otherwise. Default: `false`
    public init(size:           vector_double2  = vector2(1.0, 1.0),
                origin:         vector_double2  = vector2(0.0, 0.0),
                sampleCount:    vector_int2     = vector2(100, 100),
                seamless:       Bool            = false)
    {
        self.size           = size
        self.origin         = origin
        self.sampleCount    = sampleCount
        self.isSeamless     = seamless
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func didAddToEntity(withNode node: SKNode) {
        generateNoiseMap()
    }
    
    /// Creates a new noise map, using the properties of this component and the noise field from a `NoiseComponent`, replacing the existing map if any.
    @discardableResult
    open func generateNoiseMap() -> GKNoiseMap? {
        guard let noiseComponent = coComponent(NoiseComponent.self) else { return self.noiseMap }
        
        self.noiseMap = GKNoiseMap(noiseComponent.noise,
                                   size:         self.size,
                                   origin:       self.origin,
                                   sampleCount:  self.sampleCount,
                                   seamless:     self.isSeamless)
        return self.noiseMap
    }
}

