import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ttlock_upgrade_flutter/ttlock_upgrade.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
   // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      print("开始升级2222");
      TtlockUpgrade.startUpgradeLock("lockmac", "lockData", "firmwarePackage",
          (status, progress) {
        // print("升级进度");
        // print(status);
        // print(progress);
      }, (String newLockData) {
        // print("升级返回成功");
      }, (errorCode, errorMsg) {
        // print("升级失败");
        // print(errorCode);
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: GestureDetector(
            onTap: (){
              initPlatformState();
            },
            child: Text('Running on: $_platformVersion\n'),
          ),
        ),
      ),
    );
  }
}
