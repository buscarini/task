// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "Task",
  products: [
    .library(name: "Task", targets: ["Task"]),
    ],
	dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-nonempty.git", from: "0.1.2"),
    ],
  targets: [
    .target(name: "Task", dependencies: ["NonEmpty"]),
    .testTarget(name: "TaskTests", dependencies: ["Task", "NonEmpty"]),
    ],
   swiftLanguageVersions: [.v4_2]
)
