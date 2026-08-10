import 'package:flutter/foundation.dart';
import 'handler.dart';
import 'instance.dart';
import 'service.dart';
export 'instance.dart';
export 'service.dart';

///
/// 服务基类，替代原 GetX 版本（原继承 GetxService）。
///
/// 提供：
/// - [MixInstance] 桥接能力（原生实例双向绑定）
/// - 生命周期管理（[onInit]/[onReady]/[onClose]）
/// - 自动初始化/销毁 Mix 实例
abstract class MixService extends MixLifecycle with MixInstance, _MixDisposable {
  @mustCallSuper
  @override
  void onClose() {
    super.onClose();
    disposeMixInstance();
  }

  @override
  Map<String, NativeMethodHandler> get methodHandler => throw UnimplementedError();
}

///
mixin _MixDisposable on MixLifecycle, MixInstance {
  @override
  get initArguments => null;

  @override
  void onInit() {
    initMixInstance();
    super.onInit();
  }
}
