//
//  OKViewControllerRepresentable-iOS.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-07
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import SpriteKit

public typealias OctopusViewControllerRepresentable = OKViewControllerRepresentable

#if canImport(AppKit)

import AppKit

/// Encapsulates an `OKViewController` to present SpriteKit/SceneKit/Metal content in a SwiftUI view hierarchy.
public struct OKViewControllerRepresentable <OKGameCoordinatorType, OKViewControllerType> : NSViewControllerRepresentable
    where OKGameCoordinatorType: OKGameCoordinator,
    OKViewControllerType: OKViewController
{
    
    // typealias Context = UIViewControllerRepresentableContext<Self> // Defined in UIViewControllerRepresentable
    
    @EnvironmentObject var gameCoordinator: OKGameCoordinatorType
    
    public init() {}
    
    /// NOTE: This method is a requirement of the `UIViewControllerRepresentable` protocol; it creates a SwiftUI view controller coordinator, **NOT** OctopusKit's `OKGameCoordinator`.
    public func makeCoordinator() -> ViewControllerCoordinator<OKViewControllerType> {
        OKViewControllerRepresentable.ViewControllerCoordinator(gameCoordinator: self.gameCoordinator)
    }
    
    public func makeNSViewController(context: Context) -> OKViewControllerType {
        return context.coordinator.viewController
    }
    
    public func updateNSViewController(_ uiViewController: OKViewControllerType,
                                       context: Context)
    {
        // ❓ Apparently on macOS, updateNSViewController gets called before Application.didBecomeActiveNotification, so the first scene gets presented with a frame of (width: 0, height: 0) ... so we will just let the OKGameCoordinator's notification handler evoke the initial state.
        
        // if !gameCoordinator.didEnterInitialState {
        //    gameCoordinator.enterInitialState()
        // }
    }
  
    public static func dismantleNSViewController(_ nsViewController: OKViewControllerType,
                                                 coordinator: ViewControllerCoordinator<OKViewControllerType>)
    {
        nsViewController.gameCoordinator?.currentScene?.didPauseBySystem()
    }
    
}

#elseif canImport(UIKit)

/// Encapsulates an `OKViewController` to present SpriteKit/SceneKit/Metal content in a SwiftUI view hierarchy.
public struct OKViewControllerRepresentable <OKGameCoordinatorType, OKViewControllerType> : UIViewControllerRepresentable
    where OKGameCoordinatorType: OKGameCoordinator,
          OKViewControllerType:  OKViewController
{
    
    // typealias Context = UIViewControllerRepresentableContext<Self> // Defined in UIViewControllerRepresentable
    
    @EnvironmentObject var gameCoordinator: OKGameCoordinatorType
    
    public init() {}
    
    /// NOTE: This method is a requirement of the `UIViewControllerRepresentable` protocol; it creates a SwiftUI view controller coordinator, **NOT** OctopusKit's `OKGameCoordinator`.
    public func makeCoordinator() -> ViewControllerCoordinator<OKViewControllerType> {
        OKViewControllerRepresentable.ViewControllerCoordinator(gameCoordinator: self.gameCoordinator)
    }
    
    public func makeUIViewController(context: Context) -> OKViewControllerType {
        return context.coordinator.viewController
    }
    
    public func updateUIViewController(_ uiViewController: OKViewControllerType,
                                       context: Context)
    {
        // Enter the first game state if the game coordinator has not already done so.
        if !gameCoordinator.didEnterInitialState {
            gameCoordinator.enterInitialState()
        }
    }
  
    public static func dismantleUIViewController(_ uiViewController: OKViewControllerType,
                                                 coordinator: ViewControllerCoordinator<OKViewControllerType>)
    {
        uiViewController.gameCoordinator?.currentScene?.didPauseBySystem()
    }
    
}

#endif

public extension OKViewControllerRepresentable { // CHECK: Should this be public?
    
    class ViewControllerCoordinator <OKViewControllerType> : NSObject
        where OKViewControllerType: OKViewController
    {
        var viewController: OKViewControllerType
        
        init(gameCoordinator: OKGameCoordinator) {
            self.viewController = try! OKViewControllerType(gameCoordinator: gameCoordinator)
            super.init()
        }
    }
}
