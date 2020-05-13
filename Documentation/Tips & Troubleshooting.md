---
permalink: documentation/tips.html
---

# OctopusKit Tips & Troubleshooting

1. [Common Mistakes](#common-mistakes)
2. [Best Practices](#best-practices)
3. [Tips & Tricks](#tips--tricks)
4. [Pitfalls & Gotchas](#pitfalls--gotchas)
5. [Conditional Compilation Flags & Debugging Aids](#conditional-compilation-flags--debugging-aids)
6. [Bugs](#bug)
7. [Other Resources](#other-resources)

* 🚀 **To quickly start using OctopusKit with a template project, see [QuickStart.][quickstart]**
* ❓ **To see how to do common tasks, check the [Usage Guide.][guide]**

## Common Mistakes

#### Components not having any effect? 
- If the component has an `update(deltaTime:)` method, make sure it's registered with a Component System, or is manually updated during the scene's `update(_:)` method, and *is only updated* ***once!*** [TODO: make this automatic]

- Does the entity have all the components that the non-functioning component depends on? A component's dependencies must be added to the entity before the component that depends on them. [TODO: make this automatic]

- Pay attention to the order of components when adding them to an entity and when adding their systems to the scene.

    > Suppose *ComponentB* depends on *ComponentA*, but *ComponentB* has to execute its logic *before* *ComponentA* during every frame update cycle; so *ComponentB* must be added to the entity ***after*** *ComponentA*, but the *system* for *ComponentB* must be added to the scene ***before*** *ComponentA*.

- Check the log for warnings.

#### Components having *too* much effect? 
- Make sure that a component is updated (if applicable) only once per frame.
- Also make sure that a component *system* is added to a scene only once!

#### Input event components not working?
- The `OKScene.shared...` event components should be added to the `OKScene.entity` – Did you directly add one of them to a sub-entity, instead of a `RelayComponent` to them? Components can only be in one entity at a time! When you add the event components to a child entity, the default scene implementation cannot forward input events to it.

#### Gesture recognizer components not working? 
- Check their properties for the minimum and maximum number of touches.

#### Scene, subscene or node not receiving input events?
- Check its `isUserInteractionEnabled` property.
    
## Best Practices

- Remember to search the entire source code for `BUG:`, `APPLEBUG:`, `FIXME:` etc. comments for any outstanding bugs and their temporary workarounds, if any.

- In most cases, try to access the object hierarchy from the "bottom up" instead of "top down."

	> TODO: Example

## Tips & Tricks

* Advanced: Including the OctopusKit code in your main project (instead of as a package dependency) *may* provide the benefits of [Whole Module Optimization.](https://swift.org/blog/whole-module-optimizations/)
    
## Pitfalls & Gotchas

- Many methods MUST be overridden in a subclass and/or chained to the superclass implementation, by calling `super.method()`. Some methods should call `super` at different points (i.e. beginning or end) in the subclass' implementation. Unfortunately, there is no language-level support for enforcing that, so your best bet is to read the source and comments of the method you're overriding.
    > 💡 When in doubt, always call `super`, and call it at the top of your overriding method.  
    > TODO: make this chaining automatic/enforced when/if Swift supports it
    
- Components should try to perform their logic only during the `didAdd(...)`, `willRemove(...)`, and `update(deltaTime:)` methods. If a component's behavior must be modified outside of those methods, use flags that are then acted upon in the component's update method.  
This ensures that a component does not affect anything outside of a frame update and can be reliably paused/unpaused.  
    > Note that this does not mean that a component should not _define_ any other methods at all.  
    > TODO: Example

    - Components that respond to asynchronous events, such as a component that moves a node based on input from a gesture recognizer, like `PanControlledRepositioningComponent`, or networking components, MUST perform their function inside their `update(deltaTime:)` method, and just use the event-handling action method to mark a flag to denote that an event was received.  
This prevents the component from being active outside the frame-update cycle, or when it's [temporarily] removed from the entity or the scene's systems.

    - A SpriteKit scene processes touch and other input events **outside** of its `update(_:)` method; when those event handlers update input-processing components, those components will (should) only be able to act on the input data during the scene's `update(_:)` method.

- OctopusKit components may sometimes cause some "friction" against the SpriteKit API.  
  e.g.: when adding a `NodeComponent` and a `PhysicsComponent` to an entity; the SpriteKit node may have its own `physicsBody` and the `PhysicsComponent` may have a different `physicsBody`.
    - As a general rule, adding a component to an entity assumes that the component adds its encapsulated functionality to that entity, replacing any identical functionality that already exists. 
    
        > e.g.: If you add a "blank" component, e.g. a `PhysicsComponent` with a `nil` `physicsBody`, then the component attempts to "adopt" any existing properties of the underlying SpriteKit object.  
        In this example, the blank `PhysicsComponent` will set its property to the `physicsBody`, if any, of the `NodeComponent` node. After that, other components should access the node's physics properties through the `PhysicsComponent` instead of the node's `physicsBody` property.

- Entities and components may not always be the answer to everything. *Sometimes* good old classes and structs may be the better solution. (^ - ^")

- An entity can/should only have one component of a specific type (not counting generic variants.)  
If an entity needs multiple components of the same type but with different parameters, consider using a "master" component that holds a collection of regular classes/struct.
    > e.g.: a *ShipEntity* with a *WeaponsSystemComponent* that holds an array of *Gun* classes/structs, to represent multiple guns where each gun is mounted on a different side of the ship.
    
## Conditional Compilation Flags & Debugging Aids

> Set these in the `Package.swift` manifest for OctopusKit. Example: 
> 
>     targets: [
>         .target(
>             name: "OctopusKit",
>             dependencies: [],
>             swiftSettings[.define("LOGINPUTEVENTS")])
>

* `LOGECSVERBOSE` - Logs detailed Entity-Component-System actions.
* `LOGINPUTEVENTS` - Logs all input events and related information via the `@LogInputEvents` property modifier.
* `LOGPHYSICS` - Logs all physics contact/collision events.

⚠️ Setting any of the logging flags may reduce engine performance.

* `DISABLELOGCHANGES` - Suppresses the `@LogChanges` property modifier. May improve performance.

## Bugs

There seem to be some bugs in Apple's own APIs and frameworks that we cannot do much about:

* SpriteKit: **Scenes with cameras are not fully compatible with shaders and `shouldEnableEffects`.** 2020-05-12, 20200512C

    * Setting `shouldEnableEffects = true` on an `SKScene` instance, e.g. for applying a shader to the entire scene, messes up the scene's `camera`:
    * The `SKCameraNode`'s position remains fixed.
    * If the `SKCameraNode` is scaled (zoomed) in or out, the scene becomes blank (black) outside the camera's former frame (apparently equal to the screen size).
    * This happens whether the scene's has a `shader` or not.
    * 💡 Workaround: Untested: Use an `SKEffectNode` and Core Image filters to apply effects to the entire scene.

* SpriteKit: **Shaders with associated uniforms or attributes do not work with `SKTileMapNode`.** 2020-05-12, 20200512A, 20200512B

    * If the shader has uniforms, a runtime crash occurs: `validateFunctionArguments:3476: failed assertion 'Fragment Function(SKShader_FragFunc): missing buffer binding at index 2 for u_xxxxx[0].'`
    * If the `SKTileMapNode` has an `SKAttribute`, it is not propagated to the shader.
    * Shaders without uniforms or attributes work fine with `SKTileMapNode`.
    * 💡 Workaround: Convert the uniforms and attributes to constant values in the shader's source code.

## Other Resources

* [Apple Technical Note TN2451: SpriteKit Debugging Guide](https://developer.apple.com/library/archive/technotes/tn2451/_index.html#//apple_ref/doc/uid/DTS40017609-CH1-SHADERCOMPILATION)

----

[OctopusKit][repository] © 2020 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[quickstart]: https://github.com/InvadingOctopus/octopuskit/blob/master/QuickStart/README%20QuickStart.md
[guide]: https://invadingoctopus.io/octopuskit/documentation/guide.html
[architecture]: https://invadingoctopus.io/octopuskit/documentation/architecture.html
[tutorials]: https://invadingoctopus.io/octopuskit/documentation/tutorials.html
[tips]: https://invadingoctopus.io/octopuskit/documentation/tips.html
[conventions-&-design]: https://invadingoctopus.io/octopuskit/documentation/conventions.html
[todo]: https://invadingoctopus.io/octopuskit/documentation/todo.html
