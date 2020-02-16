//
//  CombatBehaviorComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/05/06.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit
import GameplayKit

/// Encapsulates a set of behaviors for units in combat.
public final class CombatBehaviorComponent: OKComponent {
    
    // ⚠️ PROTOTYPE: Not fully implemented.
    
    // TODO: A type for a set of percentages-values that automatically modify each other.
    
    public struct Posture: Equatable, Hashable {
        public var defensive: Double
        public var aggressive: Double
    }
    
    public enum Attitude {
        /// Cannot be exited until combat is over, incapacitation or death.
        case panicking
        
        case cowardly
        
        case stoic
        
        case camaraderie
        
        case intimidating
        
        case raucous
        
        /// Cannot be exited until combat is over, incapacitation or death.
        case berserk
    }
    
    public enum Movement {
        /// Just run away at full speed. Does not try to defend or try to be safe. May get struck or killed during movement.
        case flee
        
        case retreat
    
        case hold
        
        case aid
        
        case advance
        
        /// Just run ahead at full speed. Does not try to defend or try to be safe. May get struck or killed during movement.
        case charge
    }
    
    public struct TargettingPriorities {
        
        public enum Distance {
            case closest
            case farthest
        }
        
        public enum Threat {
            case weakest
            case strongest
        }
        
        public enum Attacker {
            case myAttacker
            case allyAttacker
        }
        
        public enum SpecificTrait {
            case leader
            case archer
            case caster
            case retreater
            case dying
        }
        
        public var wild: Bool
    }
    
    public struct Toggles {
        /// - NOTE: Not effective when fleeing or charging.
        public var shouldSeekCover: Bool
    }
}

