//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

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
    }
    
}

