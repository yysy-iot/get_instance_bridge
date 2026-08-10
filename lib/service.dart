/// 服务生命周期抽象，替代 GetX 的 GetxService / DisposableInterface。
///
/// 仅保留 GetX 中被实际使用的三个生命周期回调：
/// - [onInit]：初始化（首次获取实例时调用）
/// - [onReady]：就绪（初始化完成后调用）
/// - [onClose]：关闭（引用计数归零销毁时调用）
abstract class MixLifecycle {
  ///
  void onInit() {}

  ///
  void onReady() {}

  ///
  void onClose() {}
}