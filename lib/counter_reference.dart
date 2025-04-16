import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
export 'package:get/state_manager.dart';

class CounterReference<T extends GetxService> extends GetxService {
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

  ///
  static T get<T extends GetxService>(T Function() constructor) =>
      _get(constructor);

  ///
  static T getWith<T extends GetxService>(
    String argv,
    T Function(String) constructor,
  ) =>
      _get(
        () => constructor(argv),
        argv,
      );

  ///
  static T _get<T extends GetxService>(
    T Function() constructor, [
    String? tag,
  ]) {
    final manager = GetInstance();
    final counter = manager.putOrFind<CounterReference<T>>(
      () => CounterReference<T>._(
        constructor(),
      ),
      tag: tag,
    );
    counter._refCount += 1;
    return counter._reference;
  }

  static void dispose<T extends GetxService>([String? tag]) {
    final manager = GetInstance();
    try {
      final counter = manager.find<CounterReference<T>>(tag: tag);
      if (--counter._refCount == 0) {
        GetInstance().delete<CounterReference<T>>(tag: tag, force: true);
      }
      // ignore: empty_catches
    } catch (e) {}
  }
}
