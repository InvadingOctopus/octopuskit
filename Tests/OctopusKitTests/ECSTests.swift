//
//  ECSTests.swift
//  OctopusKit Tests
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/5.
//

import XCTest
import GameplayKit
@testable import OctopusKit

/// Tests for the Entity-Component-System core objects.
final class ECSTests: XCTestCase {
    
    class BasicComponentA: OctopusComponent {}
    class BasicComponentB: OctopusComponent {}
    
    class ComponentWithDependencies: OctopusComponent {
        override var requiredComponents: [GKComponent.Type]? {
            [BasicComponentA.self, BasicComponentB.self]
        }
    }
    
    func testEntity() {
    
        // 1: Name should match.
        
        let name    = "TestEntity"
        let entity  = OctopusEntity(name: name)
        
        XCTAssertEqual(entity.name, name)
    }
    
    func testComponentAdd() {
        
        var entity:     OctopusEntity
        var component1: BasicComponentA
        
        // Repeat these tests 3 times; once with 1 component, then with 2 components, then with 3 components via an array initializer.
        
        for passCount in 1...2 {
        
            entity      = OctopusEntity()
            component1  = BasicComponentA()
            
            switch passCount {
                
            case 1: entity.addComponent(component1)
                
            case 2: entity.addComponent(component1)
                    entity.addComponent(BasicComponentB())
                
            case 3: entity = OctopusEntity(components: [component1, BasicComponentB(), ComponentWithDependencies()])
                
            default: break
            }
            
            // 1: Entity must report the correct component count.
            XCTAssertEqual  (entity.components.count, passCount)
            
            // 2: Entity must have a component of type BasicComponentA
            XCTAssertNotNil (entity.component(ofType: BasicComponentA.self))
            
            // 3: Entity's component of type BasicComponentA must be our `component`
            XCTAssertEqual  (entity.component(ofType: BasicComponentA.self), component1)
            
            // 4: Entity's component of type of our component's type must be our component :)
            XCTAssertEqual  (entity.component(ofType: type(of: component1)), component1)
            
            // 5: The subscript must return the same component as component(ofType:)
            XCTAssertEqual  (entity[BasicComponentA.self], entity.component(ofType: BasicComponentA.self))
            
            // 6: component.entity must match our `entity`
            XCTAssertEqual  (entity, component1.entity)
            XCTAssertEqual  (entity, entity.components.first?.entity)
            
            // 7: A different type of component should not match our `component`
            XCTAssertNotEqual(entity.component(ofType: BasicComponentB.self), component1)
        }
    }
    
    func testComponentRemove() {
        
        let component1  = BasicComponentA()
        let component2  = BasicComponentB()
        let entity      = OctopusEntity(components: [component1, component2, ComponentWithDependencies()])
        
        // 1: Entity must report the correct component count.
        
        let previousCount = entity.components.count
        
        entity.removeComponent(ofType: BasicComponentA.self)

        XCTAssertEqual  (entity.components.count, previousCount - 1)
        
        // 2: component(ofType:) for a removed component must return `nil`
        XCTAssertNil    (entity[BasicComponentA.self])
        
        // 3: Removed component's entity must be `nil`
        XCTAssertNil    (component1.entity)
        
        // 4: Other components must be untouched.
        XCTAssertEqual  (entity[BasicComponentB.self], component2)
        XCTAssertNotNil (entity[ComponentWithDependencies.self])
    }
    
    func testComponentMove() {
       
        let entity1     = OctopusEntity()
        let entity2     = OctopusEntity()
        let component1  = BasicComponentA()
        
        // Adding the same component to another entity should remove it from the previous entity.
        entity1.addComponent(component1)
        entity2.addComponent(component1)
        
        // 1: entity1 should no longer have a BasicComponentA
        // This behavior is provided by OctopusEntity
        XCTAssertEqual      (entity1.components.count, 0)
        XCTAssertNil        (entity1[BasicComponentA.self])
        
        // 2: entity2 should have component1
        XCTAssertEqual      (entity2.components.count, 1)
        XCTAssertNotNil     (entity2[BasicComponentA.self])
        XCTAssertEqual      (entity2[BasicComponentA.self], component1)
        
        // 3: component1.entity should be the new parent.
        XCTAssertNotEqual   (component1.entity, entity1)
        XCTAssertEqual      (component1.entity, entity2)
        
        // Add the component back to entity1
        entity1.addComponent(component1)
        
        // 4: entity2 should no longer have a BasicComponentA
        // This behavior is provided by OctopusEntity
        XCTAssertEqual      (entity2.components.count, 0)
        XCTAssertNil        (entity2[BasicComponentA.self])
        
        // 5: entity1 should have component1
        XCTAssertEqual      (entity1.components.count, 1)
        XCTAssertNotNil     (entity1[BasicComponentA.self])
        XCTAssertEqual      (entity1[BasicComponentA.self], component1)
        
        // 6: component1.entity should be entity1 again.
        XCTAssertNotEqual   (component1.entity, entity2)
        XCTAssertEqual      (component1.entity, entity1)
    }
    
    func testComponentDuplicates() {
        
        let entity     = OctopusEntity()
        let component1 = BasicComponentA()
        let component2 = BasicComponentA()
        
        // An entity may only have a single component of a specific class.
        entity.addComponent(component1)
        entity.addComponent(component2)
        
        // 1: `entity` should report only 1 component.
        XCTAssertEqual  (entity.components.count, 1)
        
        // 2: Querying `entity` for a BasicComponentA should return the most recently-added instance: `component2`
        XCTAssertEqual  (entity[BasicComponentA.self], component2)
        
        // 3: The replaced component1's `entity` should be `nil`
        XCTAssertNil    (component1.entity) // This behavior is provided by OctopusEntity.
        
        // 4: component2.entity should be `entity`
        XCTAssertEqual  (component2.entity, entity)
    }
    
    func testCoComponents() {
        
        let component1  = BasicComponentA()
        let component2  = BasicComponentB()
        var entity:       OctopusEntity
        
        // 1: Components must be able to see each other.
        
        entity = OctopusEntity(components: [component1, component2])
        
        XCTAssertEqual  (component1.coComponent(ofType: BasicComponentB.self), component2)
        XCTAssertEqual  (component2.coComponent(ofType: BasicComponentA.self), component1)
        
        XCTAssertEqual  (component1.coComponent(ofType: type(of: component2).self), component2)
        XCTAssertEqual  (component2.coComponent(ofType: type(of: component1).self), component1)
        
        // 2: OctopusComponent.coComponent(ofType:) should not report `self`
        XCTAssertNil    (component1.coComponent(ofType: BasicComponentA.self))
        XCTAssertNil    (component2.coComponent(ofType: BasicComponentB.self))
        
        // 3: Components should not be able to see each other after removal.
        entity.removeComponent  (ofType: BasicComponentB.self)
        XCTAssertNil            (component1.coComponent(ofType: BasicComponentB.self))
        
        // 3B: Test again with a different order (includes test for moving components to a new entity.)
        entity = OctopusEntity  (components: [component1, component2])
        entity.removeComponent  (ofType: BasicComponentA.self)
        XCTAssertNil            (component2.coComponent(ofType: BasicComponentA.self))
    }
    
    func testComponentDependencies() {
        
        var entity:     OctopusEntity

        // 1: OctopusComponent.checkEntityForRequiredComponents() should return `true` if there are no `requiredComponents` even if the component has no entity.
        
        let standaloneComponent = BasicComponentA()
        XCTAssertTrue(standaloneComponent.checkEntityForRequiredComponents())
        
        // 2: checkEntityForRequiredComponents() should return `true` if there are no `requiredComponents`.
        
        let entityComponent = BasicComponentA()
        entity = OctopusEntity(components: [entityComponent])
    
        XCTAssertTrue(entityComponent.checkEntityForRequiredComponents())
        
        // 3: checkEntityForRequiredComponents() should return `false` if there are `requiredComponents` but no entity.
        
        let standaloneComponentWithDependencies = ComponentWithDependencies()
        XCTAssertFalse(standaloneComponentWithDependencies.checkEntityForRequiredComponents())
        
        // 4: checkEntityForRequiredComponents() should return `false` if the entity does not have the `requiredComponents`.
        
        let entityComponentWithDependencies = ComponentWithDependencies()
        entity = OctopusEntity(components: [entityComponentWithDependencies])
        
        XCTAssertFalse(entityComponentWithDependencies.checkEntityForRequiredComponents())
        
        // 5: checkEntityForRequiredComponents() should return `false` if only one dependency is available but not all.
        
        entity = OctopusEntity(components: [BasicComponentA(), entityComponentWithDependencies])
        XCTAssertFalse(entityComponentWithDependencies.checkEntityForRequiredComponents())
        
        // 6: checkEntityForRequiredComponents() should return `true` if all dependencies are available.
        entity.addComponent(BasicComponentB())
        XCTAssertTrue(entityComponentWithDependencies.checkEntityForRequiredComponents())
    }
    
    func testRelayComponent() {
        
        // TODO: Test RelayComponent.sceneComponentType
        
        // NOTE: Do not use subscripts here, as that calls componentOrRelay(ofType:)
        
        var entity1, entity2:           OctopusEntity
        var componentA:                 BasicComponentA
        var componentB:                 BasicComponentB
        var relayComponentA:            RelayComponent<BasicComponentA>
        var relayComponentB:            RelayComponent<BasicComponentB>
        var componentWithDependencies:  ComponentWithDependencies
        
        // Connect components in different entities via RelayComponents.
        
        componentA      = BasicComponentA()
        entity1         = OctopusEntity(components: [componentA])
        
        relayComponentA = RelayComponent(for: componentA)
        entity2         = OctopusEntity(components: [relayComponentA])
        
        // 0: Silence the warning about "Variable entity1 was written to, but never read" :)
        XCTAssertEqual  (componentA.entity, entity1)
        
        // 1: relayComponentA.target should be componentA
        XCTAssertEqual  (relayComponentA.target, componentA)
        
        // 2: The type of relayComponentA.target (unwrapped) should be BasicComponentA
        XCTAssert       (type(of: relayComponentA.target!) == BasicComponentA.self)
        
        // 3: entity2 should not have a BasicComponentA
        XCTAssertNil    (entity2.component(ofType: BasicComponentA.self))
        
        // 4: entity2 should have a RelayComponent<BasicComponentA> and its target should be basicComponentA
        XCTAssertNotNil (entity2.component(ofType: RelayComponent<BasicComponentA>.self))
        XCTAssertEqual  (entity2.component(ofType: RelayComponent<BasicComponentA>.self)?.target, componentA)
        
        // 5: GKEntity.componentOrRelay(ofType:) should be able to find a BasicComponentA in entity2
        XCTAssertEqual  (entity2.componentOrRelay(ofType: BasicComponentA.self), componentA)
        
        // 6: GKComponent.coComponent(ofType:) should find co-components via RelayComponent
        
        componentB      = BasicComponentB()
        entity2         = OctopusEntity(components: [relayComponentA, componentB])
        
        XCTAssertEqual  (componentB.coComponent(ofType: BasicComponentA.self), componentA)
        
        // 7: GKComponent.coComponent(ofType:ignoreRelayComponents: true) should NOT find co-components via RelayComponent
        
        XCTAssertNotEqual  (componentB.coComponent(ofType: BasicComponentA.self, ignoreRelayComponents: true), componentA)
        
        // 8: Entities should be able to have multiple RelayComponents with targets of different types.
        
        componentA      = BasicComponentA()
        componentB      = BasicComponentB()
        entity1         = OctopusEntity(components: [componentA, componentB])
        
        relayComponentA = RelayComponent(for: componentA)
        relayComponentB = RelayComponent(for: componentB)
        entity2         = OctopusEntity(components: [relayComponentA, relayComponentB])
        
        XCTAssertNotNil  (entity2.component(ofType: RelayComponent<BasicComponentA>.self))
        XCTAssertNotNil  (entity2.component(ofType: RelayComponent<BasicComponentB>.self))
        
        XCTAssertNotEqual(entity2.component(ofType: RelayComponent<BasicComponentA>.self),
                          entity2.component(ofType: RelayComponent<BasicComponentB>.self))
        
        // 9: OctopusComponent.checkEntityForRequiredComponents() should be able to find dependencies via RelayComponent
        
        componentA      = BasicComponentA()
        entity1         = OctopusEntity(components: [componentA])
        
        componentWithDependencies = ComponentWithDependencies()
        relayComponentA = RelayComponent(for: componentA)
        componentB      = BasicComponentB()
        entity2         = OctopusEntity(components: [relayComponentA,
                                                     componentB,
                                                     componentWithDependencies])
        
        XCTAssertEqual  (componentWithDependencies.coComponent(ofType: BasicComponentA.self), componentA)
        XCTAssertEqual  (componentWithDependencies.coComponent(ofType: BasicComponentB.self), componentB)
        XCTAssertTrue   (componentWithDependencies.checkEntityForRequiredComponents()) // If this fails, search comments for "BUG: 201804029A"
        
        // 10: RelayComponent should remain linked to its target even if the target is removed from its entity.
        
        componentA      = BasicComponentA()
        entity1         = OctopusEntity(components: [componentA])
        
        relayComponentA = RelayComponent(for: componentA)
        componentB      = BasicComponentB()
        entity2         = OctopusEntity(components: [relayComponentA, componentB])
        
        componentA.removeFromEntity()
        
        XCTAssertEqual  (relayComponentA.target, componentA)
        XCTAssertEqual  (componentB.coComponent(ofType: BasicComponentA.self), componentA)
    }
    
    static var allTests = [
        ("Test entity basics", testEntity),
        ("Test adding components", testComponentAdd),
        ("Test removing components", testComponentRemove),
        ("Test moving components", testComponentMove),
        ("Test duplicate components", testComponentDuplicates),
        ("Test co-components", testCoComponents),
        ("Test component dependencies", testComponentDependencies),
        ("Test RelayComponent", testRelayComponent)
    ]
}
