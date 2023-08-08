//
//  OKLoader.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2014-10-31
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Implement

import Foundation

public typealias OctopusLoader = OKLoader

public final class OKLoader {
    
    /// Define a startupLoader() function or variable at the global scope.
    public class func loadResourcesWithCompletionHandler(completionHandler: () -> Void) {
        // CREDIT: Apple's Adventure Sample
//        
//        let queue = dispatch_get_main_queue()
//        
//        let backgroundQueue = dispatch_get_global_queue(CLong(DISPATCH_QUEUE_PRIORITY_HIGH), 0)
//        dispatch_async(backgroundQueue) {
//            
//            if let loader = OctopusKit.startupLoader {
//                loader()
//            } else {
//                OKLog.logForWarnings.debug("\(📜("No startupLoader specified in OctopusEnvironmnet"))")
//            }
//            
//            dispatch_async(queue, completionHandler)
//        }
    }
}
