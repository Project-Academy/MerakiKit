// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MerakiKit",
    platforms: [
        .iOS("17.6"),
        .tvOS("26.0"),
        .macCatalyst(.v18)
    ],
    products: [
        .library(
            name: "Meraki",
            targets: ["Meraki"]
        ),
    ],
    dependencies: [
            .Tapioca
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Meraki",
            dependencies: [
                .Tapioca
            ]
        ),

    ]
)
extension String {
    static let Tapioca = "https://github.com/Project-Academy/Tapioca.git"
}
extension Package.Dependency {
    static var Tapioca: Package.Dependency { .package(url: .Tapioca, from: "1.1.0") }
}
extension Target.Dependency {
    static var Tapioca: Target.Dependency { .product(name: "Tapioca", package: "Tapioca") }
}
