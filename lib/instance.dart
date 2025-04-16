import 'dart:async';
import 'package:flutter/foundation.dart';
import 'codable.dart';
import 'handler.dart';
import 'manager.dart';

enum MixInstanceStatus { none, loading, loaded, dispose }

mixin MixInstance {
  ///
  Completer<void>? _initCompleter;
  InstancesManager get _manager => InstancesManager.shared;

  ///
  late MixInstanceStatus _status = MixInstanceStatus.none;
  MixInstanceStatus get status => _status;

  ///
  String get typeName;

  ///
  Map<String, NativeMethodHandler> get methodHandler;

  ///
  dynamic get initArguments;

  ///
  @protected
  @mustCallSuper
  Future<void> initMixInstance() async {
    if (_status != MixInstanceStatus.none) return;
    _status = MixInstanceStatus.loading;
    _initCompleter = Completer<void>();
    try {
      await _manager.initMixInstance(
        typeName,
        this,
        initArguments,
      );
      _status = MixInstanceStatus.loaded;
      _initCompleter?.complete();
    } catch (e) {
      _status = MixInstanceStatus.none;
      _initCompleter?.completeError(e);
    } finally {
      _initCompleter = null;
    }
  }

  ///
  @protected
  @mustCallSuper
  Future<void> disposeMixInstance() async {
    assert(_status != MixInstanceStatus.dispose,
        'Once you have called dispose() on a MixInstance $typeName, it can no longer be used.');
    //  'Once you have called dispose() on a MixInstance $typeName, it can no longer be used.');
    if (_status == MixInstanceStatus.dispose) return;
    //  if the instance is not loaded, we can dispose it immediately
    if (_status == MixInstanceStatus.none) {
      _status = MixInstanceStatus.dispose;
      return;
    }
    // if the instance is loading, we need to wait for it to finish loading
    await _waitInit();
    // if the instance is loaded, we can dispose it
    _status = MixInstanceStatus.dispose;
    await _manager.disposeMixInstance(
      typeName,
      this,
    );
  }

  /////////////////////////////////////////////////////////////////////////////////
  ///
  Future callHandler(String method, dynamic arguments) {
    final handler = methodHandler[method];
    if (handler == null) {
      return Future.error(
        NoSuchMethodError.withInvocation(
          this,
          Invocation.method(Symbol(method), arguments),
        ),
      );
    }
    return handler.callHandler(arguments);
  }

  /////////////////////////////////////////////////////////////////////////////////

  ///
  Future<T?> _invokeMethod<T>(String method, dynamic arguments) async {
    assert(_status != MixInstanceStatus.dispose, 'MixInstance $typeName $method was used after being disposed.');
    //
    if (_status == MixInstanceStatus.none) {
      await initMixInstance();
    } else {
      await _waitInit();
    }
    //
    final argv = arguments is Encodable ? arguments.toMap() : arguments;
    final methodNameStr = "method.$typeName.$hashCode.$method";
    return await _manager.invokeMethod<T>(
      methodNameStr,
      argv,
    );
  }

  ///
  Future<void> _waitInit() async {
    final completer = _initCompleter;
    if (completer != null) {
      await completer.future;
    }
  }
}

extension MixInstanceInvoke on MixInstance {
  @protected
  Future<Map<K, V>> invokeMapMethod<K, V>(String method, {dynamic arguments}) async {
    final value = await invokeOptionalMapMethod<K, V>(
      method,
      arguments: arguments,
    );
    if (value != null) {
      return value;
    } else {
      throw ArgumentError.notNull("$method result");
    }
  }

  @protected
  Future<List<T>> invokeListMethod<T>(String method, {dynamic arguments}) async {
    final value = await invokeOptionalListMethod<T>(
      method,
      arguments: arguments,
    );
    if (value != null) {
      return value;
    } else {
      throw ArgumentError.notNull("$method result");
    }
  }

  @protected
  Future<List<T>?> invokeOptionalListMethod<T>(String method, {dynamic arguments}) async {
    final List<dynamic>? result = await _invokeMethod<List<dynamic>>(
      method,
      arguments,
    );
    return result?.cast<T>();
  }

  @protected
  Future<Map<K, V>?> invokeOptionalMapMethod<K, V>(String method, {dynamic arguments}) async {
    final Map<dynamic, dynamic>? result = await _invokeMethod<Map<dynamic, dynamic>>(
      method,
      arguments,
    );
    return result?.cast<K, V>();
  }

  ///
  @protected
  Future<T> invokeInstanceMethod<T>(String method, {dynamic arguments}) async {
    final value = await _invokeMethod<T>(method, arguments);
    if (value != null) {
      return value;
    } else {
      throw ArgumentError.notNull("$method result");
    }
  }

  ///
  @protected
  Future<T?> invokeOptionalMethod<T>(String method, {dynamic arguments}) => _invokeMethod<T>(method, arguments);

  ///
  @protected
  Future<void> invokeVoidMethod(String method, {dynamic arguments}) async {
    await _invokeMethod<int?>(method, arguments);
  }
}
