//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

final class ___FILEBASENAMEASIDENTIFIER___: OctopusGameState {
    
    init() {
        // NOTE: Game state classes are initialized when the game coordinator is initialized: on game launch.
        super.init(associatedSceneClass:  <#SceneForThisState#>.self,
                   associatedSwiftUIView: <#UIForThisState#>())
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // Customize: Specify the valid states that this state can transition to.
        // You may perform game-specific checks here to allow different states based on different conditions.
        return stateClass is OctopusGameState.Type // Default: allow all states.
    }
    
}
