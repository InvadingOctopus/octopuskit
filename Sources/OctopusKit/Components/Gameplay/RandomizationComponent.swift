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
    
    /// Calls `source.next()` if `source` conforms to `RandomNumberGenerator`, otherwise calls `source.nextInt()` twice to generate an unsigned 64-bit integer.
    ///
    /// - Returns: An unsigned 64-bit random value.
    public func next() -> UInt64 {
        if  var source = self.source as? RandomNumberGenerator {
            return source.next()
        } else {
            // CREDIT: Grigory Entin https://stackoverflow.com/users/1859783/grigory-entin
            // https://stackoverflow.com/a/57370987/1948215
            // GKRandom produces values in the `INT32_MIN...INT32_MAX` range; hence we need two numbers to produce 64-bit value.
            let next1 = UInt64(bitPattern: Int64(self.source.nextInt()))
            let next2 = UInt64(bitPattern: Int64(self.source.nextInt()))
            return next1 ^ (next2 << 32)
        }
    }
    
    /*
    /// Calls `source.next(upperBound:)`
    ///
    /// - Returns - A random value of T in the range 0..<upperBound. Every value in the range 0..<upperBound is equally likely to be returned.
    public func next<T>(upperBound: T) -> T
        where T: FixedWidthInteger, T: UnsignedInteger
    {
        return T(abs(self.source.nextInt(upperBound: Int(upperBound))))
    }
    */
}
