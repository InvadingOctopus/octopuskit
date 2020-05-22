//
//  OKLogViewerButton.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020-05-21
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//


import SwiftUI

/// A viewer for `OctopusKit.unifiedLog`.
public struct OKLogViewerButton: View {
    
    @State var showingLogViewer: Bool = false
    
    public init() {}
    
    public var body: some View {
        Button(action: { self.showingLogViewer.toggle() } ) {
            Text("📜")
                .accessibility(label: Text("View OctopusKit Log"))
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                        .blendMode(.difference)
                )
        }
        .sheet(isPresented: $showingLogViewer) {
            OKLogList(OctopusKit.unifiedLog)
        }
    }
}

struct LogViewerButton_Previews: PreviewProvider {
    static var previews: some View {
       OKLogViewerButton()
    }
}
