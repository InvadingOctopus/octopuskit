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
        
        self.entity?.addComponents([sharedMouseOrTouchEventComponent,
                                    sharedPointerEventComponent])
        
        addEntity(OKEntity(name: "", components: [
            // Customize
        ]))
    }
    
}

