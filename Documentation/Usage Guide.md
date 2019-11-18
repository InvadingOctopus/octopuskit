---
permalink: documentation/guide.html
redirect_from: "/Documentation/Usage%2Guide.html"
---

# OctopusKit Usage Guide

### How-To and examples for common tasks.

> *This documentation assumes that the reader is using OctopusKit in a SwiftUI project, and has some prior experience with developing for Apple platforms in the Swift programming language.*

1. [Start](#start)
2. [Player Input](#player-input)
3. [Accessing Game State From SwiftUI Views](#accessing-game-state-from-swiftui-views)
3. [Global Data](#global-data)

##### Other Documents

* [OctopusKit Architecture][architecture]
* [Tips & Troubleshooting][tips]
* [Coding Conventions & Design Decisions][conventions-&-design]
* [TODO & Roadmap][todo]

##### Notes

* Currently, API documentation (i.e. for types/methods/properties) is only provided via extensive source-code comments, which can be viewed in Xcode's Quick Help.

    > This guide provides examples for common tasks and how to get started, but there is no standalone reference for the API, as I don't have the time and energy to write that alongside developing the engine. (´･_･`)  
    >
    > The best way to learn may be to examine the engine source code.
        
## Start

### 🍰 **To begin from a template**:

1. See the [**README QuickStart.md**][quickstart] file in the QuickStart folder of the OctopusKit package/repository.

### 🛠 **To import OctopusKit into a new or existing project:**

1. 📦 Add OctopusKit as a **Swift Package Manager** Dependency.
    
    > *Xcode File menu » Swift Packages » Add Package Dependency...*
        
    > Enter the URL for the GitHub [repository][repository]. Download the "develop" branch for the latest version.
    
2. Create an instance of `OctopusGameCoordinator`.

    ```
    let gameCoordinator = OctopusGameCoordinator(
        states: [OctopusGameState()], // A placeholder for now.
        initialStateClass: OctopusGameState.self)
    ```

    > The game coordinator is the top-level "controller" (in the Model-View-Controller sense) that manages the global state of your game.
    
    > If your game needs to share complex logic or data across multiple scenes, you may create a subclass of `OctopusGameCoordinator`.

3. Displaying OctopusKit content in your view hierarchy requires different steps depending on whether you use SwiftUI or AppKit/UIKit:

    * **SwiftUI:** Add a `OctopusKitContainerView` and pass the game coordinator as an `environmentObject` to it:
    
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
        
        > ❗️ If you created a subclass of `OctopusGameCoordinator`, then you must provide a generic type parameter: `OctopusKitContainerView<MyGameCoordinator>()`
    
        > 💡 It's best to pass the game coordinator `environmentObject` to the top level content view created in the `SceneDelegate.swift` file, which will make it available to your entire view hierarchy.
    
    * **AppKit or UIKit:** Your storyboard should have an `SKView` whose controller class is set to `OctopusViewController` or its subclass.
        
        * If you use `OctopusViewController` directly, then you must initialize OctopusKit early in your application launch cycle: 

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
            
            required init(gameCoordinator: OctopusGameCoordinator? = nil) {
                super.init(gameCoordinator: gameCoordinator)
            }
            ``` 
            
            > ❗️ If you are starting with Xcode's SpriteKit Game template, you must **delete** the `GameViewController.viewDidLoad()` override, as that will prevent the `OctopusViewController` from presenting your game coordinator's scenes.
        
4. Code the states, scenes and UI for your game. The game coordinator must have at least one state that is associated with a scene, so your project must have custom classes which inherit from `OctopusGameState` and `OctopusScene`. 

    > For an explanation of these classes, see [Control Flow & Object Hierarchy.](#control-flow--object-hierarchy)

    > If your scenes requires custom per-frame logic, you may override the `OctopusScene.shouldUpdateSystems(deltaTime:)` method.
    
    > If your game state classes also perform per-frame updates, then you may also override the `OctopusScene.shouldUpdateGameCoordinator(deltaTime:)` method.

5. Each of your game states can have a SwiftUI view associated with them to provide user interface elements like text and HUDs. The SwiftUI view is overlaid on top of the SpriteKit gameplay view. To let SwiftUI interact with your game's state, make sure to pass an `.environmentObject(gameCoordinator)` to your SwiftUI view hierarchy.

### 💡 Xcode File Templates

To save yourself from writing a lot of the same code for every new state, scene, component or method override, copy the contents of the `Templates/Xcode` subfolder of the OK package to your `~/Library/Developer/Xcode/Templates/OctopusKit`.

This offers a section of templates for OctopusKit when you create a ⌘N New File in Xcode, including a very convenient template for creating a new game state class + its scene + UI in a single file, with just one click.

> You may create a symbolic link (with the `ln` Terminal command) to keep the templates folders in sync whenever they're updated.

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

## Accessing Game State from SwiftUI Views

```swift
class GlobalDataComponent: OctopusComponent, ObservableObject {
    
    @Published public var secondsElapsed: TimeInterval = 0
    
    override func update(deltaTime seconds: TimeInterval) {
        secondsElapsed += seconds
    }
}

struct GlobalDataComponentLabel: View {

    @ObservedObject var component: GlobalDataComponent
    
    var body: some View {
        Text("Seconds since activation: \(component.secondsElapsed)")
    }
}
```

In a container view, pass the component as an argument to the label view:

```swift
var globalDataComponent: GlobalDataComponent? {
    gameCoordinator.entity[GlobalDataComponent.self]
}

var body: some View {
    if  globalDataComponent != nil {
        GlobalDataComponentLabel(component: globalDataComponent!)
    }
}
```

💡 You may write a custom property wrapper like say `@Component` to simplify accessing components.

## Global Data

> TODO: Sharing "global" data via `RelayComponent`s

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

[mvc]: https://en.wikipedia.org/wiki/Model–view–controller
[reducing-dynamic-dispatch]: https://developer.apple.com/swift/blog/?id=27
[frame-cycle]: https://developer.apple.com/documentation/spritekit/skscene/responding_to_frame-cycle_events
[sf-symbols]: https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/