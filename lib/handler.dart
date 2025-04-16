class NativeMethodHandler<T> {
  final T? Function(dynamic)? asFunc;

  final Future Function(T?) handler;

  NativeMethodHandler._({this.asFunc, required this.handler});

  factory NativeMethodHandler.voidArg(Future Function() handler) =>
      NativeMethodHandler._(
        handler: (_) => handler(),
      );

  factory NativeMethodHandler.instance(Future Function(T) handler,
          [T? Function(dynamic)? asFunc]) =>
      NativeMethodHandler._(
        asFunc: asFunc,
        handler: (value) => value != null
            ? handler(value)
            : Future.error("no such arguments type error"),
      );

  factory NativeMethodHandler.optional(Future Function(T?) handler,
          [T? Function(dynamic)? asFunc]) =>
      NativeMethodHandler._(
        asFunc: asFunc,
        handler: handler,
      );

  Future callHandler(dynamic arguments) {
    final value = asFunc != null ? asFunc!(arguments) : arguments;
    return handler(value);
  }
}
