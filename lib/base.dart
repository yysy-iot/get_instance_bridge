// import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/foundation.dart';
import 'handler.dart';
import 'instance.dart';
export 'instance.dart';

///
abstract class MixService extends GetxService with MixInstance, _MixDisposable {
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
mixin _MixDisposable on DisposableInterface, MixInstance {
  @override
  get initArguments => null;

  @override
  void onInit() {
    initMixInstance();
    super.onInit();
  }
}
