// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "get_instance_bridge",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "get-instance-bridge", targets: ["get_instance_bridge"])
    ],
    dependencies: [
        // FlutterFramework 是 Flutter 构建系统在 macos/FlutterFramework/ 生成的本地包。
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // instance_bridge_core 必须作为 Flutter 插件被 symlink 到 .packages/（其 pubspec 声明了
        // flutter.plugin）。插件间 SPM 依赖目前被 Flutter 工具链 bug 阻塞（#188646，修复 PR
        // #188647）：Xcode 会把 `../instance_bridge_core` 按插件真实路径解析，而本地 path 插件
        // 的真实路径下没有该兄弟目录，导致 SPM 解析失败。CocoaPods 为主轨（已验证双平台可构建）；
        // 若需 SPM，需在 macos/ 下放置指向 instance_bridge_core 副本的符号链接。待 Flutter 修复后
        // 此依赖即可直接工作。
        .package(name: "instance_bridge_core", path: "../instance_bridge_core")
    ],
    targets: [
        .target(
            name: "get_instance_bridge",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "instance_bridge_core", package: "instance_bridge_core")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
