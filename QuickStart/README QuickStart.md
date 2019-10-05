#  OctopusKit QuickStart (iOS)

#### Xcode game project replacement files and rudimentary tutorial for the [OctopusKit][repository] game engine.

## How To Use

1. In Xcode 11 or newer, create a new **Game** project.

2. Add OctopusKit as a Swift Package Dependency.
    
    > Xcode File menu » Swift Packages » Add Package Dependency...
    
3. Copy all the contents of the relevant QuickStart subfolder (iOS or macOS) from the OctopusKit package folder to your project's source folder. 
    
    > 📥 **Replace** the default pregenerated files: **AppDelegate.swift, GameViewController.swift** and **GameScene.swift**
    
    > 🗑 Delete GameScene.sks and Actions.sks

4. Include the copied files to your Xcode project. 

    > Remove any leftover duplicates of the pregenerated project files (like AppDelegate.swift) if needed.

ℹ️ See comments prefixed with "Step #" for a quick overview of the flow of execution.

💡 To customize this template for a simple game of your own, modify the `TitleScene.swift` and `PlayScene.swift` classes and try out different components from `/OctopusKit (1.1)/Sources/OctopusKit/Components`.

**For further details, see the [OctopusKit Usage Guide.][usage-guide]**

----

[OctopusKit][repository] © 2019 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[usage-guide]: https://invadingoctopus.io/octopuskit/documentation/usage.html
