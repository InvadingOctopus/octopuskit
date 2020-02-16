//
//  SKNode+OctopusAnimations.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/11/09.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

extension SKNode {
    
    /// Cycles the node's `isHidden` state between `true` and `false` for the specified number of times, optionally removing the node from its parent at the end.
    @inlinable
    open func blink(times: Int,
                    withDelay delay: TimeInterval = 0.1,
                    removeFromParentOnCompletion: Bool = false)
    {
        guard times > 0 else { return }
        
        let blink = SKAction.repeat(
            SKAction.blink(withDelay: delay),
            count: times)
        
        var sequence: SKAction
        
        if  removeFromParentOnCompletion {
            sequence = SKAction.sequence([
                blink,
                .removeFromParent()])
        
        } else {
            sequence = blink
        }
        
        self.run(sequence, withKey: SKAction.OKAnimationKeys.blink)
    }
    
}
