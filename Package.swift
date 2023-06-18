// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

//  https://github.com/InvadingOctopus/octopuskit

import PackageDescription

let package = Package(
    name: "OctopusKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "OctopusKit",
            targets: ["OctopusKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OctopusKit",
            dependencies: [],
            exclude: [
                "Apple API Extensions/SwiftUI/OctopusUI.md"],
            resources: [
                .copy("Assets/Shaders/ShaderKit/LICENSE")]
//          , swiftSettings: [                // MARK: - Conditional Compilation Flags
//                .define("LOGECSVERBOSE"),   // Log detailed ECS core events. ⚠️ May decrease performance.
//                .define("LOGECSDEBUG"),     // Log ECS debugging info. ⚠️ Will decrease performance.
//                .define("LOGCHANGES"),      // Enables the `@LogChanges` property wrapper and other value logging. ⚠️ May decrease performance.
//                .define("LOGINPUTEVENTS"),  // Log detailed mouse/touch/pointer input events. ⚠️ May decrease performance.
//                .define("LOGPHYSICS"),      // Log physics contact/collision events. ⚠️ May decrease performance.
//                .define("LOGTURNBASED")     // Log each begin/update/end cycle for turn-based components. ⚠️ May decrease performance.
//            ]                               // Remember to uncomment this if you uncomment any of the lines above ^^
        ),
        .testTarget(
            name: "OctopusKitTests",
            dependencies: ["OctopusKit"]),
    ],
    swiftLanguageVersions: [.v5]
)

