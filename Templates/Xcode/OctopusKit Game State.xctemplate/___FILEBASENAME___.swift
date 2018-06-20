//___FILEHEADER___

import SpriteKit
import GameplayKit

final class ___FILEBASENAMEASIDENTIFIER___: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass: GameScene.self) // Customize
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is OctopusGameState.Type // Customize
    }
    
    // MARK: - OctopusSceneDelegate
    
    override func octopusSceneDidFinish(_ scene: OctopusScene) {
        self.octopusSceneDidChooseNextGameState(scene) // Customize
    }
    
    @discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OctopusScene) -> Bool {
        return stateMachine?.enter(OctopusGameState.self) ?? false // Customize
    }
    
    @discardableResult override func octopusSceneDidChoosePreviousGameState(_ scene: OctopusScene) -> Bool {
        return stateMachine?.enter(OctopusGameState.self) ?? false // Customize
    }
    
}
