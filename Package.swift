// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "TelmeSinks",
	products: [
		.library(
			name: "TelmeSinks",
			targets: ["TelmeSinks"]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/vsmbd/swift-core.git",
			branch: "main"
		),
		.package(
			url: "https://github.com/vsmbd/swift-http-core.git",
			branch: "main"
		),
		.package(
			url: "https://github.com/vsmbd/swift-telme.git",
			branch: "main"
		),
		.package(
			url: "https://github.com/vsmbd/swift-json.git",
			branch: "main"
		)
	],
	targets: [
		.target(
			name: "TelmeSinks",
			dependencies: [
				.product(
					name: "SwiftCore",
					package: "swift-core"
				),
				.product(
					name: "HTTPCore",
					package: "swift-http-core"
				),
				.product(
					name: "Telme",
					package: "swift-telme"
				),
				.product(
					name: "JSON",
					package: "swift-json"
				),
			],
			path: "Sources/TelmeSinks"
		),
		.testTarget(
			name: "TelmeSinksTests",
			dependencies: [
				"TelmeSinks",
				.product(name: "JSON", package: "swift-json"),
			],
			path: "Tests/TelmeSinksTests"
		)
	]
)
