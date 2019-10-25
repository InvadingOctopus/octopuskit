//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

final class ___FILEBASENAMEASIDENTIFIER___: OctopusScene {
        
    // MARK: - Life Cycle
    
    override func createComponentSystems() -> [GKComponent.Type] {
        [
            // Customize
            
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
            
            PhysicsEventComponent.self,
            RepeatingClosureComponent.self,
            DelayedClosureComponent.self,
            CameraComponent.self
        ]
    }
    
    override func prepareContents() {
        super.prepareContents()
        // Customize: This is where you build your scene.
    }
    
}

