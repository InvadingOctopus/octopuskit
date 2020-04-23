//
//  RandomizationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/03/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

/// Encapsulates a `GKRandom` object.
open class RandomizationComponent: OKComponent {
    
    open var source: GKRandom
    
    public init(source: GKRandom = GKRandomSource()) {
        self.source = source
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension RandomizationComponent: RandomNumberGenerator {
    
    // TODO: Verify & Test
    
    // ⚠️ WARNING: GKRandomDistribution does not currently work when accessed as a RandomNumberGenerator
    
    /// Calls `source.next()`
    ///
    /// - Returns: An unsigned 64-bit random value.
    public func next<T>() -> T
        where T: FixedWidthInteger, T: UnsignedInteger
    {
        return T(abs(self.source.nextInt()))
    }
    
    /// Calls `source.next(upperBound:)`
    ///
    /// - Returns - A random value of T in the range 0..<upperBound. Every value in the range 0..<upperBound is equally likely to be returned.
    public func next<T>(upperBound: T) -> T
        where T: FixedWidthInteger, T: UnsignedInteger
    {
        return T(abs(self.source.nextInt(upperBound: Int(upperBound))))
    }
}
