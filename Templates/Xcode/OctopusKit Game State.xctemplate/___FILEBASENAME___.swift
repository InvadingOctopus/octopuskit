//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

final class ___FILEBASENAMEASIDENTIFIER___: OctopusGameState {
    
    override var validNextStates: [OctopusGameState.Type] {
        // Customize: Specify the valid states that this state can transition to.
        // NOTE: Do not perform any logic to conditionally control state transitions here. See `OctopusGameState` documentation.
        []  // Default: allow all states.
    }
    
    init() {
        // NOTE: Game state classes are initialized when the game coordinator is initialized: on game launch.
        super.init(associatedSceneClass:  <#SceneForThisState#>.self,
                   associatedSwiftUIView: <#UIForThisState#>())
    }
    
}
