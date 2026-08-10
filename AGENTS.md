# AGENTS.md

Flutter 插件（已发布到 pub.dev，非应用）。核心能力：通过 MethodChannel 在 Dart（GetX）与原生实例（Android Kotlin / iOS+macOS Swift）之间双向绑定通信。

## 仓库结构

- `lib/` — Dart 侧实现。**无 barrel 导出**，各文件独立使用，按需直接 import（如 `package:get_instance_bridge/base.dart`、`counter_reference.dart`）。
- `example/` — 演示应用，通过 `path: ../` 依赖插件。含唯一的 Flutter 测试与可运行的 Android/iOS/macOS 工程。
- `android/` — 完整的原生实现（Kotlin + Moshi），测试在 `android/src/test/kotlin/`。
- `ios/`、`macos/` — **仅薄封装**：Swift 实现全部委托给私有 pod `instance_bridge_core`（`~> 0.0.7`）。这两端的原生行为不在本仓库内，改动需另发该包。

## 架构要点（跨端协议，勿随意改动）

- MethodChannel 名固定为 `"MixInstances"`，硬编码在 Dart `manager.dart` 与 Android `InstancesManager.kt`（iOS 侧在 `instance_bridge_core` 内）。
- 协议方法：`instance`（注册）、`destroy`、`cleanCaches`（仅 debug）、`method.<typeName>.<hashCode>.<methodName>`（业务调用）。
- 方法路由格式 `method.$typeName.$hashCode.$method` 必须保持 Dart / Android / iOS 三端同步；`hashCode` 是跨桥实例标识。
- Dart 侧：`MixService`（= GetxService + MixInstance）、`InstancesManager` 单例、`CounterReference` 为 GetX 服务做引用计数；`Encodable`（`toMap`/`toJsonStr`）对应 Android 的 Moshi JSON 适配。
- `cleanCaches` 仅在 Dart `kDebugMode` 下于 `InstancesManager` 构造时调用；`_synchronized` 也只在 debug 下等待初始化完成。

## 命令

```bash
flutter analyze          # 根包
flutter analyze          # example/ 下另跑一次（example 是独立包）
flutter test             # 在 example/ 下运行（唯一测试是 widget_test）
./gradlew test           # 在 example/android/ 下运行 Kotlin 单测
```

## 已知坑

- `android/src/test/.../GetInstanceBridgePluginTest.kt` 是**过期测试**：调用已不存在的 `GetInstanceBridgePlugin.onMethodCall`（该类现只实现 `FlutterPlugin`），会编译失败。若运行 Android 测试请先处理该文件。
- podspec 版本号（`ios/`、`macos/` 均为 `0.0.2`）与 `pubspec.yaml`（`0.0.4`）不同步，发布时需分别核对。
- 代码注释与提交信息中英混合，新增代码沿用现有风格（中文注释为主）。
- `example/pubspec.lock` 被 git 跟踪；根目录 `.gitignore` 只忽略根 `pubspec.lock`。
- 无 CI、无 opencode 配置、无既有指令文件。