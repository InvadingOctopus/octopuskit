//___FILEHEADER___

import SwiftUI
import SpriteKit
import GameplayKit
import OctopusKit

// MARK: - Game State

final class ___FILEBASENAMEASIDENTIFIER___: OctopusGameState {
    
    open var validNextStates: [OctopusGameState.Type] {
        // Customize: Specify the valid states that this state can transition to.
        // NOTE: Do not perform any logic to conditionally control state transitions here. See `OctopusGameState` documentation.
        []  // Default: allow all states.
    }
    
    init() {
        // NOTE: Game state classes are initialized when the game coordinator is initialized: on game launch.
        super.init(associatedSceneClass:  ___FILEBASENAMEASIDENTIFIER___Scene.self,
                   associatedSwiftUIView: ___FILEBASENAMEASIDENTIFIER___UI())
    }
    
}

// MARK: - Scene

final class ___FILEBASENAMEASIDENTIFIER___Scene: OctopusScene {
    
    override func createComponentSystems() -> [GKComponent.Type] {
        [
            // Customize. Each component must be listed after the components it depends on; check the `requiredComponents` property.
            
            // 1: Time and state.
            
            TimeComponent.self,
            StateMachineComponent.self,
            
            // 2: Player input.
            
            OSMouseOrTouchEventComponent.self,
            PointerEventComponent.self,
            NodePointerStateComponent.self,
            NodePointerClosureComponent.self,
            
            // 3: Movement and physics.
            
            PointerControlledPositioningComponent.self,
            OctopusAgent2D.self,
            PhysicsComponent.self, // The physics component should come in after other components have modified node properties, so it can clamp the velocity etc. if such limits have been specified.
            
            // 4: Custom code and anything else that depends on the final placement of nodes per frame.
            
            PhysicsEventComponent.self,
            RepeatingClosureComponent.self,
            DelayedClosureComponent.self,
            CameraComponent.self
        ]
    }
    
    override func createContents() {
        super.createContents()
        // Customize: This is where you construct entities to add to your scene.
        
        self.entity?.addComponents([sharedMouseOrTouchEventComponent,
                                    sharedPointerEventComponent])
        
        addEntity(OctopusEntity(name: "", components: [
            // Customize
        ]))
    }
    
}

// MARK: - UI

struct ___FILEBASENAMEASIDENTIFIER___UI: View {

    @EnvironmentObject var gameCoordinator: OctopusGameCoordinator
    
    var body: some View {
        <#Text("___FILEBASENAMEASIDENTIFIER___").font(.largeTitle).foregroundColor(.gray)#>
    }
    
}

struct ___FILEBASENAMEASIDENTIFIER___UI_Previews: PreviewProvider {
    static var previews: some View {
        ___FILEBASENAMEASIDENTIFIER___UI()
            // .environmentObject(gameCoordinator)
    }
}
