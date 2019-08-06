// swift-tools-version:4.0
import PackageDescription

var package = Package(
    name: "Schrodinger",
    products: [
        .library(name: "Schrodinger", targets: ["Schrodinger"])
    ],
    targets: [
        .target(name: "Schrodinger")
    ]
)
