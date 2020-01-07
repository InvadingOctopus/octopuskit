//___FILEHEADER___

import SpriteKit
import GameplayKit
import OctopusKit

final class ___FILEBASENAMEASIDENTIFIER___: OKEntityState {
    
    override init(entity: OKEntity) {
        super.init(entity: entity)
        
        self.componentsToAddOnEntry = [] // Customize
        
        self.componentTypesToRemoveOnExit = [] // Customize
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        switch previousState {
            
        case is OKEntityState: // Customize
            break
            
        default: break
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        switch nextState {
            
        case is OKEntityState: // Customize
            break
            
        default: break
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is OKEntityState.Type // Customize
    }
}

