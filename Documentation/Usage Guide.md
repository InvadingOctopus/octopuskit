---
permalink: documentation/usage.html
---

# OctopusKit Usage Guide

> *This documentation assumes that the reader has some prior experience with developing for Apple platforms in the Swift programming language.*

1. [Quickstart](#quickstart)
2. [Control Flow & Object Hierarchy](#control-flow--object-hierarchy)
3. [Folder Organization](#folder-organization)
4. [Scenes](#scenes)
5. [Entities](#entities)
6. [Components](#components)
7. [State Machines](#state-machines)
8. [Advanced Stuff](#advanced-stuff)

## Quickstart

### 🍰 **To begin from a template**:

1. Download the [**OctopusKitQuickstart** Xcode project from the Releases page.][quickstart-project]

2. Build and run the project.

3. Modify the `TitleScene.swift` and `PlayScene.swift` files in the `Scenes` folder to customize them for your game.

    > The file names are prefixed with `Step #` so you can follow the flow of execution at a glance.
    >
    > 💡 Browse the `OctopusKit/Components` folder and try tinkering with different components!
    >
    > 💡 If something goes wrong, see [Tips & Troubleshooting.][tips-&-troubleshooting]  

### 🛠 **To import OctopusKit into a new or existing project**:

1. Your storyboard should have an `SKView` whose controller is or inherits from `OctopusSceneController`.

    > XIB-based projects have not been tested.

2. Your `AppDelegate` class must inherit from `OctopusAppDelegate`. It needs to implement (override) only one method: `applicationWillLaunchOctopusKit()`, where it must initialize the shared `OctopusKit` singleton instance by calling:

    ```swift
    OctopusKit(appName: "YourGame", gameController: YourGameControllerClass())
    ```

    > "Game controller" refers to a "controller" in the Model-View-Controller sense here, not a gamepad or joystick, and must be a subclass of `OctopusGameController`.
    >
    > If your game does not need to share any global logic or data across multiple scenes, you can simply call `OctopusGameController(states:initialStateClass:)` instead of creating a subclass.
    
3. The game controller must have at least one state that is associated with a scene, so your project must have custom classes that inherit from `OctopusGameState` and `OctopusScene`. 

    > For an explanation of these classes, see [Control Flow & Object Hierarchy.](#control-flow--object-hierarchy)

4. Your scenes should inherit from `OctopusScene` and they should implement (override) the `update(_:)` method. Your implementation must call `super`, check the paused state flags, and update component systems:

    ```swift
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        guard !isPaused, !isPausedBySystem, !isPausedByPlayer, !isPausedBySubscene else { return }
        
        OctopusKit.shared?.gameController.update(deltaTime: updateTimeDelta)
        updateSystems(in: componentSystems, deltaTime: updateTimeDelta)
    }
    ```

    > Values such as `updateTimeDelta` are calculated when you call `super`.  
    > `componentSystems` is the default array of systems in every scene.
    >
    > Other steps are left for the subclass because each scene may need to handle these differently.

----

#### Notes

* **Xcode Templates:** To quickly create new files for common OK classes such as scenes and components, copy the files from the `Templates/Xcode` folder in the OK package to your `~/Library/Developer/Xcode/Templates/OctopusKit`.

* Including the OctopusKit code in your main project provides the benefits of [Whole Module Optimization](https://swift.org/blog/whole-module-optimizations/), quicker modification and autocompletion, easier navigation etc.

* You can give each of your projects a separate copy of the OctopusKit code to let you customize the engine to suit each specific project, or you can keep a single copy of the engine code and share it between projects (via git, or by dragging the OK package folder into your project *without* checking "**Copy items if needed**")

* Currently, API documentation (i.e. for types/methods/properties) is only provided via extensive source-code comments, which can be viewed in Xcode's Quick Help.

    > This guide provides a detailed overview of the engine architecture, but there is no standalone reference for the API, as I don't have the time and energy to write that alongside developing the engine. (´･_･`)  
    >
    > The best way to learn may be to examine the engine source code. In the future I might make a demo game to serve as a comprehensive tutorial.

## Folder Organization

- `Apple API Extensions`: Adds engine-specific functionality and general convenience features to the classes provided by Apple.

- `Assets`: A collection of basic images, shaders and sounds to get you started.

- `Components`: A wide library of components for graphics, gameplay, physics, UI and other aspects of a game. Although many are marked `final` by default (to improve performance, see [TODO LINK]), you can modify and extend them as needed.

- `Core/Base`: The base classes for game states, scenes, entities, components and 
systems.

- `Core/Launch`: The objects that launch your game and manage the OctopusKit environment.  
    > 💡 If your project crashes on startup, i.e. immediately returns to the home screen without showing anything, the classes in this folder are where you should look first.
        
- `Entities`: Provides classes to quickly construct entities for common tasks, such as UI buttons, from groups of standard components.

- `Miscellaneous`: General types used by various components, such as compass directions.

- `Scene Templates`: Some prebuilt scenes, such as the OctopusKit logo.

- `Support & Utility`: Auxiliary classes that are required for common OctopusKit functionality, such as logging, but may not always be needed. Advanced projects may exclude these or use custom implementations.

## Control Flow & Object Hierarchy

| 🐙 |
| :-: |
|📱 *Operating System*|
|↓|
|📲 `YourAppDelegate: OctopusAppDelegate`|
|↓|
|🎬 `YourGameController: OctopusGameController` ¹|
|↓|
|🚦 `YourGameState: OctopusGameState`|
|↕|
|🏞 `YourScene: OctopusScene` ²|
|↓|
|👾 `OctopusEntity` ³|
|↓|
|🚥 `YourEntityState: OctopusEntityState` ⁴|
|↕|
|⚙️ `YourComponent: OctopusComponent` ⁵|
|↑|
|⛓ `OctopusComponentSystem` ⁶|

> ¹ `OctopusGameController` need not always be subclassed; projects that do not require a custom controller may use `OctopusGameController(states:initialStateClass:)`.
> 
> ² `OctopusScene` may tell the game controller to enter different states and transition to other scenes. A scene itself is also represented by an entity which may have components of its own. A scene may be comprised entirely of components only, and need not necessarily have sub-entities.  
>
> ³ `OctopusEntity` need not always be subclassed; `OctopusEntity(name:components:)` may be enough for most cases.
>
> ⁴ `OctopusEntityState`s are optional. An entity need not necessarily have states.  
>
> ⁵ `OctopusComponent` may tell its entity to enter a different state, and it can also signal the scene to remove/spawn entities.  
>
> ⁶ `OctopusComponentSystem`s are used by scenes to group each type of component in an ordered array which determines the sequence of component execution for every frame.

### Tier 1

📱 `OctopusAppDelegate:`[`UIApplicationDelegate`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate) or [`NSApplicationDelegate`](https://developer.apple.com/documentation/appkit/nsapplicationdelegate)  
🎬 `OctopusGameController:`[`GKStateMachine`](https://developer.apple.com/documentation/gameplaykit/gkstatemachine)  
🚦 `OctopusGameState:`[`GKState`](https://developer.apple.com/documentation/gameplaykit/gkstate)

- At launch, the application delegate configures a **Game Controller** object, which is a "controller" in the [MVC][mvc] sense. A game controller is a **State Machine** with one or more **Game States**, each associated with a **Scene**. The controller may also manage global objects that are shared across states and scenes, i.e. the "model" of the game, such as the game world's map, player stats, multiplayer network sessions and so on.  

	> 💡 *Advanced: A single application may have multiple "games" by using multiple game controllers, each with its own hierarchy of states and scenes.*

### Tier 2 

🏞 `OctopusScene:`[`SKScene`](https://developer.apple.com/documentation/spritekit/skscene)

- A **Scene** presents the visuals, plays audio, and receives player input events and device updates for each state or "act" of the game. A scene is itself an **Entity** with various **Components**, and it loads or creates sub-entities that represent the characters and other elements of the gameplay. 

    > A single scene may represent multiple game states.  
    > e.g.: for most games, it may not be necessary to have a separate scene for a "Paused" game state, and a single scene may handle both "Play" and "Paused" game states by displaying a dark overlay and some text in the paused state.

- TODO: Explain Subscenes (used for displaying modal UI.)

### Tier 3

👾 `OctopusEntity:`[`GKEntity`](https://developer.apple.com/documentation/gameplaykit/gkentity)  
🚥 `OctopusEntityState:`[`GKState`](https://developer.apple.com/documentation/gameplaykit/gkstate)

- An **Entity** is a group of **Components** that may interact with each other. It may also have an **Entity State Machine** which is a special component comprising different **Entity States**. Each state has logic that decides which components to add to the entity and which components to remove depending on different conditions, as well as when to transition to a different state.

	> e.g.: A *GrueEntity* with a *SpawningState, NormalState, EatingState and DeadState.*

### Tier 4

⚙️ `OctopusComponent:`[`GKComponent`](https://developer.apple.com/documentation/gameplaykit/gkcomponent)  

- A **Component** represents each onscreen object or unit of game logic. It may contain properties and execute logic at specific moments in its lifetime: when it's added to an entity, removed from an entity, and/or once every frame. A component may signal its entity to enter a different state, or request the entity's scene to spawn new entities, or even to remove the component's own entity from the scene. 

    > Components may also access the game controller and its states. Nothing is "off limits" to a component; what a component may do is up to you. However, good programming practices dictate that a component only access its entity and its co-components.

⛓ `OctopusComponentSystem:`[`GKComponentSystem`](https://developer.apple.com/documentation/gameplaykit/gkcomponentsystem)

- Whenever a component is added to an entity, the scene registers the component with a **Component System** that matches the component's class. Only components that perform any logic during frame updates need to be registered with a system.

- After enumerating all components from all entities and adding them to a list of **Component Systems**, the scene updates each system in a deterministic order during the `OctopusScene.update(_:)` method every frame. The array of systems should be arranged such that components which depend on other components are processed after their dependencies.

	> e.g.: An entity's `TouchControlledPositioningComponent` must be executed after its `TouchEventComponent`, so a scene's component systems array should place the system for `TouchEventComponent`s before the system for `TouchControlledPositioningComponent`s.

- Over the course of the gameplay, a scene, state or even a component may signal the **Game Controller** to enter a different **Game State** in response to certain game-specific conditions. The current game state's logic determines whether the transition is valid; if it is, the state then passes control to another state, which may then load a different scene.

    > As noted above, a single scene may choose to handle multiple game states. In those cases, no scene transition occurs during a game state transition. 

## Scenes

TODO: Incomplete section; to revise  
TODO: OctopusScene API overview

### Scenes should:

- Try to encapsulate as much of their content into components, including visual content as well as non-visual functionality, such as music and input subsystems.

## Entities

TODO: Incomplete section; to revise  
TODO: OctopusEntity API overview

- Contain components which are the primary block of game functionality.

- May dynamically add or remove components during runtime, mutating themselves and taking on new behaviors.

- Have a delegate (which is by default the scene they're added to) to assist components with spawning new entities and removing themselves from their scene.

- May be subclassed from `OctopusEntity` and offer `init` constructors that group sets of related components. The components may be customized according to the supplied arguments.

	> e.g.: A *PlayerShipEntity* with "mass", "speed" etc. parameters.

- Contain `StateMachineComponent`s that add and remove groups of components to the entity depending on the state.
    
    > e.g.: a player character in a *SpawningState* may have a *BlinkingEffectComponent* but no *DamageComponent* as it must be invulnerable before it has fully spawned, but entering the *ReadyState* will add a *DamageComponent* as well as a *PlayerControlComponent* etc.

### Entities should *not:*

- Be subclassed too much, i.e. inherited from a subclass of `OctopusEntity`. Do not fall into the traps of inheritance, which may defeat the advantages of composition that components are supposed to offer.

- Contain properties or code other than initializers/constructors.

## Components

TODO: Incomplete section; to revise  
TODO: OctopusComponent API overview

- Ideally, components should have no methods/callbacks triggered by events, delegation or notifications. If a component needs to process events, then a parent object, such as a scene or view controller, should create a separate component for holding copies of events every frame. Components that rely on events should read that event-holding component every frame. An example would be an input events component.

- SpriteKit and GameplayKit features should be abstracted behind and accessed via components as much as conveniently and practically possible.
	
	> e.g.: access an `SKSpriteNode`'s `physicsBody` through a `PhysicsComponent`, instead of an `SpriteKitComponent`'s node. This way, when the `PhysicsComponent` is removed from an entity, it marks the entity as no longer affected by physics.

- A component's properties can be supplied upon initialization and should generally be accessible afterwards.

- A component may depend upon other components of its entity, and it may provide the list of its co-dependencies/requirements as a property.

- Since components may be dynamically added to and removed from an entity, a component should query its entity for any required co-components whenever they are needed, e.g. on every frame update. Instead of raising exceptions or halting the app, a component should simply skip part or all of its functionality (optionally logging a warning) if any dependencies are unavailable.

- Dependencies should not be hardcoded or supplied in an init, unless they are "global" components, such as components of the scene's entity that process player input.

### Component Categories

Each component may be conceptually classified under one or more of the following categories:

- **Data Component**: Adds some properties to the entity.

	> e.g.: A *PlayerInfoComponent* with "playerName" and "score" properties.
		
- **Logic Component**: Executes some code when added to an entity, during every frame, upon being removed from an entity, or in response to external/asynchronous events such as player input.

- **Coordinator Component**: A logic component that observes one or more components and uses that information to act upon other components.

    > TODO: example

- **Visual Component**: A logic component that mainly adds visual effects or child nodes to the SpriteKit node associated with the entity. 

	> e.g.: A *SpinComponent* that sets an entity's color to green when added to the entity, changes the entity's rotation a little in every frame, and sets the entity's color to red when removed from the entity.
		
- **Support/Utility Component**: Performs no action upon the entity on its own, but provides a set of methods and data to assist other components.

	> e.g.: A `TextureDictionaryComponent` used by a `TextureAnimationComponent`, and a `TouchEventComponent` used by many touch-controlled components.
		
### Components should:

- Be broken into sub-components if one component handles many duties.
    
	> e.g.: a `PlayerControlComponent` may be broken down into a `TouchControlledSeekingComponent` and a `MotionControlledThrustComponent`.

### What should be Entities and what should be Components?

- An spaceship, or a monster, are not Components; they are Entities. A spaceship may have a *ThrusterComponent*, and a *GunComponent*. A monster may have a *MonsterSpeciesComponent*. Both will have a `SpriteKitComponent`, `PhysicsComponent` etc.

## State Machines

TODO: Incomplete section; to revise  
TODO: OctopusGameState/OctopusEntityState API overview  


- If an entity can be in one of several conceptual states at a given time, it more makes sense to represent those states with a `GKStateMachine` (as encapsulated by a `StateMachineComponent`) instead of putting lots of conditional checks in multiple components.

	> e.g.: A spaceship entity with gun components that generate heat and temporarily stop firing when they are overheated. Without states, you might need to repeatedly check for the overheated state in *GunComponent* and *GunControlComponent* and *ShipVisualEffectsComponent* etc. With states, you may have an *OverheatedState* that removes the *GunControlComponent* and adds a *OverheatedVisualEffectComponent*. The overheated state monitors the *HeatComponent* to see when the ship cools down, and transitions the entity back to its *NormalState* which restores the relevant components necessary for normal player control.

### State classes should:

- Only handle the logic of when and whether to transition to a different state.

## Advanced Stuff

### Using the Xcode Scene Editor as the primary design tool 

TODO: Incomplete section; to revise

Set the custom class of the scene as `OctopusScene` or a subclass of it. Load the scene by calling `OctopusSceneController.loadAndPresentScene(fileNamed:withTransition:)`, e.g. during the `didEnter.from(_:)` event of an `OctopusGameState`.  

----

OctopusKit © 2018 [Invading Octopus][website] • [Apache License 2.0][license] • [github.com/invadingoctopus/octopuskit][repository]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[quickstart-project]: https://github.com/invadingoctopus/octopuskit/releases
[octopuskit-github]: https://github.com/invadingoctopus/octopuskit

[tips-&-troubleshooting]: tips.html

[mvc]: https://en.wikipedia.org/wiki/Model–view–controller
