import 'service.dart';

/// 带引用计数的服务包装器。
///
/// 替代原 GetX 版本：使用内部注册表（[CounterReference] 静态持有）
/// 替代 GetX 的 `GetInstance().putOrFind/find/delete`，不依赖任何外部 DI 容器。
class CounterReference<T extends MixLifecycle> extends MixLifecycle {
  int _refCount = 0;
  final T _reference;

  CounterReference._(this._reference);

  @override
  void onInit() {
    super.onInit();
    _reference.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _reference.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _reference.onClose();
  }

  // ─── 自建注册表（替代 GetInstance()） ───

  /// 注册表：key(类型+tag) -> CounterReference 实例
  static final Map<_RegistryKey, CounterReference> _registry = {};

  ///
  static T get<T extends MixLifecycle>(T Function() constructor) =>
      _get(constructor);

  ///
  static T getWith<T extends MixLifecycle>(
    String argv,
    T Function(String) constructor,
  ) =>
      _get(
        () => constructor(argv),
        argv,
      );

  ///
  static T _get<T extends MixLifecycle>(
    T Function() constructor, [
    String? tag,
  ]) {
    final key = _RegistryKey(T, tag);
    final counter = _registry.putIfAbsent(
      key,
      () {
        final c = CounterReference<T>._(constructor());
        // 首次创建时驱动生命周期
        // onInit 同步调用（对应 GetX putOrFind 的 onInit）
        c.onInit();
        // onReady 延迟到下一个 microtask，更接近 GetX 的异步延迟语义
        // 避免用户在 onReady 中依赖 onInit 的异步操作（如 initMixInstance）已完成
        Future.microtask(() => c.onReady());
        return c;
      },
    );
    counter._refCount += 1;
    return (counter as CounterReference<T>)._reference;
  }

  ///
  static void dispose<T extends MixLifecycle>([String? tag]) {
    final key = _RegistryKey(T, tag);
    final counter = _registry[key];
    if (counter == null) return;
    counter._refCount -= 1;
    if (counter._refCount <= 0) {
      _registry.remove(key);
      counter.onClose();
    }
  }

  ///
  static void cleanCaches() {
    for (final counter in _registry.values) {
      counter.onClose();
    }
    _registry.clear();
  }
}

/// 注册表 key：类型 + 可选 tag
class _RegistryKey {
  final Type type;
  final String? tag;

  _RegistryKey(this.type, [this.tag]);

  @override
  bool operator ==(Object other) =>
      other is _RegistryKey && other.type == type && other.tag == tag;

  @override
  int get hashCode => Object.hash(type, tag);
}
