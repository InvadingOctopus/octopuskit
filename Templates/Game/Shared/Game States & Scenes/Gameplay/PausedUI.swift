//
//  PausedUI.swift
//  OctopusKit Project Template
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/07/02.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SwiftUI

struct PausedUI: View {
    var body: some View {
        VStack {

            Text("PAUSED")
                .font(.title)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

struct PausedUI_Previews: PreviewProvider {
    static var previews: some View {
        PausedUI()
    }
}
