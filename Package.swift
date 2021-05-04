// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Task",
	products: [
		.library(name: "Task", targets: ["Task"]),
	],
	dependencies: [
		.package(
			name: "swift-nonempty",
			url: "https://github.com/pointfreeco/swift-nonempty.git",
			from: "0.3.1"
		)
	],
	targets: [
		.target(
			name: "Task",
			dependencies: [
				.product(name: "NonEmpty", package: "swift-nonempty")
			]),
		.testTarget(
			name: "TaskTests",
			dependencies: [
				"Task",
				.product(name: "NonEmpty", package: "swift-nonempty")
			]),
	]
)
