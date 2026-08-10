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
