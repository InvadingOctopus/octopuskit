# OctopusKit Game Project Template

**Template and tutorial for the [OctopusKit][repository] game engine.**

1. 🆕 In Xcode 12 or later, create a new **App** project, and choose **Interface: SwiftUI**.
	
	> ❗️ **Do NOT** create a "Game" project, because that template does not use SwiftUI.

	> OctopusKit targets iOS/iPadOS/tvOS 14 and macOS Big Sur, but you may be able to get it to run with Xcode 11, iOS 13 and Catalina.
	
2. 📦 Add OctopusKit as a **Swift Package Manager** Dependency.
    
    > *Xcode File menu » Swift Packages » Add Package Dependency...*
        
    > Enter the URL for the GitHub [repository][repository].
    
    > Download the "develop" branch for the latest version.
    
3. 📥 **Copy and include** all the *subfolders* from the `Templates/Game/Shared` folder in your project. 

    > In the Xcode Project Navigator, select the `OctopusKit/Templates/Game` folder, then in the File Inspector, click the arrow next to "Full Path", then drag all the *subfolders* (`Components, Core, Entities` etc.) from the `Shared` subfolder into your project's `Shared` folder in the Xcode navigator. 

4. 🖼 Add the `GameContentView` to the `ContentView.swift` file:

    ```
    var body: some View {
        GameContentView()
    }
    ```
    	
5. 🚀 Build and run the project to verify that the template works.

6. 👓 Examine the various files to see how everything works, then modify the template for your specific game. 

7. Check the documentation:
    
    * For a detailed explanation of the engine architecture, see [Architecture.md][architecture] in the `Documentation` folder of the OctopusKit package/repository.

    * **To see how to do common tasks, refer to [Usage Guide.md][guide]**

----

[OctopusKit][repository] © 2020 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[guide]: https://github.com/InvadingOctopus/octopuskit/blob/master/Documentation/Usage%20Guide.md
[architecture]: https://github.com/InvadingOctopus/octopuskit/blob/master/Documentation/Architecture.md
