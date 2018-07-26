---
permalink: documentation/conventions.html
---

# OctopusKit Coding Conventions & Design Decisions

[TODO: Revise this page]

[Developer Diary](#developer-diary)  
[Comments Key](#comments-key)

- Git workflow: [http://nvie.com/posts/a-successful-git-branching-model/](http://nvie.com/posts/a-successful-git-branching-model/)

- OctopusKit types are prefixed with the word "Octopus" instead of "OK" because I liked it that way, and it saved me from a lot of refactoring when I had to change the name of the engine a few times.

- Classes are marked `final` where possible to improve performance. If you need to subclass them in a specific project, you could create a copy of the class (or entire engine source) and modify it to suit your project. See: [Increasing Performance by Reducing Dynamic Dispatch](https://developer.apple.com/swift/blog/?id=27)

- When checking a list of conditions in a single `if` or `guard`, check the condition that is the most likely to change each time, without which the operation will not continue, and the conditions that will most likely pass should be checked last, so that you save processing time by exiting early in the checklist instead of later.
	> In some cases however, it may be best to check the most important condition first. :)

- There are almost no `private` properties and methods in the OctopusKit API, so that you can observe almost everything at runtime, or customize in subclasses. Some may be read-only, however.

- Sometimes a type may have both type methods and instance methods for the same operations, like the `CGFloat+OctopusKit` extension with `distance(between:and:)` and `distance(to:)?` It may usually be more natural to write `distance = CGPoint.distance(between: a, and: b)` than `distance = a.distance(to: b)`, but it wouldn't do to make that method available only on the type and not on instances, so OK provides both. However, to reduce duplication of code, the instance methods are the "primary" code (to improve performance by reducing extra calls, because calling these methods on an instance may be more "idiomatic") and the type methods call the instance versions.

- `for each x in y` may be cleaner and self-explanatory compared to `y.forEach { x in ... }` or `$0.z` in most cases.

- In subclasses, try to prefix properties with `super.` or `self.` if there might be any ambiguity at the use site about where the property is defined.
    > [TODO: example]

- Say "player" instead of "user" whenever referring to the person playing the game. (^ - ^")

## Developer Diary

- Trying to implement Scene Editor support for components via `@GKInspectable` seems like a waste of effort, as the editor does not show inspectable properties from a component's superclass. 2018-04-18

## Comments Key

- ℹ️ / DESIGN: A design decision or note.
- ⚠️ A warning about potential undesirable behavior, or a workaround for an undesirable situation that was avoided or fixed. 
- 💬 General commentary/observations.
- PERFORMANCE: Related to speed/efficiency/optimization.

----

[OctopusKit][repository] © 2018 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html
