//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

// MARK: - PlayableState

// A placeholder provided as an example of a possible state for the game. Include this state when initializing the `OKGameCoordinator` state machine. This class may be moved out to a separate file and extended.

final class PlayableState: OKGameState {
    
    open var validNextStates: [OKState.Type] {
        [PausedState.self]
    }
    
    init() {
        super.init(associatedSceneClass:  ___FILEBASENAMEASIDENTIFIER___.self,
                   associatedSwiftUIView: <#UIForThisState#>())
    }
}

// MARK: - PausedState

// A placeholder provided as an example of a possible state for the game. Include this state when initializing the `OKGameCoordinator` state machine. This class may be moved out to a separate file and extended.

final class PausedState: OKGameState {
    
    open var validNextStates: [OKState.Type] {
        [PlayableState.self]
    }
    
    init() {
        super.init(associatedSceneClass:  ___FILEBASENAMEASIDENTIFIER___.self,
                   associatedSwiftUIView: <#UIForThisState#>())
    }
}

final class ___FILEBASENAMEASIDENTIFIER___: OKScene {
        
    // MARK: - Life Cycle
    
    override func createComponentSystems() -> [GKComponent.Type] {
        // Customize. Each component must be listed after the components it depends on (as per its `requiredComponents` property.)
        // See OKScene.createComponentSystems() for the default set of commonly-used systems.
        super.createComponentSystems()
    }
    
    override func createContents() {
        // Customize: This is where you construct entities to add to your scene.
        
        // Access these shared components from child entities with `RelayComponent(for:)`
        self.entity?.addComponents([sharedMouseOrTouchEventComponent,
                                    sharedPointerEventComponent])
        
        self.anchorPoint = .half // This places nodes with a position of (0,0) at the center of the scene.
        
        addEntity(OKEntity(name: "", components: [
            // Customize
        ]))
        
        // You may also perform scene construction and deconstruction in `gameCoordinatorDidEnterState(_:from:)` and `gameCoordinatorWillExitState(_:to:)`
    }
    
    // MARK: - States
    
    /// Useful in games that use a single scene for multiple games states (e.g. displaying an overlay for the paused state, menus, etc. on the gameplay view.)
    override func gameCoordinatorDidEnterState(_ state: GKState, from previousState: GKState?) {
        super.gameCoordinatorDidEnterState(state, from: previousState)
        
        // If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
        
        switch type(of: state) { // Tuples may be used here: `(type(of: previousState), type(of: state))`
            
        case is PlayableState.Type: // Entering `PlayableState`
            break
            
        case is PausedState.Type: // Entering `PausedState`
            physicsWorld.speed = 0
            
        default:
            break
        }
    }
    
    /// Useful in games that use a single scene for multiple games states (e.g. removing overlays that were displaying during a paused state, menus, etc.)
    override func gameCoordinatorWillExitState(_ exitingState: GKState, to nextState: GKState) {
        super.gameCoordinatorWillExitState(exitingState, to: nextState)
        
        // If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
        
        switch type(of: exitingState) { // Tuples may be used here: `(type(of: exitingState), type(of: nextState))`
            
        case is PlayableState.Type: // Exiting `PlayableState`
            break
            
        case is PausedState.Type: // Exiting `PausedState`
            physicsWorld.speed = 1
            
        default:
            break
        }
    }
    
    // MARK: - Pausing/Unpausing
    
    override func didPauseBySystem() {
        if  let currentState = OctopusKit.shared.gameCoordinator.currentState,
            type(of: currentState) is PlayableState.Type
        {
            self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
        }
    }
    
    override func didUnpauseBySystem() {
        // If we were in the paused game state, remain in that state so the player has to manually unpause when they are ready.
        
        if  let currentState = OctopusKit.shared.gameCoordinator.currentState,
            type(of: currentState) is PausedState.Type
        {
            // Since we are still in the paused state, keep the action paused, preventing `super.applicationDidBecomeActive()` from resuming it.
            physicsWorld.speed = 0
        }
    }
    
    override func didPauseByPlayer() {
        // This transition should be subject to the validation logic in the relevant `OKGameState` classes.
        self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
    }
    
    override func didUnpauseByPlayer() {
        // This transition should be subject to the validation logic in the relevant `OKGameState` classes.
        self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PlayableState.self)
    }
    
}
