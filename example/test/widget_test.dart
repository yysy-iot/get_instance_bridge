// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:get_instance_bridge_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Verify Platform version', (WidgetTester tester) async {
    // 设置 MethodChannel mock 处理器，模拟原生侧响应
    const String channelName = 'MixInstances';
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel(channelName),
      (MethodCall methodCall) async {
        if (methodCall.method == 'cleanCaches') return 0;
        if (methodCall.method == 'instance') return 0;
        // 匹配 method.<typeName>.<hashCode>.<methodName> 格式
        if (methodCall.method.startsWith('method.')) {
          return 'mock-id-${methodCall.method}';
        }
        return null;
      },
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // 推进 Future.delayed(1s) 定时器并完成异步操作
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text &&
                           widget.data!.startsWith('Running on:'),
      ),
      findsOneWidget,
    );
  });
}
