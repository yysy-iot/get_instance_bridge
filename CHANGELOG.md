## [0.1.4] - 2026-09-11

- 修复 debug 模式下 `cleanCaches` 调用失败导致后续所有 MethodChannel 调用卡住的问题：
  - 构造函数改用 `Future.microtask` + `try-catch`，异常静默忽略（原生端可能未实现 `cleanCaches`）
  - `_synchronized` 等待初始化超时从 120s 缩短为 5s，超时/异常后主动完成 `_initCompleter`，避免后续调用持续等待

## [0.1.3] - 2026-09-10

- 升级 `instance_bridge_core` 至 0.0.17（`^0.0.17` / podspec `~> 0.0.17`），同步 `@Sendable` 协议破坏性变更
- `example/ios/Runner/TestRepository.swift` 的 `MixCallHandler` 闭包补 `@Sendable`
- 移除 example Podfile 中 stale 的 `instance_bridge_core` git 依赖（tag 0.0.8），改用 Flutter symlink 插件源
- 移除 example iOS `project.pbxproj` 中失效的 `get_instance_bridge` SPM 本地包引用（CocoaPods 为主轨）

## [0.1.2] - 2026-09-09

- 升级 `instance_bridge_core` 至 0.0.15（`^0.0.15` / podspec `~> 0.0.15`），含 Swift 6 并发支持：`HashInstance`/`ObjInstance` 标注 `@unchecked Sendable`
- iOS/macOS 构建切换 Swift Package Manager 为主轨（`flutter config --enable-swift-package-manager`），example iOS/macOS SPM 构建验证通过
- SPM 变通：ios/ 与 macos/ 下指向 pub-cache `instance_bridge_core` 副本的符号链接（工具链 #188646 path 依赖 bug），已加入 .gitignore

## [0.1.1] - 2026-09-09

- iOS/macOS 声明 `instance_bridge_core: ^0.0.10` 插件依赖，podspec 保持 `~> 0.0.10`
- iOS/macOS 原生源码迁移到 SwiftPM 风格目录并新增 `Package.swift`（实验性）
- 明确 CocoaPods 为主轨；SPM 插件间 `path` 依赖仍受 Flutter 工具链限制
- 环境要求更新为 `flutter: '>=3.44.0'`

## [0.1.0] - 2026-08-10

### Breaking Changes
- **移除 GetX 依赖**：不再需要 `get` 包
- `MixService` 基类从 `GetxService` 改为 `MixLifecycle`（新增 `lib/service.dart`）
- `CounterReference` 使用内部注册表替代 `GetInstance().putOrFind/find/delete`
- 删除 `export 'package:get/state_manager.dart'`（不再透传 GetX 类型）

### Migration Guide
- 若服务类之前依赖 GetX 其他能力（如 `Get.find()`、`Get.delete()`），
  请改用 `CounterReference.get()` 与 `CounterReference.dispose()`
- `MixService` 仍提供 `onInit()`、`onReady()`、`onClose()` 生命周期方法

## [0.0.4] - 2025-05-03

- feat: macOS 10.15 iOS 13

## [0.0.3] - 2025-05-03

- feat: android open MethodChannel.Result.onError
- feat: remove Decodable<T>

## [0.0.2] - 2025-04-18

- fix: android Unable to respond to MethodChannel.Result.onError issues

## [0.0.1] - 2025-04-16

- Initial release
- Basic instance binding and communication
