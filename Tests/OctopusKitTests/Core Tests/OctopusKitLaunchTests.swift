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
        
        // 2: `OKViewController` should not initialize without an `OKGameCoordinator`.
            
        XCTAssertThrowsError(try OKViewController())
        
        // 3: OctopusKit should be initialized more than once.
        
        let gameCoordinator = OKGameCoordinator(states: [OKGameState()])
        
        XCTAssertNoThrow(try OctopusKit(gameCoordinator: gameCoordinator))
        
        XCTAssertThrowsError(try OctopusKit(gameCoordinator: gameCoordinator))
            
        // 4: `OKViewController` should allow multiple instances.
        
        var viewController1, viewController2: OKViewController?
        
        XCTAssertNoThrow(viewController1 = try OKViewController())
        XCTAssertNoThrow(viewController2 = try OKViewController())
        
        XCTAssertEqual(viewController1!.gameCoordinator, viewController2!.gameCoordinator)
        
        // TODO: Test `OKViewControllerRepresentable`
        // let viewControllerRepresentable = OKViewControllerRepresentable()
        // XCTAssertThrowsError(viewControllerRepresentable.makeCoordinator())

    }
    
    static var allTests = [
        ("Test Launch Process", testLaunch)
    ]
}
