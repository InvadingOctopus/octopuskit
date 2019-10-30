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
        // NOTE: Do not use this method to conditionally control state transitions. Perform such conditional logic in the scene or UI, before calling the game coordinator state machine’s enter(_:) method.
        return stateClass is OctopusGameState.Type // Default: allow all states.
    }
    
}
