//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

final class ___FILEBASENAMEASIDENTIFIER___: OctopusEntityState {
    
    override init(entity: OctopusEntity) {
        super.init(entity: entity)
        
        self.componentsToAddOnEntry = [] // Customize
        
        self.componentTypesToRemoveOnExit = [] // Customize
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        switch previousState {
            
        case is OctopusEntityState: // Customize
            break
            
        default: break
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        switch nextState {
            
        case is OctopusEntityState: // Customize
            break
            
        default: break
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is OctopusEntityState.Type // Customize
    }
}

