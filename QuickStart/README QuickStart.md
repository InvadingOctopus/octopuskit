#  OctopusKit QuickStart (iOS)

#### Template and tutorial for the [OctopusKit][repository] game engine.

## How To Use

1. 🆕 In Xcode 11 or later, create a new **Single View App** project, and choose **User Interface: SwiftUI.**

    > ❗️ **Do NOT** create a "Game" project, because that template does not use SwiftUI.

2. 📦 Add OctopusKit as a **Swift Package** Dependency.
    
    > Xcode File menu » Swift Packages » Add Package Dependency...

3. 📥 **Copy** all the contents of the relevant QuickStart subfolder (iOS or macOS) from the OctopusKit package to your project's source folder. 

    > In the Xcode Project Navigator, menu-click on the OctopusKit/QuickStart folder and select "Show in Finder"
    
4. 🗂 **Include** the copied files in your Xcode project. 

	> By dragging the copies from your project's folder into the Project Navigator sidebar.

5. 🖼 Add the `OctopusKitQuickStartView` to the `ContentView.swift` file:

    ```
    var body: some View {
        OctopusKitQuickStartView()
    }
    ```
	
6. 🚀 Build and run the project!

7. 👓 Examine the OctopusKitQuickStartView.swift file and dig around in the QuickStart folder to see how everything works, then modify the template for your specific game.

    > 🏷 Filenames are prefixed with a number denoting the order they come in during the application's life cycle. 
	
    > 🔍 Search for comments prefixed with "STEP #" for a quick overview of the flow of execution.

    > 💡 To customize this template for a simple game of your own, modify the `TitleScene.swift` and `PlayScene.swift` classes and try out different components from the `Sources/OctopusKit/Components` folder in the OK package.

**For further details, see the [OctopusKit Usage Guide.][usage-guide]**

----

[OctopusKit][repository] © 2019 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[usage-guide]: https://invadingoctopus.io/octopuskit/documentation/usage.html
