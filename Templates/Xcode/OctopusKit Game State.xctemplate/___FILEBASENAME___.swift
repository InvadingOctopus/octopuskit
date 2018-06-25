//___FILEHEADER___

import SpriteKit
import GameplayKit

final class ___FILEBASENAMEASIDENTIFIER___: OctopusGameState {
    
    init() {
        // NOTE: Game state classes are initialized when the game controller is initialized: on game launch.
        super.init(associatedSceneClass: <#Scene for this state#>.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // Customize: Enter the valid states that this state can transition to.
        // You may perform game-specific checks here to allow different states based on different conditions.
        return stateClass is OctopusGameState.Type // Default: allow all states.
    }
    
    // MARK: - OctopusSceneDelegate
    
    // Customize: This section may be deleted if the scene is not going to use these methods.
    
    override func octopusSceneDidFinish(_ scene: OctopusScene) {
        // By default this method attempts to transition to the state that logically follows after the scene for this state finishes, if applicable. e.g.: `TitleState` after a `GameOverState`.
        // You may perform game-specific checks here to enter a different state based on different conditions.
        self.octopusSceneDidChooseNextGameState(scene)
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        // Enter the state that logically follows this state, if applicable. e.g.: `PlayState` after a `PausedState`.
        // You may perform game-specific checks here to choose different states based on different conditions.
        return stateMachine?.enter(<#Next game state#>.self) ?? false
    }

    @discardableResult override func octopusSceneDidChoosePreviousGameState(_ scene: OctopusScene) -> Bool {
        // Enter the state that logically precedes this state, if applicable. e.g.: `PlayState` before a `GameOverState`.
        // You may perform game-specific checks here to choose different states based on different conditions.
        return stateMachine?.enter(<#Previous game state#>.self) ?? false
    }
    
}
