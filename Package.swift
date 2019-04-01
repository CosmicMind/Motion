// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Motion",
    // platforms: [.iOS("8.0")],
    products: [
        .library(name: "Motion", targets: ["Motion"])
    ],
    targets: [
        .target(
            name: "Motion",
            path: "Sources"
        )
    ]
)
