//
//  SKPhysicsContact+OctopusKit.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/27.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

public extension SKPhysicsContact {
    
    // TODO: Tests
    
    /// Returns an array of the bodies whose `categoryBitMask` contains all of the specified flags. The returned bodies may have more flags besides the search criteria. If neither body has the specified categories, an empty array is returned.
    @inlinable
    final func bodiesMatchingCategories(_ categories: PhysicsCategories) -> [SKPhysicsBody] {
        
        var matchingBodies: [SKPhysicsBody] = []
        
        // Loops may not be as efficient as just checking twice :P
        
        if  PhysicsCategories(self.bodyA.categoryBitMask).contains(categories) {
            matchingBodies.append(bodyA)
        }
        
        if  PhysicsCategories(self.bodyB.categoryBitMask).contains(categories) {
            matchingBodies.append(bodyB)
        }
        
        return matchingBodies
    }
}
