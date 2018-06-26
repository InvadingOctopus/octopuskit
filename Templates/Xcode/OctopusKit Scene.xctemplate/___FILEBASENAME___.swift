//___FILEHEADER___

import SpriteKit
import GameplayKit

final class ___FILEBASENAMEASIDENTIFIER___: OctopusScene {
        
    // MARK: - Life Cycle
    
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
            
            // 3: Movement and physics.
            
            TouchControlledPositioningComponent.self,
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
        // Customize: This is where you build your scene.
    }
    
    // MARK: - Frame Update
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        guard !isPaused && !isPausedBySystem && !isPausedByPlayer && !isPausedBySubscene else { return }
        
        // Update game state, entities and components.
        
        OctopusKit.shared?.gameController.update(deltaTime: updateTimeDelta)
        updateSystems(in: componentSystems, deltaTime: updateTimeDelta)
    }

}

