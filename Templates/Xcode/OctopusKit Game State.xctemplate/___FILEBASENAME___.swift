//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

final class ___FILEBASENAMEASIDENTIFIER___: OKGameState {
    
    init() {
        // NOTE: Game state classes are initialized when the game coordinator is initialized: on game launch.
        super.init(associatedSceneClass:  <#SceneForThisState#>.self,
                   associatedSwiftUIView: <#UIForThisState#>())
    }
    
    override var validNextStates: [OKGameState.Type] {
        // Customize: Specify the valid states that this state can transition to.
        // NOTE: Do not perform any logic to conditionally control state transitions here. See `OKGameState` documentation.
        []  // Default: allow all states.
    }
    
}
