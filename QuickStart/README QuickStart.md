# OctopusKit QuickStart

**Template and tutorial for the [OctopusKit][repository] game engine.**

1. 🆕 In Xcode 12 or later, create a new **App** project, and choose **Interface: SwiftUI**.
	
	> ❗️ **Do NOT** create a "Game" project, because that template does not use SwiftUI.

	> OctopusKit targets iOS/iPadOS/tvOS 14 and macOS Big Sur, but you may be able to get it to run with Xcode 11, iOS 13 and Catalina.
	
2. 📦 Add OctopusKit as a **Swift Package Manager** Dependency.
    
    > *Xcode File menu » Swift Packages » Add Package Dependency...*
        
    > Enter the URL for the GitHub [repository][repository].
    
    > Download the "develop" branch for the latest version.
    
3. 📥 **Copy and include** the `QuickStart/Universal/` folder (which supports iOS, macOS and tvOS) in your project. 

    > In the Xcode Project Navigator, select the `OctopusKit/QuickStart/` folder, then in the File Inspector, click the arrow next to "Full Path", then drag the `Universal` subfolder into your project folder in the Xcode navigator. 

4. 🖼 Add the `OKQuickStartView` to the `ContentView.swift` file:

    ```
    var body: some View {
        OKQuickStartView()
    }
    ```
    	
5. 🚀 Build and run the project to verify that the template works.

6. 👓 Examine the `OKQuickStartView.swift` file and dig around in the QuickStart folder to see how everything works, then modify the template for your specific game. 

    > 📁 The main content of the template is in the `TitleState` and `PlayState` folders.

    > 🏷 Filenames are prefixed with a number denoting the order they come in during the application's life cycle. 
	
    > 🔍 Search for comments prefixed with `STEP #` for a quick overview of the flow of execution.

    > 💡 Try out different components from the `Sources/OctopusKit/Components` folder.

7. Check the documentation:
    
    * For a detailed explanation of the engine architecture, see [Architecture.md][architecture] in the `Documentation` folder of the OctopusKit package/repository.

    * **To see how to do common tasks, refer to [Usage Guide.md][guide]**

----

[OctopusKit][repository] © 2021 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[guide]: https://github.com/InvadingOctopus/octopuskit/blob/master/Documentation/Usage%20Guide.md
[architecture]: https://github.com/InvadingOctopus/octopuskit/blob/master/Documentation/Architecture.md
