// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Task",
	products: [
		.library(name: "Task", targets: ["Task"]),
	],
	dependencies: [
		.package(
			name: "NonEmpty",
			url: "https://github.com/pointfreeco/swift-nonempty.git",
			from: "0.2.2"
		)
	],
	targets: [
		.target(
			name: "Task",
			dependencies: [
				"NonEmpty"
			]),
		.testTarget(
			name: "TaskTests",
			dependencies: [
				"Task",
				"NonEmpty"
			]),
	]
)
