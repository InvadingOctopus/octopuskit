# OctopusKit 👾🐙⚙️

A flexible composition-based game engine written in Swift for iOS, macOS and tvOS.  
Built upon Apple's SpriteKit, GameplayKit and Metal technologies.

1. [Examples](#examples)
2. [Overview](#overview)
3. [Design Goals](#design-goals)
4. [Getting Started](#getting-started)
5. [Etcetera](#etcetera) (license, contact etc.)

🚀 *Anxious to dive in? Download the [Quickstart project.][quickstart-project]* 

> This is a result of trying to make my own games as a hobby. I love Swift but I couldn't find any engines that support it or had the kind of architecture that I wanted to work with, so I started making my own *(see Design Goals ahead.)*
>
> It's also my first ever open-source project and a **work in progress**; I'm still learning. If you have any advice on how to improve the API, coding style, git workflow, or open-source best-practices, I'll be thankful to hear it!
>
> *– ShinryakuTako* 

## Examples

👾 *Creating an animated sprite*

```swift
let character = OctopusEntity(components:[
    
    // Start with a blank sprite.
    SpriteKitComponent(node: SKSpriteNode(color: .clear, size: CGSize(widthAndHeight: 42))),
    
    // Load texture resources.
    TextureDictionaryComponent(atlasName: "PlayerCharacter"),
    
    // Animate the sprite with textures whose names begin with the specified prefix.
    TextureAnimationComponent(initialAnimationTexturePrefix: "Idle")])
```

📱 *Adding player control*

```swift
// Add a component to the scene that will be updated with input events.
// Other components that handle player input will query this component.
// A shared event stream is more efficient than forwarding events to every entity.

let sharedTouchEventComponent = TouchEventComponent()
scene.entity?.addComponent(sharedTouchEventComponent)

character.addComponents([
    
    // A relay component adds a reference to a component in another entity.
    // This fulfills the dependencies of other components in this entity.
    RelayComponent(for: sharedTouchEventComponent),
    
    // This component checks the entity for a TouchEventComponent (provided here by a relay)
    // and syncs the entity's position to the touch location in every frame.
    TouchControlledPositioningComponent()])
```

🕹 *Dynamically removing player control or changing to a different input method*

```swift
character.removeComponents(ofTypes: [
    RelayComponent<TouchEventComponent>.self,
    TouchControlledPositioningComponent.self])
    
character.addComponents([

    // Add a physics body to the sprite.
    PhysicsComponent(),
    
    // Use a hypothetical shared component.
    RelayComponent(for: scene.sharedJoystickEventComponent),
    
    // Apply a force to the sprite's body based on joystick input in every frame.
    JoystickControlledForceComponent()])
```

🎛 *Advanced: Using a custom "script" to change the animation based on player movement*

```swift
// Add a component that executes custom code every frame.
character.addComponent(RepeatedClosureComponent { component in
    
    // Check if the entity of this component has the required dependencies at runtime.
    // This approach allows dynamic behavior modification without hardcoding anything.
    
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

if let editorScene = SKReferenceNode(fileNamed: "EditorScene.sks") {
    scene.addChild(editorScene)
}

// Search the entire node tree for all nodes named "Turret",
// and give them properties of "tower defense" turrets
// and make them independently draggable by the player.

for namedNode in scene["//Turret"] {
    scene.addEntity(OctopusEntity(components: [
        SpriteKitComponent(node: namedNode),
        PhysicsComponent(),
        RelayComponent(for: sharedTouchEventComponent),
                
        // Track the first touch that begins inside the sprite.
        NodeTouchComponent(),
                
        // Move the sprite along with the tracked touch.
        // This differs from the TouchControlledPositioningComponent in a previous example.
        TouchControlledDraggingComponent()
                
        // A GameplayKit Agent used by AI components.
        OctopusAgent2D(),        

        // Hypothetical game-specific components.
        HealthComponent(),
        AttackComponent(),
        MonsterTargettingComponent()]))
}

// Once the first monster wave starts, you could replace TouchControlledDraggingComponent 
// with TouchControlledShootingComponent to make the turrets immovable but manually-triggered.
```

## Overview

OctopusKit uses an ["Entity-Component-System"][entity–component–system] architecture, where:

- 🎬 A game is organized into **States** (such as "MainMenu", "Playing" and "Paused") and **Scenes** that display the content for those states using **Entities**, **Components** and **Systems**.

- 👾 **Entities** are simply collections of **Components**. They contain no logic, except for convenience constructors which initialize groups of related components. 

- ⚙️ **Components** (which could also be called Behaviors, Effects, Features, or Traits) are the core concept in OctopusKit, containing the properties as well as the logic\* which make up each visual or abstract element of the game.They may be dynamically added to and removed from an entity to alter its appearance and behavior during runtime. OK comes with a library of many customizable components for graphics, gameplay, physics and UI etc. 

- ⛓ **Systems** are simply collections of components of a specific type. They do not perform any logic, but they are arranged by a **Scene** to execute components in a deterministic order every frame, so that components which rely on other components are updated after their dependencies.

    > \* *These definitions may differ from other engines, like Unity.*  
    > *OK does not use "data-oriented design" but it does not prevent you from implementing that in your project.*

The primary workflow is writing component classes for each "unit" of visual appearance and gameplay logic, then combining them in entities that appear onscreen or handle game data in the "backend."

> e.g.: Say a _SceneBackgroundEntity_ containing a _CloudsComponent_ and a *HillsComponent*, or a _GameSessionEntity_ containing a _WorldMapComponent_ and a _MultiplayerSyncComponent_.)

## Design Goals

- **Tailored for Swift**: Swift, Swift, Swift! The framework must follow the [established guidelines][swift-api-guidelines] for Swift API design. Everything must make sense within Swift and flow effortlessly with Swift idioms, without any friction against the "Swift way of thinking."

- **Vitamin 2D**: At the moment, OK is primarily a framework for 2D games, but it does not prevent you from using SceneKit or other technologies to render 3D content in 2D space, and it can be used for non-game apps.

- **Shoulders of Giants**: The engine leverages SpriteKit, GameplayKit and their related technologies. It should not try to "fight" them, replace them, or hide them behind too many abstractions.

    > OK is mostly implemented through custom subclasses and extensions of the SpriteKit and GameplayKit classes, without "obscuring" them or blocking you from interacting with the base classes. This allows you to adopt this framework incrementally, and lets you integrate your game with the Xcode IDE tools such as the Scene Editor where possible.  
    >
    > Most importantly, the tight coupling with Apple APIs ensures that your game is future-proof; whenever Apple improves these frameworks, OctopusKit and your games should also get some benefits "for free." For example, when Metal was introduced, SpriteKit was updated to automatically use Metal instead of OpenGL under the hood, giving many existing games a performance and efficiency boost. [(WWDC 2016, Session 610)][wwdc-610]    
- **Code Comes First**: OK is primarily a "programmatical" engine; almost everything is done in code. This also helps with source control. The Xcode Scene Editor is relegated to "second-class citizen" status because of its incompleteness and bugs as of May 2018 (Xcode 9.4), but it is supported wherever convenient. See the next point.

    > 💡 You can design high-level layouts/mockups in the Scene Editor, using placeholder nodes with names (identifiers.) You may then create entities from those nodes and add components to them in code.

- **Customizability & Flexibility**: The engine strives to be flexible and gives you the freedom to structure your game in various ways. Since you have full access to the engine's source code, you can modify or extend anything to suit the exact needs of each project.   

    > You can use any of the following approaches to building your scenes, in order of engine support:  
    >
    > 1. Perform the creation and placement of nodes mostly in code. Use the Xcode Scene Editor infrequently, to design and preview a few individual elements such as UI HUDs etc., not entire scenes, and use `SKReferenceNode` to load them in code.  
    >
    > 2. Use the Xcode Scene Editor as your starting point, to create template scenes that may be loaded as top-level `SKReferenceNode` instances of an `OctopusScene`. This approach allows a modicum of "WYSIWYG" visual design and previewing.  
    > 3. Create a scene almost entirely in the Xcode Scene Editor, adding any supported components, actions, physics bodies, navigation graphs and textures etc. right in the IDE.   
Set the custom class of the scene as `OctopusScene` or a subclass of it. Load the scene by calling `OctopusSceneController.loadAndPresentScene(fileNamed:withTransition:)`, e.g. during the `didEnter.from(_:)` event of an `OctopusGameState`.  
    >
    > 4. You don't *have* to use any of the architectures and patterns suggested here; you don't have to use game states, and your game objects don't even have to inherit from any OK classes. You could use your own architecture, and just use OK for a few helper methods etc., keeping only what you need from this framework and excluding the rest from compilation.

- **Self-Containment**: You should not need to download or keep up with any other third-party libraries if your own project does not require them; everything that OK uses is within OK or Apple frameworks, so it comes fully usable out-of-the-box.

## Getting Started

1. **Read the [Quickstart and Usage Guide.][quickstart-&-usage-guide]** You will need Xcode 9.4 or 10.

2. Stuck? See [Tips & Troubleshooting.][tips-&-troubleshooting]

3. Wondering whether something was intentionally done the way it is, or why? [Coding Conventions & Design Decisions][coding-conventions-&-design-guide] may have an explanation.

4. Want to keep tabs on what's coming or help out with the development of missing features? See the [TODO & Roadmap.][todo-&roadmap]

## Etcetera

> **Skill Level: Intermediate**: OK does not attempt to present itself as a tool for "absolute beginners", mostly because I'm too lazy to write documentation from step zero, but it's not "advanced" level stuff either. If you've read the [Swift Language Book][swift-book] and have attempted to make a SpriteKit game in Xcode, you are ready to use OK. 
> 
> You should also read about the ["Composition over inheritance"][composition-over-inheritance] and ["Entity–component–system"][entity–component–system] patterns if you're not already familiar with those concepts, although OK's implementation of these may be different than what you expect.

- Currently, API documentation is only provided via extensive source-code comments; there is no standalone documentation for the API, as I do not have the time and energy to write it alongside developing the engine. :(

    > The best way for learning how to make the most of this engine is to examine the [Quickstart project][quickstart-project] and read the engine source code. In the future I might build a demo game to serve as a tutorial.

- This project may be referred to as "OctopusKit", "OK" or "OKIO" (for "OctopusKit by Invading Octopus") but "IOOK" sounds weird.

- **Support** my decadent lifestyle so I can focus on making unsaleable stuff: [My Patreon][patreon]

- **Tell** me how awesome or terrible everything is: [Discord][discord], [Twitter][twitter] or 🆂hinryaku🆃ako@🅘nvading🅞ctopus.ⓘⓞ

- **License: [Apache 2.0][license]**

- *Not affiliated in any way with Apple.*

----

OctopusKit © 2018 [Invading Octopus][website] • [Apache License 2.0][license] • [github.com/invadingoctopus/octopuskit][repository]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html
[twitter]: https://twitter.com/invadingoctopus
[discord]: https://discord.gg/y3har7D
[patreon]: https://www.patreon.com/invadingoctopus

[quickstart-&-usage-guide]: ./Documentation/Usage%20Guide.md
[quickstart-project]: ../../releases
[tips-&-troubleshooting]: ./Documentation/Tips%20&%20Troubleshooting.md
[coding-conventions-&-design-guide]: ./Documentation/Coding%20Conventions%20&%20Design%20Decisions.md
[todo-&roadmap]: ./Documentation/TODO%20&%20Roadmap.md

[swift-book]: https://docs.swift.org/swift-book/GuidedTour/GuidedTour.html
[swift-api-guidelines]: https://swift.org/documentation/api-design-guidelines/
[wwdc-610]: https://developer.apple.com/videos/play/wwdc2016-610/?time=137
[composition-over-inheritance]: https://en.wikipedia.org/wiki/Composition_over_inheritance
[entity–component–system]: https://en.wikipedia.org/wiki/Entity–component–system

