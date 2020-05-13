//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit
import SwiftUI

/// A component with an associated SwiftUI view.
final class ___FILEBASENAMEASIDENTIFIER___: OKComponent, UpdatedPerFrame, ObservableObject  {
    
    override var requiredComponents: [GKComponent.Type]? {
        []
    }
    
    // MARK: Observed Properties
    
    @Published var frame: Int = 0 // CUSTOMIZE
    
    // MARK: Life Cycle
    
    override func didAddToEntity(withNode node: SKNode) {
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.frame += 1 // CUSTOMIZE
    }
    
    override func willRemoveFromEntity(withNode node: SKNode) {
        
    }
    
    // MARK: - UI
    
    /// Creates and returns a copy of this component's associated SwiftUI view, with this instance of the component as the view's observed property.
    var ui: ___FILEBASENAMEASIDENTIFIER___.UI {
        // NOTE: Returning a singleton may not make a difference in performance, as SwiftUI Views are value types (that would be copied anyway).
        ___FILEBASENAMEASIDENTIFIER___.UI(component: self)
    }
    
    /// A SwiftUI view that displays UI based on the data of a ___FILEBASENAMEASIDENTIFIER___.
    struct UI: View {
        
        @ObservedObject var component: ___FILEBASENAMEASIDENTIFIER___
        
        var body: some View {
            Text("\(component.frame)") // CUSTOMIZE
        }
        
    }
    
}
