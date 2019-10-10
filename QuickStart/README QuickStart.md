#  OctopusKit QuickStart (iOS)

#### Xcode game project replacement files and rudimentary tutorial for the [OctopusKit][repository] game engine.

## How To Use

1. 🆕 In Xcode 11 or later, create a **new SpriteKit Game** project.

2. 📦 Add OctopusKit as a **Swift Package** Dependency.
    
    > Xcode File menu » Swift Packages » Add Package Dependency...

3. 🗑 **Delete** the following default files created by the Xcode template: 

	Actions.sks  
	AppDelegate.swift  
	GameScene.sks  
	GameScene.swift  
	GameViewController.swift  

4. 📥 **Copy** all the contents of the relevant QuickStart subfolder (iOS or macOS) from the OctopusKit package folder to your project's source folder. 

5. 🗂 **Include** the copied files in your Xcode project. 

	> By dragging the copies from your project's folder into the Project Navigator.

ℹ️ See comments prefixed with "Step #" for a quick overview of the flow of execution.

💡 To customize this template for a simple game of your own, modify the `TitleScene.swift` and `PlayScene.swift` classes and try out different components from `/OctopusKit (1.1)/Sources/OctopusKit/Components`.

**For further details, see the [OctopusKit Usage Guide.][usage-guide]**

----

[OctopusKit][repository] © 2019 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[usage-guide]: https://invadingoctopus.io/octopuskit/documentation/usage.html
