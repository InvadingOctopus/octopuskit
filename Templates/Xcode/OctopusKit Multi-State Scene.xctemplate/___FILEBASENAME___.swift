//___FILEHEADER___

import SpriteKit
import GameplayKit

// MARK: - PlayableState

// A placeholder provided as an example of a possible state for the game. Include this state when initializing the `OctopusGameController` state machine. This class may be moved out to a separate file and extended.

final class PlayableState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass: GameScene.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PausedState.self
    }
}

// MARK: - PausedState

// A placeholder provided as an example of a possible state for the game. Include this state when initializing the `OctopusGameController` state machine. This class may be moved out to a separate file and extended.

final class PausedState: OctopusGameState {
    
    init() {
        super.init(associatedSceneClass: GameScene.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayableState.self
    }
}

final class ___FILEBASENAMEASIDENTIFIER___: OctopusScene {
        
    // MARK: - Life Cycle
    
    override func willMove(to view: SKView) {
        super.willMove(to: view)
        // Set scaling and any other properties that need to be set before presenting in the view.
        // self.scaleAndCropToFitLandscape(in: view) // Fill landscape orientation at the cost of cutting out some edges.
        // self.halveSizeAndFit(in: view) // For a pixelated effect.
    }
    
    /*
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // view.setAllDebugStatsVisibility(to: true)
        // view.showsPhysics = false
    }
    */
    
    override func prepareContents() {
        super.prepareContents()
        createComponentSystems()
        createEntities()
    }
    
    fileprivate func createComponentSystems() {
        
        super.componentSystems.createSystems(forClasses: [ // Customize
            
            // 1: Time and state.
            
            TimeComponent.self,
            StateMachineComponent.self,
            
            // 2: Player input.
            
            TouchEventComponent.self,
            NodeTouchComponent.self,
            NodeTouchClosureComponent.self,
            MotionManagerComponent.self,
            TouchControlledPositioningComponent.self,
            
            // 3: Movement and physics.
            
            OctopusAgent2D.self,
            PhysicsComponent.self, // The physics component should come in after other components have modified node properties, so it can clamp the velocity etc. if such limits have been specified.
            
            // 4: Custom code and anything else that depends on the final placement of nodes per frame.
            
            PhysicsContactEventComponent.self,
            RepeatedClosureComponent.self,
            DelayedClosureComponent.self,
            CameraComponent.self
            ])
    }
    
    fileprivate func createEntities() {
    }
    
    // MARK: - Frame Update
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        guard !isPaused && !isPausedBySystem && !isPausedByPlayer && !isPausedByModalInterface else { return }
        
        // Update game state, entities and components.
        
        OctopusEngine.shared?.gameController.update(deltaTime: updateTimeDelta)
        updateSystems(in: componentSystems, deltaTime: updateTimeDelta)
    }
    
    // MARK: - States
    
    /// Useful in games that use a single scene for multiple games states (e.g. displaying an overlay for the paused state, menus, etc. on the gameplay view.)
    override func gameControllerDidEnterState(_ state: GKState, from previousState: GKState?) {
        super.gameControllerDidEnterState(state, from: previousState)
        
        // Common to every state, before state-specific
        
        // ...
        
        // State-specific
        
        switch type(of: state) { // Can also use tuples: `(type(of: previousState), type(of: state))`
            
        case is PlayableState.Type: // Entering PlayableState
            break
            
        case is PausedState.Type: // Entering PausedState
            physicsWorld.speed = 0
            
        default:
            break
        }
        
        // Common to every state, after state-specific
        
        // ...
    }
    
    /// Useful in games that use a single scene for multiple games states (e.g. removing overlays that were displaying during a paused state, menus, etc.)
    override func gameControllerWillExitState(_ exitingState: GKState, to nextState: GKState) {
        super.gameControllerWillExitState(exitingState, to: nextState)
        
        // Common to every state, before state-specific
        
        // ...
        
        // State-specific
        
        switch type(of: exitingState) { // Can also use tuples: `(type(of: exitingState), type(of: nextState))`
            
        case is PlayableState.Type: // Exiting PlayableState
            break
            
        case is PausedState.Type: // Exiting PausedState
            physicsWorld.speed = 1
            
        default:
            break
        }
        
        // Common to every state, after state-specific
        
        // ...
    }
    
    override func pausedBySystem() {
        if
            let currentState = OctopusEngine.shared?.gameController.currentState,
            type(of: currentState) is PlayableState.Type
        {
            self.octopusSceneDelegate?.octopusScene(self, didRequestGameStateClass: PausedState.self)
        }
    }
    
    override func unpausedBySystem() {
        // Remain in the paused state so the player has to manually unpause when they are ready.
        
        if
            let currentState = OctopusEngine.shared?.gameController.currentState,
            type(of: currentState) is PausedState.Type
        {
            // Since we are still in the paused state, keep the action paused, preventing `super.applicationDidBecomeActive()` from resuming it.
            physicsWorld.speed = 0
        }
    }
    
    override func pausedByPlayer() {
        // This transition should be subject to the validation logic in the relevant `OctopusGameState` classes.
        self.octopusSceneDelegate?.octopusScene(self, didRequestGameStateClass: PausedState.self)
    }
    
    override func unpausedByPlayer() {
        // This transition should be subject to the validation logic in the relevant `OctopusGameState` classes.
        self.octopusSceneDelegate?.octopusScene(self, didRequestGameStateClass: PlayableState.self)
    }
    
}
