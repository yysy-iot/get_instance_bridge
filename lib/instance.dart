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
    if (_status == MixInstanceStatus.dispose) return;
    // 如果实例未初始化，直接标记为 dispose，无需通知原生侧
    if (_status == MixInstanceStatus.none) {
      _status = MixInstanceStatus.dispose;
      return;
    }
    // 如果实例正在加载，等待初始化完成（或失败）
    if (_status == MixInstanceStatus.loading) {
      try {
        await _waitInit();
      } catch (e) {
        // 初始化失败，直接标记为 dispose，跳过原生销毁（原生侧可能未成功创建）
        _status = MixInstanceStatus.dispose;
        return;
      }
    }
    // await 后复查 _status，防止并发 dispose 导致重复销毁
    if (_status == MixInstanceStatus.dispose) return;
    // 实例已加载，执行销毁
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
    // release 模式下 assert 被跳过，需要显式检查
    if (_status == MixInstanceStatus.dispose) {
      return Future.error(StateError('MixInstance $typeName.$method was used after being disposed.'));
    }
    if (_status == MixInstanceStatus.none) {
      await initMixInstance();
    } else {
      await _waitInit();
    }
    // await 后复查 _status，防止 TOCTOU 竞态（await 期间可能被并发 dispose）
    if (_status == MixInstanceStatus.dispose) {
      return Future.error(StateError('MixInstance $typeName.$method was disposed while calling.'));
    }
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
