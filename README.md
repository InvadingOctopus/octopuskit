# OctopusKit ![OctopusKit Logo](https://github.com/InvadingOctopus/octopuskit/blob/develop/Assets/SinclairZXSpectrumOK-Slim.png?raw=true)

A 2D game engine in 100% Swift for iOS, macOS and tvOS.

OctopusKit wraps and extends Apple's frameworks:  
• **GameplayKit**'s flexible Entity-Component-System architecture lets you dynamically compose game behavior.  
• **SpriteKit** gives you full access to textures, physics and GPU shaders.  
• **SwiftUI**'s declarative syntax lets you quickly design fluid, scalable HUDs.  
• **Metal** under the hood ensures the best native performance.  
• OS-agnostic components let you compile natively for iOS and macOS and handle mouse + touch input with the same code, without needing Catalyst etc.

![QuickStart Demo](https://github.com/InvadingOctopus/octopuskit/blob/develop/QuickStart/Images/OctopusKitQuickStartDemo.gif?raw=true)

🚀 *Eager to dive in? Add OctopusKit as a Swift Package Manager dependency to a SwiftUI project, and use the [**QuickStart** template][quickstart] (which also serves as a little demo.)*

1. [Examples](#examples)
2. [Overview](#overview)
3. [Design Goals](#design-goals)
4. [Getting Started](#getting-started)
5. [Etcetera](#etcetera)

> OctopusKit is a constant **work in progress** and my first ever open-source project. I'm still learning as I go, so it may change rapidly without maintaining backwards compatibility or updating the documentation.

> This project is a result of trying to make my own games as a hobby. I fell in love with Swift but couldn't find any engines that supported it or had the kind of architecture that I wanted to work with, so I started making my own.

> Any advice on how to improve the API, coding style, git workflow, or open-source best-practices, would be appreciated! *– ShinryakuTako*
 
## Examples

🎨 *Using with SwiftUI*

```swift
import SwiftUI
import OctopusKit
                                                
struct ContentView: View {

    // The coordinator object manages your game's scenes and global state, 
    // and can be observed and controlled from SwiftUI.
    
    var gameCoordinator = OKGameCoordinator(states: [
        MainMenu(),
        Lobby(), 
        Gameplay() ])
                                                
    var body: some View {
        OKContainerView()
            .environmentObject(gameCoordinator)
            .edgesIgnoringSafeArea(.all)
            .statusBar(hidden: true)
    }
}
```

👾 *Creating an animated sprite*

```swift
var character = OKEntity(components: [
    
    // Start with a blank texture.
    SpriteKitComponent(node: SKSpriteNode(color: .clear, size: CGSize(widthAndHeight: 42))),
    
    // Load texture resources.
    TextureDictionaryComponent(atlasName: "PlayerCharacter"),
    
    // Animate the sprite with textures whose names begin with the specified prefix.
    TextureAnimationComponent(initialAnimationTexturePrefix: "Idle") ])
```

🕹 *Adding player control*

```swift
// Add a component to the scene that will be updated with input events.
// Other components that handle player input will query this component.

// This lets us handle asynchronous events in sync with the frame-update cycle.
// A shared event stream is more efficient than forwarding events to every entity.

// PointerEventComponent is an OS-agnostic component for touch or mouse input.

let sharedPointerEventComponent = PointerEventComponent()
scene.entity?.addComponent(sharedPointerEventComponent)

character.addComponents([
    
    // A relay component adds a reference to a component from another entity,
    // and also fulfills the dependencies of other components in this entity.
    RelayComponent(for: sharedPointerEventComponent),
    
    // This component checks the entity's PointerEventComponent (provided here by a relay)
    // and syncs the entity's position to the touch or mouse location in every frame.
    PointerControlledPositioningComponent() ])
```

🕹 *Dynamically removing player control or changing to a different input method*

```swift
character.removeComponent(ofType: PointerControlledPositioningComponent.self)
    
character.addComponents([

    // Add a physics body to the sprite.
    PhysicsComponent(),
    
    RelayComponent(for: sharedKeyboardEventComponent),
    
    // Apply a force to the sprite's body based on keyboard input in every frame.
    KeyboardControlledForceComponent() ])
```

🧩 *A custom game-specific component*

```swift
class AngryEnemyComponent: OKComponent {
    
    override func didAddToEntity(withNode node: SKNode) {
        node.colorTint = .angryMonster
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let behaviorComponent = coComponent(EnemyBehaviorComponent.self) else { return }
        behaviorComponent.regenerateHP()
        behaviorComponent.chasePlayerWithExtraFervor()
    }
    
    override func willRemoveFromEntity(withNode node: SKNode) {
        node.colorTint = .mildlyInconveniencedMonster
    }
}
```

🛠 *Using a custom closure to change the animation based on player movement*

```swift
// Add a component that executes the supplied closure every frame.
character.addComponent(RepeatingClosureComponent { component in
    
    // Check if the entity of this component has the required dependencies at runtime.
    // This approach allows dynamic behavior modification instead of halting the game.
    
    if  let physicsBody = component.coComponent(PhysicsComponent.self)?.physicsBody,
        let animationComponent = component.coComponent(TextureAnimationComponent.self)
    {
        // Change the animation depending on whether the body is stationary or mobile.
        animationComponent.textureDictionaryPrefix = physicsBody.isResting ? "Idle" : "Moving"
    }
})

// This behavior could be better encapsulated in a custom component,
// with many different game-specific animations depending on many conditions.
```

🎎 *Loading a scene built in the Xcode Scene Editor and creating multiple entities from sprites identified by a shared name*

```swift
// Load a ".sks" file as a child node.

if  let editorScene = SKReferenceNode(fileNamed: "EditorScene.sks") {
    scene.addChild(editorScene)
}

// Search the entire tree for all nodes named "Turret",
// and give them properties of "tower defense" turrets,
// and make them independently draggable by the player.

for turretNode in scene["//Turret"] {

    // Create a new entity for each node found.
    scene.addEntity(OKEntity(components: [
    
        SpriteKitComponent(node: turretNode),
        RelayComponent(for: sharedPointerEventComponent),
                        
        // Hypothetical game-specific components.
        HealthComponent(),
        AttackComponent(),
        MonsterTargetingComponent(),
 
        // Track the first touch or mouse drag that begins inside the sprite.
        NodePointerStateComponent(),
                
        // Let the player select and drag a specific sprite.
        // This differs from the PointerControlledPositioningComponent in a previous example, 
        // which repositions nodes regardless of where the pointer began.
        PointerControlledDraggingComponent() ]))
}

// Once the first monster wave starts, you could replace PointerControlledDraggingComponent 
// with PointerControlledShootingComponent to make the turrets immovable but manually-fired.
```

## Overview

OctopusKit uses an ["Entity-Component-System"][entity–component–system] architecture, where:

- 🎬 A game is organized into **States** such as *MainMenu*, *Playing* and *Paused*. Each state is associated with a **SwiftUI** view which displays the user interface, and a **SpriteKit Scene** that presents the gameplay for that state using **Entities**, **Components** and **Systems**.

    > You can divide your game into as many or as few states as you want. e.g. A single "PlayState" which also handles the main menu, pausing, cutscenes etc.
    
    > States, Scenes, and SwiftUI views may have many-to-many relationships that may change during runtime.

- 👾 **Entities** are simply collections of **Components**. They contain no logic, except for convenience constructors which initialize groups of related components. 

- 🧩 **Components** (which could also be called Behaviors, Effects, Features, or Traits) are the core concept in OctopusKit, containing the properties as well as the logic\* which make up each visual or abstract element of the game. A component runs its code when it's added to an entity, when a frame is updated, and/or when it's removed from an entity. Components may query their entity for other components and affect each other's behavior to form dynamic dependencies during runtime. The engine comes with a library of customizable components for graphics, gameplay, physics etc. 

- ⛓ **Systems** are simply collections of components *of a specific class.* They don't perform any logic\*, but they're arranged by a **Scene** in an array to execute components from all entities in a deterministic order every frame, so that components which rely on other components are updated after their dependencies.

    > \* *These definitions may differ from other engines, like Unity, where all the logic is contained within systems.*  
   
- 🎛 **User Interface** elements like buttons, lists and HUDs are designed in **SwiftUI**. This allows fluid animations, sharp text, vector shapes, live previews, automatic data-driven updates, and over 1,500 high-quality icons from Apple's [SF Symbols.][sf-symbols]

See the [Usage Guide][usage-guide] for a detailed breakdown of the object hierarchy.

Your primary workflow will be writing component classes for each "part" of the graphics and gameplay, then combining them to build entities which appear onscreen or abstract entities that handle data on the "backend", while SwiftUI lets you design slick HUDs and other UI in declarative code.

> e.g. say a _ParallaxBackgroundEntity_ containing a _CloudsComponent_, a *HillsComponent* and a *TreesComponent*, or a _GameSessionEntity_ containing a _WorldMapComponent_ and a _MultiplayerSyncComponent_.

**Performance:** Although extensive benchmarks have not been done yet, OK can display **over 3000 sprites on an iPhone X at 60 frames per second**; each sprite represented by an entity with multiple components being updated every frame, and responding to touch input.

## Design Goals

- **Tailored for Swift**: Swift, Swift, Swift! The framework must follow the [established guidelines][swift-api-guidelines] for Swift API design. Everything must make sense within Swift and flow seamlessly with Swift idioms as much as possible.

- **Vitamin 2D**: At the moment, OK is primarily a framework for 2D games, but it does not prevent you from using technologies like SceneKit (which I plan to add direct support for), and it can be used for non-game apps.

- **Shoulders of Ettins**: The engine leverages SpriteKit, GameplayKit, SwiftUI and other technologies provided by Apple. It should not try to "fight" them, replace them, or hide them behind too many abstractions.
    
    > OK is mostly implemented through custom subclasses and extensions of the SpriteKit and GameplayKit classes, without "obscuring" them or blocking you from interacting with the base classes. This allows you to adopt this framework incrementally, and lets you integrate your game with the Xcode IDE tools such as the Scene Editor where possible.  
    
    > Most importantly, the tight coupling with Apple APIs ensures that your game is future-proof; whenever Apple improves these frameworks, OctopusKit and your games should also get some benefits "for free." For example, when Metal was introduced, SpriteKit was updated to automatically use Metal instead of OpenGL under the hood, giving many existing games a performance boost. [(WWDC 2016, Session 610)][wwdc-610]    

- **Code Comes First**: OK is primarily a "programmatical" engine; almost everything is done in code. This also helps with source control. The Xcode Scene Editor is relegated to "second-class citizen" status because of its incompleteness and bugs (as of  May 2018, Xcode 9.4), but it is supported wherever convenient. See the next point.

    > 💡 You can design high-level layouts/mockups in the Scene Editor, using placeholder nodes with names (identifiers.) You may then create entities from those nodes and add components to them in code.
    
    > Now with SwiftUI, programming for Apple platforms is heading towards a focus on code instead of visual editors anyway. 

- **Customizability & Flexibility**: The engine strives to be flexible and gives you the freedom to structure your game in various ways. Since you have full access to the engine's source code, you can modify or extend anything to suit the exact needs of each project.   
    
    > You can use any of the following approaches to building your scenes, in order of engine support:  
    
    > 1. Perform the creation and placement of nodes mostly in code. Use the Xcode Scene Editor infrequently, to design and preview a few individual elements such as entities with specific positions etc., not entire scenes, and use `SKReferenceNode` to load them in code.  
    
    > 2. Use the Xcode Scene Editor as your starting point, to create template scenes that may be loaded as top-level `SKReferenceNode` instances of an `OKScene`. This approach allows a modicum of "WYSIWYG" visual design and previewing.  
    
    > 3. Create a scene almost entirely in the Xcode Scene Editor, adding any supported components, actions, physics bodies, navigation graphs and textures etc. right in the IDE.   
Set the custom class of the scene as `OKScene` or a subclass of it. Load the scene by calling `OKViewController.loadAndPresentScene(fileNamed:withTransition:)`, e.g. during the `didEnter.from(_:)` event of an `OKGameState`.  
    
    > 4. You don't *have* to use any of the architectures and patterns suggested here; you don't have to use game states, and your game objects don't even have to inherit from any OK classes. You could use your own architecture, and just use OK for a few helper methods etc., keeping only what you need from this framework and excluding the rest from compilation.

- **Self-Containment**: You should not need to download or keep up with any other third-party libraries if your own project does not require them; everything that OK uses is within OK or Apple frameworks, so it comes fully usable out-of-the-box.

## Getting Started

1. **Read the [QuickStart][quickstart] and [Usage Guide.][guide]** You will need Xcode 11, iOS 13 and macOS Catalina (though OK may work on older versions with some manual modifications.)

    > **Skill Level: Intermediate**: Although OK is not presented in a form designed for absolute beginners, mostly because I'm too lazy to write documentation from step zero, it's not "advanced" level stuff either; if you've read the [Swift Language Book][swift-book] and have attempted to make a SpriteKit game in Xcode, you are ready to use OK! 
     
    > You should also read about the ["Composition over inheritance"][composition-over-inheritance] and ["Entity–component–system"][entity–component–system] patterns if you're not already familiar with those concepts, although OK's implementation of these may be different than what you expect.
    
    > Also see Apple's tutorials for [SwiftUI.][swiftui]

2. For a detailed overview of the engine's architecture, see [Architecture.][architecture]

3. Stuck? See [Tips & Troubleshooting.][tips]

4. Wondering whether something was intentionally done the way it is, or why? [Coding Conventions & Design Decisions][conventions-&-design] may have an explanation.

5. Want to keep tabs on what's coming or help out with the development of missing features? See the [TODO & Roadmap.][todo]

## Etcetera

- This project may be referred to as OctopusKit, "OK" or "OKIO" (for "OctopusKit by Invading Octopus") but "IOOK" sounds weird.

- The naming is a combination of inspiration from companies like Rogue Amoeba, the .io domain, and the anime *Shinryaku! Ika Musume*.

- The space before the last `])` in the Examples section is for clarity. :)

- **License: [Apache 2.0][license]**

- **Tell** me how awesome or terrible everything is: [Discord][discord], [Twitter][twitter] or 🆂hinryaku🆃ako@🅘nvading🅞ctopus.ⓘⓞ

    > I rarely check these though, so the best way to message may be to post something on this GitHub project.

- **Support** my decadent lifestyle so I can focus on making unsaleable stuff: [My Patreon][patreon]

- *This project is not affiliated in any way with Apple.*

----

[OctopusKit][repository] © 2019 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html
[twitter]: https://twitter.com/invadingoctopus
[discord]: https://discord.gg/y3har7D
[patreon]: https://www.patreon.com/invadingoctopus

[quickstart]: https://github.com/InvadingOctopus/octopuskit/blob/master/QuickStart/README%20QuickStart.md
[guide]: https://invadingoctopus.io/octopuskit/documentation/guide.html
[architecture]: https://invadingoctopus.io/octopuskit/documentation/architecture.html
[tutorials]: https://invadingoctopus.io/octopuskit/documentation/tutorials.html
[tips]: https://invadingoctopus.io/octopuskit/documentation/tips.html
[conventions-&-design]: https://invadingoctopus.io/octopuskit/documentation/conventions.html
[todo]: https://invadingoctopus.io/octopuskit/documentation/todo.html

[swift-book]: https://docs.swift.org/swift-book/GuidedTour/GuidedTour.html
[swift-api-guidelines]: https://swift.org/documentation/api-design-guidelines/
[wwdc-610]: https://developer.apple.com/videos/play/wwdc2016-610/?time=137
[composition-over-inheritance]: https://en.wikipedia.org/wiki/Composition_over_inheritance
[entity–component–system]: https://en.wikipedia.org/wiki/Entity–component–system
[swiftui]: https://developer.apple.com/tutorials/swiftui/
[sf-symbols]: https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/

[demo-gif]: QuickStart/Images/OctopusKitQuickStartDemo20191024.gif "QuickStart Demo"
