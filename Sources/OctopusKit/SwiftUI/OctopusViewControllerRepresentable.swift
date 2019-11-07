//
//  OctopusViewControllerRepresentable-iOS.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019-10-07
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI
import SpriteKit

#if canImport(UIKit)

/// Encapsulates an OctopusViewController for presenting SpriteKit/SceneKit/Metal content in a SwiftUI application.
public struct OctopusViewControllerRepresentable <OctopusGameCoordinatorType, OctopusViewControllerType> : UIViewControllerRepresentable
    where OctopusGameCoordinatorType: OctopusGameCoordinator,
    OctopusViewControllerType: OctopusViewController
{
    
    // typealias Context = UIViewControllerRepresentableContext<Self> // Defined in UIViewControllerRepresentable
    
    @EnvironmentObject var gameCoordinator: OctopusGameCoordinatorType
    
    public init() {}
    
    /// NOTE: This method is a requirement of the `UIViewControllerRepresentable` protocol; it creates a SwiftUI view controller coordinator, **NOT** OctopusKit's `OctopusGameCoordinator`.
    public func makeCoordinator() -> ViewControllerCoordinator<OctopusViewControllerType> {
        OctopusViewControllerRepresentable.ViewControllerCoordinator(gameCoordinator: self.gameCoordinator)
    }
    
    public func makeUIViewController(context: Context) -> OctopusViewControllerType {
        return context.coordinator.viewController
    }
    
    public func updateUIViewController(_ uiViewController: OctopusViewControllerType,
                                       context: Context)
    {
        // Enter the first game state if the game coordinator has not already done so.
        if !gameCoordinator.didEnterInitialState {
            gameCoordinator.enterInitialState()
        }
    }
  
    public static func dismantleUIViewController(_ uiViewController: OctopusViewControllerType,
                                                 coordinator: ViewControllerCoordinator<OctopusViewControllerType>)
    {
        uiViewController.gameCoordinator?.currentScene?.didPauseBySystem()
    }
    
}

#elseif canImport(AppKit)

import AppKit

/// Encapsulates an OctopusViewController for presenting SpriteKit/SceneKit/Metal content in a SwiftUI application.
public struct OctopusViewControllerRepresentable <OctopusGameCoordinatorType, OctopusViewControllerType> : NSViewControllerRepresentable
    where OctopusGameCoordinatorType: OctopusGameCoordinator,
    OctopusViewControllerType: OctopusViewController
{
    
    // typealias Context = UIViewControllerRepresentableContext<Self> // Defined in UIViewControllerRepresentable
    
    @EnvironmentObject var gameCoordinator: OctopusGameCoordinatorType
    
    public init() {}
    
    /// NOTE: This method is a requirement of the `UIViewControllerRepresentable` protocol; it creates a SwiftUI view controller coordinator, **NOT** OctopusKit's `OctopusGameCoordinator`.
    public func makeCoordinator() -> ViewControllerCoordinator<OctopusViewControllerType> {
        OctopusViewControllerRepresentable.ViewControllerCoordinator(gameCoordinator: self.gameCoordinator)
    }
    
    public func makeNSViewController(context: Context) -> OctopusViewControllerType {
        return context.coordinator.viewController
    }
    
    public func updateNSViewController(_ uiViewController: OctopusViewControllerType,
                                       context: Context)
    {
        // ❓ Apparently on macOS, updateNSViewController gets called before Application.didBecomeActiveNotification, so the first scene gets presented with a frame of (width: 0, height: 0) ... so we will just let the OctopusGameCoordinator's notification handler evoke the initial state.
        
        // if !gameCoordinator.didEnterInitialState {
        //    gameCoordinator.enterInitialState()
        // }
    }
  
    public static func dismantleNSViewController(_ nsViewController: OctopusViewControllerType,
                                                 coordinator: ViewControllerCoordinator<OctopusViewControllerType>)
    {
        nsViewController.gameCoordinator?.currentScene?.didPauseBySystem()
    }
    
}

#endif

public extension OctopusViewControllerRepresentable { // CHECK: Should this be public?
    
    class ViewControllerCoordinator <OctopusViewControllerType> : NSObject
        where OctopusViewControllerType: OctopusViewController
    {
        var viewController: OctopusViewControllerType
        
        init(gameCoordinator: OctopusGameCoordinator) {
            self.viewController = try! OctopusViewControllerType(gameCoordinator: gameCoordinator)
            super.init()
        }
    }
}
