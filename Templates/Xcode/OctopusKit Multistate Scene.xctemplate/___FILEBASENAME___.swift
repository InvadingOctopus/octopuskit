//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

// MARK: - PlayableState

// A placeholder provided as an example of a possible state for the game. Include this state when initializing the `OctopusGameCoordinator` state machine. This class may be moved out to a separate file and extended.

final class PlayableState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass:  ___FILEBASENAMEASIDENTIFIER___.self,
                   associatedSwiftUIView: <#UIForThisState#>())
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PausedState.self
    }
}

// MARK: - PausedState

// A placeholder provided as an example of a possible state for the game. Include this state when initializing the `OctopusGameCoordinator` state machine. This class may be moved out to a separate file and extended.

final class PausedState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass:  ___FILEBASENAMEASIDENTIFIER___.self,
                   associatedSwiftUIView: <#UIForThisState#>())
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayableState.self
    }
}

final class ___FILEBASENAMEASIDENTIFIER___: OctopusScene {
        
    // MARK: - Life Cycle
    
    override func createComponentSystems() -> [GKComponent.Type] {
        [
            // Customize. Each component must be listed after the components it depends on; check the `requiredComponents` property.
            
            // 1: Time and state.
            
            TimeComponent.self,
            StateMachineComponent.self,
            
            // 2: Player input.
            
            OSMouseOrTouchEventComponent.self,
            PointerEventComponent.self,
            NodeTouchComponent.self,
            NodeTouchClosureComponent.self,
            MotionManagerComponent.self,
            
            // 3: Movement and physics.
            
            TouchControlledPositioningComponent.self,
            OctopusAgent2D.self,
            PhysicsComponent.self, // The physics component should come in after other components have modified node properties, so it can clamp the velocity etc. if such limits have been specified.
            
            // 4: Custom code and anything else that depends on the final placement of nodes per frame.
            
            PhysicsEventComponent.self,
            RepeatingClosureComponent.self,
            DelayedClosureComponent.self,
            CameraComponent.self
        ]
    }
    
    override func prepareContents() {
        super.prepareContents()
        // Customize: This is where you construct entities to add to your scene.
        //
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
        if  let currentState = OctopusKit.shared?.gameCoordinator.currentState,
            type(of: currentState) is PlayableState.Type
        {
            self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
        }
    }
    
    override func didUnpauseBySystem() {
        // If we were in the paused game state, remain in that state so the player has to manually unpause when they are ready.
        
        if  let currentState = OctopusKit.shared?.gameCoordinator.currentState,
            type(of: currentState) is PausedState.Type
        {
            // Since we are still in the paused state, keep the action paused, preventing `super.applicationDidBecomeActive()` from resuming it.
            physicsWorld.speed = 0
        }
    }
    
    override func didPauseByPlayer() {
        // This transition should be subject to the validation logic in the relevant `OctopusGameState` classes.
        self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
    }
    
    override func didUnpauseByPlayer() {
        // This transition should be subject to the validation logic in the relevant `OctopusGameState` classes.
        self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PlayableState.self)
    }
    
}
