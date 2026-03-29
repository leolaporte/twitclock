// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TwitClock",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "TwitClock",
            path: "Sources/TwitClock"
        )
    ]
)
