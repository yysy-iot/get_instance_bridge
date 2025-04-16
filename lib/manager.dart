import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'instance.dart';

class InstancesManager {
  /// Debug
  late final _initCompleter = Completer<void>();

  ///
  late final _cachesMap = <String, MixInstance>{};

  ///
  late final _channel = const MethodChannel("MixInstances")..setMethodCallHandler(_callHandler);

  ///
  static final shared = InstancesManager._();
  InstancesManager._() {
    if (kDebugMode) {
      _channel.invokeMethod("cleanCaches").then((_) => _initCompleter.complete());
    }
  }

  ///
  Future<void> initMixInstance(
    String typeName,
    MixInstance instance,
    dynamic arguments,
  ) {
    final maps = {"typeName": typeName, "hash": instance.hashCode};
    //
    if (arguments != null) maps["arguments"] = arguments;
    //
    return _synchronized(
      () => _channel.invokeMethod("instance", maps),
    ).then(
      (_) {
        final key = _key(typeName, instance.hashCode);
        _cachesMap[key] = instance;
      },
    );
  }

  ///
  Future<void> disposeMixInstance(String typeName, MixInstance instance) => _synchronized(
        () => _channel.invokeMethod(
          "destroy",
          {
            "typeName": typeName,
            "hash": instance.hashCode,
          },
        ),
      ).then(
        (_) {
          final key = _key(typeName, instance.hashCode);
          _cachesMap.remove(key);
        },
      );

  ///
  @optionalTypeArgs
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) => _synchronized(
        () => _channel.invokeMethod<T>(method, arguments),
      ).onError(
        (error, stack) {
          final dynamic obj;
          if (error == null) {
            obj = method;
          } else if (error is PlatformException) {
            final String stacktrace;
            if (error.stacktrace != null) {
              stacktrace = "$method\n${error.stacktrace!}";
            } else {
              stacktrace = method;
            }
            obj = PlatformException(
              code: error.code,
              message: error.message,
              details: error.details,
              stacktrace: stacktrace,
            );
          } else {
            obj = error;
          }
          return Future<T>.error(obj, stack);
        },
      );

  //////////////////////////////////
  ///
  String _key(String typeName, int hashCode) => "$typeName$hashCode";

  ///
  Future _callHandler(MethodCall call) {
    final components = call.method.split(".");
    if (components.length != 4 || components[0] != "method") {
      return Future.error(UnimplementedError(call.method));
    }
    final code = int.tryParse(components[2]);
    if (code == null) {
      return Future.error(UnimplementedError(call.method));
    }
    final key = _key(components[1], code);
    final instance = _cachesMap[key];
    if (instance == null) {
      return Future.error(const StackOverflowError());
    }
    return instance.callHandler(components[3], call.arguments);
  }

  ///
  Future<T> _synchronized<T>(FutureOr<T> Function() computation, {Duration? timeout}) async {
    if (kDebugMode) {
      // 等待初始化完成
      await _initCompleter.future.timeout(const Duration(seconds: 120));
    }
    return await computation();
  }
}
