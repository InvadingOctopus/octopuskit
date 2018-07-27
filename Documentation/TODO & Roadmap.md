---
permalink: documentation/todo.html
---

# OctopusKit Roadmap

> If you'd like to help with the development of the OK project, these are some of the areas that need to be implemented.

1. [Major Missing Features](#major-missing-features)
2. [To Do](#to-do)
3. [To Decide](#to-decide)

## Major Missing Features

*More-or-less in order of priority/necessity:*

- Full macOS and tvOS support (currently in a preliminary state as of 2018-06-08.)
- Components for mouse, keyboard, gamepad/joystick and Siri Remote input.
- Asset/resource loading system.
- Saving and loading game/scene/entity/component states via `Codable`.
- Support for describing scenes/entities/components in HTML/XML/JSON or a  similar format.
- Networking components.
- SceneKit support in 2D scenes, and 3D components.
- Custom Scene Editor & Live Previewer?

## To Do

- Tests. Too lazy.
- Improve coding conventions.
- Write tutorials for common tasks.
- Clarify `super` chaining where applicable – when an overridden method in a subclass *needs* to call the superclass method for the functionality to work correctly – and enforce it when it becomes possible through language support in a future version of Swift.
- Eliminate the possibility of a `SKNode.physicsBody` being added to a scene more than once.
- Internationalization/Localization
- Implement configurable Xcode templates (single files with multiple variations based on options during file creation, e.g. single-state scenes vs. multi-state scenes.) 
- Add `Codable` support for components and their `init?(coder aDecoder: NSCoder)` where applicable.
- GitHub Wiki?

### Performance Optimizations

- Replace `Array` with `ContiguousArray` where applicable.

## Outstanding Bugs & Known Issues 

- Sending an array like `[GKComponent.Type]`, such the one at `OctopusComponent.requiredComponents?`, to `entity.componentOrRelay(ofType:)` does not use the actual metatypes, and so it can cause false warnings about missing components.

- Nodes added via an `SKReferenceNode` that is loaded from a scene created in the Xcode Scene Editor, start with their `isPaused` set to `true` until Xcode pauses and resumes the program execution.

- `UITouch.location(in:)` and `UITouch.previousLocation(in:)` are sometimes not updated for many frames, causing a node to "jump" many pixels after 10 or so frames. Same issue with `preciseLocation(in:)` and `precisePreviousLocation(in:)`.

- `UITouch.location(in:)` and `UITouch.preciseLocation(in:)` for a touch "wobbles" when a 2nd touch moves near it, even if the tracked touch is stationary. Seems to be a problem since iOS 11.3 on all devices, in all apps, including system apps like Photos. RADAR: 39997859.

## To Decide

- Shorten the prefix for engine types from "Octopus" to "OK"?
- Use variadic parameters (`...`) instead of arrays in certain places, like `GKEntity.addComponent(_:)`?
- Change `public` access to `open` or `internal`?
- Write standalone documentation for every API unit? (Currently, source comments are the primary API documentation.)
- Write documentation and tutorials for absolute beginners? i.e. people who have no experience with Xcode or Swift?

----

[OctopusKit][repository] © 2018 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html
