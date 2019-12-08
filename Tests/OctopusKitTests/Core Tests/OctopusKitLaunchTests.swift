//
//  OctopusKitLaunchTests.swift
//  OctopusKitTests
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/30.
//

import XCTest
@testable import OctopusKit

final class OctopusKitLaunchTests: XCTestCase {
    
    func testLaunch() {
        
        // 1: `verifyConfiguration` should fail if there's nothing configured.
        
        XCTAssertThrowsError(try OctopusKit.verifyConfiguration())
        
        // 2: `OctopusViewController` should not initialize without an `OctopusGameCoordinator`.
            
        XCTAssertThrowsError(try OctopusViewController())
        
        // 3: OctopusKit should be initialized more than once.
        
        let gameCoordinator = OctopusGameCoordinator(states: [OctopusGameState()])
        
        XCTAssertNoThrow(try OctopusKit(gameCoordinator: gameCoordinator))
        
        XCTAssertThrowsError(try OctopusKit(gameCoordinator: gameCoordinator))
            
        // 4: `OctopusViewController` should allow multiple instances.
        
        var viewController1, viewController2: OctopusViewController?
        
        XCTAssertNoThrow(viewController1 = try OctopusViewController())
        XCTAssertNoThrow(viewController2 = try OctopusViewController())
        
        XCTAssertEqual(viewController1!.gameCoordinator, viewController2!.gameCoordinator)
        
        // TODO: Test `OctopusViewControllerRepresentable`
        // let viewControllerRepresentable = OctopusViewControllerRepresentable()
        // XCTAssertThrowsError(viewControllerRepresentable.makeCoordinator())

    }
    
    static var allTests = [
        ("Test Launch Process", testLaunch)
    ]
}
