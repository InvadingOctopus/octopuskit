---
permalink: documentation/guide.html
redirect_from: "/Documentation/Usage%2Guide.html"
---

# OctopusKit Usage Guide

### Tutorials and examples for common tasks

1. [Adding OctopusKit to your project](#adding-octopuskit-to-your-project)
2. [Xcode File Templates](#xcode-file-templates)
3. [Player Input](#player-input)
4. [Sharing Data](#sharing-data)
5. [Accessing Game State from SwiftUI Views](#accessing-game-state-from-swiftui-views)
6. [Advanced Stuff](#advanced-stuff)

##### Related Documentation

* [OctopusKit Architecture][architecture]
* [Tips & Troubleshooting][tips]

##### Notes

* This documentation assumes that the reader is using OctopusKit in a SwiftUI project, and has some prior experience with developing for Apple platforms in the Swift programming language.

* Currently, API documentation (i.e. for types/methods/properties) is only provided via extensive source-code comments, which can be viewed in Xcode's Quick Help.

    > This guide provides examples for common tasks and how to get started, but there is no standalone reference for the API, as I don't have the time and energy to write that alongside developing the engine. (´･_･`)  
    >
    > The best way to learn may be to examine the engine source code.
        
## Adding OctopusKit to your project

### 🍰 **To begin from a template**:

1. See the [**README QuickStart.md**][quickstart] file in the QuickStart folder of the OctopusKit package/repository.

### 🛠 **To import OctopusKit into a new or existing project:**

1. 📦 Add OctopusKit as a **Swift Package Manager** Dependency.
    
    > *Xcode File menu » Swift Packages » Add Package Dependency...*
        
    > Enter the URL for the GitHub [repository][repository]. Download the "develop" branch for the latest version.
    
2. Create an instance of `OKGameCoordinator`.

    ```
    let gameCoordinator = OKGameCoordinator(
        states: [OKGameState()], // A placeholder for now.
        initialStateClass: OKGameState.self)
    ```

    > The game coordinator is the top-level "controller" (in the Model-View-Controller sense) that manages the global state of your game.
    
    > If your game needs to share complex logic or data across multiple scenes, you may create a subclass of `OKGameCoordinator`.

3. Presenting OctopusKit content in your view hierarchy requires different steps depending on whether you use SwiftUI or AppKit/UIKit:

    * **SwiftUI (iOS/iPadOS, macOS, tvOS):** Add a `OctopusKitContainerView` and pass the game coordinator as an `environmentObject` to it:
    
        ```
        import OctopusKit
    
        struct ContentView: View {
            var body: some View {
                OctopusKitContainerView()
                    .environmentObject(gameCoordinator)
            }
        }
        ```
        
        > The `OctopusKitContainerView` combines a SpriteKit `SKView` with a SwiftUI overlay.
        
        > ❗️ If you created a subclass of `OKGameCoordinator`, then you must provide a generic type parameter: `OctopusKitContainerView<MyGameCoordinator>()`
    
        > 💡 It's best to pass the game coordinator `environmentObject` to the top level content view created in the `SceneDelegate.swift` file, which will make it available to your entire view hierarchy.
    
    * **AppKit (macOS) or UIKit (iOS/iPadOS, tvOS):** Your storyboard should have an `SKView` whose controller class is set to `OKViewController` or its subclass.
        
        * If you use `OKViewController` directly, then you must initialize OctopusKit early in your application launch cycle: 

            ```
            func application(_ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
            {
                OctopusKit(gameCoordinator: coordinator)
                return true
            }
            ```
        
        * If you create your own subclass, it must implement these initializers:
    
            ```
            required init?(coder aDecoder: NSCoder) {
                OctopusKit(gameCoordinator: gameCoordinator)
                super.init(coder: aDecoder)
            }
            
            required init(gameCoordinator: OKGameCoordinator? = nil) {
                super.init(gameCoordinator: gameCoordinator)
            }
            ``` 
            
            > ❗️ If you are starting with Xcode's SpriteKit Game template, you must **delete** the `GameViewController.viewDidLoad()` override, as that will prevent the `OKViewController` from presenting your game coordinator's scenes.
        
4. Code the states, scenes and UI for your game. The game coordinator must have at least one state that is associated with a scene, so your project must have custom classes which inherit from `OKGameState` and `OKScene`. 

    > For an explanation of these classes, see the [Architecture][architecture] documentation.

    > If your scenes requires custom per-frame logic, you may override the `OKScene.shouldUpdateSystems(deltaTime:)` method.
    
    > If your game state classes also perform per-frame updates, then you may also override the `OKScene.shouldUpdateGameCoordinator(deltaTime:)` method.

5. Each of your game states can have a SwiftUI view associated with them to provide user interface elements like text and HUDs. The SwiftUI view is overlaid on top of the SpriteKit gameplay view. To let SwiftUI interact with your game's state, make sure to pass an `.environmentObject(gameCoordinator)` to your SwiftUI view hierarchy.

## Xcode File Templates

To save yourself from writing a lot of the same code for every new state, scene, component or method override, copy the contents of the `Templates/Xcode` subfolder of the OK package to your `~/Library/Developer/Xcode/Templates/OctopusKit`.

This offers a section of templates for OctopusKit when you create a ⌘N New File in Xcode, including a very convenient template for creating a new game state class + its scene + UI in a single file, with just one click.

💡 You may create a symbolic link (with the `ln` Terminal command) to keep the templates folders in sync whenever they're updated.

## Player Input

In your **scene**'s `override func prepareContents()`

```swift
self.entity?.addComponents([
    
    // Collect asynchronous events in a buffer for processing them in sync with the frame-update cycle:
    sharedMouseOrTouchEventComponent,   // iOS & macOS
    
    // Translate mouse or touch input to an OS-agnostic format:
    sharedPointerEventComponent,        // iOS & macOS
    
    sharedKeyboardEventComponent        // macOS
    ])
    
yourPlayerEntity.addComponents([

    // Use the scene's shared event stream:
    RelayComponent(for: sharedPointerEventComponent),
    
    // Filter the stream for events in the entity's sprite's bounds:
    NodePointerStateComponent(),
    
    PointerControlledDraggingComponent()
    ])
```

💡 See other components in `OctopusKit/Components/Input`

## Sharing Data

You can share data between states, scenes and entities in many ways.

You may simply add custom properties to `OctopusKit.shared.gameCoordinator`

Or use data components like a `DictionaryComponent`

```swift
OctopusKit.shared.gameCoordinator.entity.addComponent(
    DictionaryComponent <String, Any> ([
        "playerNode":  playerEntity.node as Any,
        "playerStats": playerEntity[PlayerStatsComponent.self] as Any ]) )
```

To access that data:

```swift
if  let globalData = OctopusKit.shared.gameCoordinator.entity[DictionaryComponent<String, Any>.self] {
    
    let node  = globalData["playerNode"]  as? SKNode
    let stats = globalData["playerStats"] as? PlayerStatsComponent
    //  ...
}
```

❕ Note that once an object is added to the dictionary, it holds a reference to the object.

💡 Instead of typo-prone `String` keys, use `TypeSafeIdentifiers`

## Accessing Game State from SwiftUI Views

```swift
class DataComponent: OKComponent, ObservableObject {
    
    @Published public var secondsElapsed: TimeInterval = 0
    
    override func update(deltaTime seconds: TimeInterval) {
        secondsElapsed += seconds
    }
}

struct DataComponentLabel: View {

    @ObservedObject var component: DataComponent
    
    var body: some View {
        Text("Seconds elapsed: \(component.secondsElapsed)")
    }
}
```

In a container view, pass the component as an argument to the label view:

```swift
var globalDataComponent: DataComponent? {
    gameCoordinator.entity[DataComponent.self]
}

var body: some View {
    if  globalDataComponent != nil {
        DataComponentLabel(component: globalDataComponent!)
    }
}
```

💡 You may write a custom property wrapper like say `@Component` to simplify accessing components from the current scene etc.

## Advanced Stuff

### Using the Xcode Scene Editor as the primary design tool 

> TODO: Incomplete section

Set the custom class of the scene as `OKScene` or a subclass of it. Load the scene by calling `OKGameCoordinator.loadAndPresentScene(fileNamed:withTransition:)`, e.g. during the `didEnter.from(_:)` event of an `OKGameState`. 

----

[OctopusKit][repository] © 2019 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[quickstart]: https://github.com/InvadingOctopus/octopuskit/blob/master/QuickStart/README%20QuickStart.md
[architecture]: https://invadingoctopus.io/octopuskit/documentation/architecture.html
[tutorials]: https://invadingoctopus.io/octopuskit/documentation/tutorials.html
[tips]: https://invadingoctopus.io/octopuskit/documentation/tips.html
[conventions-&-design]: https://invadingoctopus.io/octopuskit/documentation/conventions.html
[todo]: https://invadingoctopus.io/octopuskit/documentation/todo.html