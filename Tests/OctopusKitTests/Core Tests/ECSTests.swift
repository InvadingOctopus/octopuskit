//
//  ECSTests.swift
//  OctopusKitTests
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/5.
//

import XCTest
import GameplayKit
@testable import OctopusKit

/// Tests for the Entity-Component-System core objects.
final class ECSTests: XCTestCase {
    
    // MARK: - Types
    
    /// An entity that gives itself a default name including a random number.
    class TestEntity: OKEntity {
        override init(name: String? = nil, components: [GKComponent] = []) {
            let name = name ?? "TestEntity\(Int.random(in: 100...999))"
            super.init(name: name, components: components)
        }
        required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    }
    
    class TestComponentA: OKComponent {}
    class TestComponentB: OKComponent {}
    
    /// A component that requires `TestComponentA` and `TestComponentB`
    class ComponentWithDependencies: OKComponent {
        override var requiredComponents: [GKComponent.Type]? {
            [TestComponentA.self, TestComponentB.self]
        }
    }
    
    // MARK: - Tests
    
    func testEntity() {
    
        // Name should match.
        
        let name    = "TestEntity"
        let entity  = TestEntity(name: name)
        
        XCTAssertEqual(entity.name, name)
    }
    
    func testComponentAdd() {
        
        var entity:     TestEntity
        var component1: TestComponentA
        
        // Repeat these tests 3 times; once with 1 component, then with 2 components, then with 3 components via an array initializer.
        
        for passCount in 1...2 {
        
            entity      = TestEntity()
            component1  = TestComponentA()
            
            switch passCount {
                
            case 1: entity.addComponent(component1)
                
            case 2: entity.addComponent(component1)
                    entity.addComponent(TestComponentB())
                
            case 3: entity = TestEntity(components: [component1, TestComponentB(), ComponentWithDependencies()])
                
            default: break
            }
            
            // #1: Entity must report the correct component count.
            XCTAssertEqual  (entity.components.count, passCount)
            
            // #2: Entity must have a component of type TestComponentA
            XCTAssertNotNil (entity.component(ofType: TestComponentA.self))
            
            // #3: Entity's component of type TestComponentA must be our `component`
            XCTAssertEqual  (entity.component(ofType: TestComponentA.self), component1)
            
            // #4: Entity's component of type of our component's type must be our component :)
            XCTAssertEqual  (entity.component(ofType: type(of: component1)), component1)
            
            // #5: The subscript must return the same component as component(ofType:)
            XCTAssertEqual  (entity[TestComponentA.self], entity.component(ofType: TestComponentA.self))
            
            // #6: component.entity must match our `entity`
            XCTAssertEqual  (entity, component1.entity)
            XCTAssertEqual  (entity, entity.components.first?.entity)
            
            // #7: A different type of component should not match our `component`
            XCTAssertNotEqual(entity.component(ofType: TestComponentB.self), component1)
        }
    }
    
    func testComponentRemove() {
        
        let component1  = TestComponentA()
        let component2  = TestComponentB()
        let entity      = TestEntity(components: [component1, component2, ComponentWithDependencies()])
        
        // #1: Entity must report the correct component count.
        
        let previousCount = entity.components.count
        
        entity.removeComponent(ofType: TestComponentA.self)

        XCTAssertEqual  (entity.components.count, previousCount - 1)
        
        // #2: component(ofType:) for a removed component must return `nil`
        XCTAssertNil    (entity[TestComponentA.self])
        
        // #3: Removed component's entity must be `nil`
        XCTAssertNil    (component1.entity)
        
        // #4: Other components must be untouched.
        XCTAssertEqual  (entity[TestComponentB.self], component2)
        XCTAssertNotNil (entity[ComponentWithDependencies.self])
    }
    
    func testComponentMove() {
       
        let entity1     = TestEntity()
        let entity2     = TestEntity()
        let component1  = TestComponentA()
        
        // Adding the same component to another entity should remove it from the previous entity.
        entity1.addComponent(component1)
        entity2.addComponent(component1)
        
        // #1: entity1 should no longer have a TestComponentA
        // This behavior is provided by TestEntity
        XCTAssertEqual      (entity1.components.count, 0)
        XCTAssertNil        (entity1[TestComponentA.self])
        
        // #2: entity2 should have component1
        XCTAssertEqual      (entity2.components.count, 1)
        XCTAssertNotNil     (entity2[TestComponentA.self])
        XCTAssertEqual      (entity2[TestComponentA.self], component1)
        
        // #3: component1.entity should be the new parent.
        XCTAssertNotEqual   (component1.entity, entity1)
        XCTAssertEqual      (component1.entity, entity2)
        
        // Add the component back to entity1
        entity1.addComponent(component1)
        
        // #4: entity2 should no longer have a TestComponentA
        // This behavior is provided by TestEntity
        XCTAssertEqual      (entity2.components.count, 0)
        XCTAssertNil        (entity2[TestComponentA.self])
        
        // #5: entity1 should have component1
        XCTAssertEqual      (entity1.components.count, 1)
        XCTAssertNotNil     (entity1[TestComponentA.self])
        XCTAssertEqual      (entity1[TestComponentA.self], component1)
        
        // #6: component1.entity should be entity1 again.
        XCTAssertNotEqual   (component1.entity, entity2)
        XCTAssertEqual      (component1.entity, entity1)
    }
    
    func testComponentDuplicates() {
        
        let entity     = TestEntity()
        let component1 = TestComponentA()
        let component2 = TestComponentA()
        
        // An entity may only have a single component of a specific class.
        entity.addComponent(component1)
        entity.addComponent(component2)
        
        // #1: `entity` should report only 1 component.
        XCTAssertEqual  (entity.components.count, 1)
        
        // #2: Querying `entity` for a TestComponentA should return the most recently-added instance: `component2`
        XCTAssertEqual  (entity[TestComponentA.self], component2)
        
        // #3: The replaced component1's `entity` should be `nil`
        XCTAssertNil    (component1.entity) // #This behavior is provided by TestEntity.
        
        // #4: component2.entity should be `entity`
        XCTAssertEqual  (component2.entity, entity)
    }
    
    func testCoComponents() {
        
        let component1  = TestComponentA()
        let component2  = TestComponentB()
        var entity:       TestEntity
        
        // #1: Components must be able to see each other.
        
        entity = TestEntity(components: [component1, component2])
        
        XCTAssertEqual  (component1.coComponent(ofType: TestComponentB.self), component2)
        XCTAssertEqual  (component2.coComponent(ofType: TestComponentA.self), component1)
        
        XCTAssertEqual  (component1.coComponent(ofType: type(of: component2).self), component2)
        XCTAssertEqual  (component2.coComponent(ofType: type(of: component1).self), component1)
        
        // #2: OKComponent.coComponent(ofType:) should not report `self`
        XCTAssertNil    (component1.coComponent(ofType: TestComponentA.self))
        XCTAssertNil    (component2.coComponent(ofType: TestComponentB.self))
        
        // #3: Components should not be able to see each other after removal.
        entity.removeComponent  (ofType: TestComponentB.self)
        XCTAssertNil            (component1.coComponent(ofType: TestComponentB.self))
        
        // #3B: Test again with a different order (includes test for moving components to a new entity.)
        entity = TestEntity  (components: [component1, component2])
        entity.removeComponent  (ofType: TestComponentA.self)
        XCTAssertNil            (component2.coComponent(ofType: TestComponentA.self))
    }
    
    func testComponentDependencies() {
        
        var entity:     TestEntity

        // #1: OKComponent.checkEntityForRequiredComponents() should return `true` if there are no `requiredComponents` even if the component has no entity.
        
        let standaloneComponent = TestComponentA()
        XCTAssertTrue(standaloneComponent.checkEntityForRequiredComponents())
        
        // #2: checkEntityForRequiredComponents() should return `true` if there are no `requiredComponents`.
        
        let entityComponent = TestComponentA()
        entity = TestEntity(components: [entityComponent])
    
        XCTAssertTrue(entityComponent.checkEntityForRequiredComponents())
        
        // #3: checkEntityForRequiredComponents() should return `false` if there are `requiredComponents` but no entity.
        
        let standaloneComponentWithDependencies = ComponentWithDependencies()
        XCTAssertFalse(standaloneComponentWithDependencies.checkEntityForRequiredComponents())
        
        // #4: checkEntityForRequiredComponents() should return `false` if the entity does not have the `requiredComponents`.
        
        let entityComponentWithDependencies = ComponentWithDependencies()
        entity = TestEntity(components: [entityComponentWithDependencies])
        
        XCTAssertFalse(entityComponentWithDependencies.checkEntityForRequiredComponents())
        
        // #5: checkEntityForRequiredComponents() should return `false` if only one dependency is available but not all.
        
        entity = TestEntity(components: [TestComponentA(), entityComponentWithDependencies])
        XCTAssertFalse(entityComponentWithDependencies.checkEntityForRequiredComponents())
        
        // #6: checkEntityForRequiredComponents() should return `true` if all dependencies are available.
        entity.addComponent(TestComponentB())
        XCTAssertTrue(entityComponentWithDependencies.checkEntityForRequiredComponents())
    }
    
    func testRelayComponent() {
        
        // NOTE: Do not use subscripts here, as that calls componentOrRelay(ofType:)
        
        var entity1, entity2:           TestEntity
        var componentA:                 TestComponentA
        var componentB:                 TestComponentB
        var relayComponentA:            RelayComponent<TestComponentA>
        var relayComponentB:            RelayComponent<TestComponentB>
        var componentWithDependencies:  ComponentWithDependencies
        
        // Connect components in different entities via RelayComponents.
        
        componentA      = TestComponentA()
        entity1         = TestEntity(components: [componentA])
        
        relayComponentA = RelayComponent(for: componentA)
        entity2         = TestEntity(components: [relayComponentA])
        
        // #0: Silence the warning about "Variable entity1 was written to, but never read" :)
        XCTAssertEqual  (componentA.entity, entity1)
        
        // #1: relayComponentA.target should be componentA
        XCTAssertEqual  (relayComponentA.target, componentA)
        
        // #2: The type of relayComponentA.target (unwrapped) should be TestComponentA
        XCTAssert       (type(of: relayComponentA.target!) == TestComponentA.self)
        
        // #3: entity2 should not have a TestComponentA
        XCTAssertNil    (entity2.component(ofType: TestComponentA.self))
        
        // #4: entity2 should have a RelayComponent<TestComponentA> and its target should be basicComponentA
        XCTAssertNotNil (entity2.component(ofType: RelayComponent<TestComponentA>.self))
        XCTAssertEqual  (entity2.component(ofType: RelayComponent<TestComponentA>.self)?.target, componentA)
        
        // #5: GKEntity.componentOrRelay(ofType:) should be able to find a TestComponentA in entity2 via RelayComponent
        XCTAssertEqual  (entity2.componentOrRelay(ofType: TestComponentA.self), componentA)
        
        // #6: GKComponent.coComponent(ofType:) should find co-components via RelayComponent
        
        componentB      = TestComponentB()
        entity2         = TestEntity(components: [relayComponentA, componentB])
        
        XCTAssertEqual  (componentB.coComponent(ofType: TestComponentA.self), componentA)
        
        // #7: GKComponent.coComponent(ofType:ignoreRelayComponents: true) should NOT find co-components via RelayComponent
        
        XCTAssertNotEqual  (componentB.coComponent(ofType: TestComponentA.self, ignoreRelayComponents: true), componentA)
        
        // #8: Entities should be able to have multiple RelayComponents with targets of different types.
        
        componentA      = TestComponentA()
        componentB      = TestComponentB()
        entity1         = TestEntity(components: [componentA, componentB])
        
        relayComponentA = RelayComponent(for: componentA)
        relayComponentB = RelayComponent(for: componentB)
        entity2         = TestEntity(components: [relayComponentA, relayComponentB])
        
        XCTAssertNotNil  (entity2.component(ofType: RelayComponent<TestComponentA>.self))
        XCTAssertNotNil  (entity2.component(ofType: RelayComponent<TestComponentB>.self))
        
        XCTAssertNotEqual(entity2.component(ofType: RelayComponent<TestComponentA>.self),
                          entity2.component(ofType: RelayComponent<TestComponentB>.self))
        
        // #9: OKComponent.checkEntityForRequiredComponents() should be able to find dependencies via RelayComponent
        
        componentA          = TestComponentA()
        entity1             = TestEntity(components: [componentA])
        
        componentWithDependencies = ComponentWithDependencies()
        relayComponentA     = RelayComponent(for: componentA)
        componentB          = TestComponentB()
        entity2             = TestEntity(components: [relayComponentA,
                                                      componentB,
                                                      componentWithDependencies])
        
        XCTAssertEqual      (componentWithDependencies.coComponent(ofType: TestComponentA.self), componentA)
        XCTAssertEqual      (componentWithDependencies.coComponent(ofType: TestComponentB.self), componentB)
        XCTAssertTrue       (componentWithDependencies.checkEntityForRequiredComponents()) // If this fails, search comments for "BUG: 201804029A"
        
        // #10: When an entity has both a direct component and a RelayComponent whose `target` is the same type, GKEntity.componentOrRelay(ofType:) should return the direct component first.
        // See comments for OKEntity.addComponent(_:)
        
        componentA          = TestComponentA()
        relayComponentA     = RelayComponent(for: componentA)
        entity1             = TestEntity(components: [componentA, relayComponentA])
        
        XCTAssertEqual      (entity1.componentOrRelay(ofType: TestComponentA.self), componentA)
        XCTAssertNotEqual   (entity1    .componentOrRelay(ofType: TestComponentA.self), relayComponentA)
        
        // #11: RelayComponent should remain linked to its target even if the target is removed from its entity.
        
        componentA          = TestComponentA()
        entity1             = TestEntity(components: [componentA])
        
        relayComponentA     = RelayComponent(for: componentA)
        componentB          = TestComponentB()
        entity2             = TestEntity(components: [relayComponentA, componentB])
        
        componentA.removeFromEntity()
        
        XCTAssertEqual      (relayComponentA.target, componentA)
        XCTAssertEqual      (componentB.coComponent(ofType: TestComponentA.self), componentA)
        
        // #11: RelayComponent(sceneComponentType:) should not cause infinite recursion.
        // This was a bug caused by `RelayComponent.target` calling `GKEntity.node` then `GKEntity.node` called `componentOrRelay(ofType:)` which called `RelayComponent.target` :)
        
        entity1             = TestEntity(components:  [RelayComponent(sceneComponentType: TestComponentA.self) ])

        XCTAssertNotNil     (entity1.component(ofType: RelayComponent<TestComponentA>.self))
        XCTAssertNil        (entity1.component(ofType: RelayComponent<TestComponentA>.self)?.target)
    }
    
    static var allTests = [
        ("Test entity basics",          testEntity),
        ("Test adding components",      testComponentAdd),
        ("Test removing components",    testComponentRemove),
        ("Test moving components",      testComponentMove),
        ("Test duplicate components",   testComponentDuplicates),
        ("Test co-components",          testCoComponents),
        ("Test component dependencies", testComponentDependencies),
        ("Test RelayComponent",         testRelayComponent)
    ]
}
