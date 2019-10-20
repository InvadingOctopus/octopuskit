//
//  OctopusKitQuickStartView.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/16.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 1: A SwiftUI view which displays the OctopusKit QuickStart "game".
//
//  Add this view in the `body` property of your SwiftUI project's `ContentView.swift` file.

import SwiftUI
import OctopusKit
import Combine

struct OctopusKitQuickStartView: View {
    
    var body: some View {
        OctopusKitContainerView<MyGameCoordinator, MyGameViewController>()
            .environmentObject(MyGameCoordinator())
            .edgesIgnoringSafeArea(.all)
            .statusBar(hidden: true)
    }
    
}

/// A custom style for buttons to reduce redundant view modifier code.
struct QuickStartButtonLabel: View {
    
    var text: String
    var color: Color
    
    var body: some View {
        Text(text)
        .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .foregroundColor(color)
                .opacity(0.85)
                .shadow(color: .black, radius: 10, x: 0, y: -10))
            .padding()
    }
}

struct OctopusKitQuickStartView_Previews: PreviewProvider {
    static var previews: some View {
        Text("See the TitleUI preview")
    }
}
