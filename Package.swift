// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BingPaper",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "BingPaper",
            targets: ["BingPaper"]
        )
    ],
    targets: [
        .executableTarget(
            name: "BingPaper",
            path: "Sources/BingPaper"
        )
    ]
)
