import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get_instance_bridge/base.dart';
import 'package:get_instance_bridge/counter_reference.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  late final testRepository = TestRepository();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    testRepository.release();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await Future.delayed(const Duration(seconds: 1));
    final id = await testRepository.id();
    setState(() {
      _platformVersion = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Text('Running on: $_platformVersion\n')),
      ),
    );
  }
}

class TestRepository extends MixService {
  @override
  String get typeName => "TestRepository";

  @override
  get initArguments => "2";

  ///
  factory TestRepository() => CounterReference.get(TestRepository._);
  TestRepository._();

  ///
  void release() => CounterReference.dispose<TestRepository>();

  Future<String> id() => invokeInstanceMethod<String>("id");
}
