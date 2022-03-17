import 'dart:async';

import 'package:flutter/services.dart';

enum TTLockUpgradeStatus { preparing, upgrading, recovering }
enum TTLockUpgradeReuslt { success, progress, fail }

enum TTLockUpgradeError {
  success,
  peripheralPoweredOff,
  connectTimeout,
  netFail,
  noNeedUpgrade,
  unknownUpgradeVersion,
  enterUpgradeState,
  upgradeLockFail,
  preparingError,
  getSpecialValueError,
  upgradeFail
}

typedef TTUpgradeLockSuccessCallback = void Function(String lockData);
typedef TTUpgradeFailedCallback = void Function(
    TTLockUpgradeError errorCode, String errorMsg);
typedef TTUpgradeProgressCallback = void Function(
    TTLockUpgradeStatus status, int progress);

class TtlockUpgrade {
  static const MethodChannel _commandChannel =
      const MethodChannel('com.ttlock/command/upgrade');
  static EventChannel _listenChannel =
      EventChannel("com.ttlock/listen/upgrade");

  static TTUpgradeFailedCallback _upgradeFailedCallback =
      (TTLockUpgradeError errorCode, String errorMessage) {};

  static TTUpgradeLockSuccessCallback _upgradeLockSuccessCallback =
      (String lockData) {};
  static TTUpgradeProgressCallback _upgradeProgressCallback =
      (TTLockUpgradeStatus status, int progress) {};

  static Future<String?> get platformVersion async {
    final String? version =
        await _commandChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  static startUpgradeLock(
      String lockData,
      String firmwarePackage,
      TTUpgradeProgressCallback progressCallback,
      TTUpgradeLockSuccessCallback successCallback,
      TTUpgradeFailedCallback failedCallback) {
    Map map = Map();
    map["lockData"] = lockData;
    map["firmwarePackage"] = firmwarePackage;
    invoke("startUpgradeLock", map, successCallback, progressCallback,
        failedCallback);
  }

  static stopUpgradeLock() {
    invoke(
        "stopUpgradeLock",
        Map(),
        (String lockData) {},
        (TTLockUpgradeStatus status, int progress) {},
        (TTLockUpgradeError error, String msg) {});
  }

  static bool isListenEvent = false;
  static void invoke(
      String command,
      Object? parameter,
      TTUpgradeLockSuccessCallback success,
      TTUpgradeProgressCallback progress,
      TTUpgradeFailedCallback fail) {
    if (!isListenEvent) {
      isListenEvent = true;
      _listenChannel
          .receiveBroadcastStream("TTLockUpgradeListen")
          .listen(_onEvent, onError: _onError);
    }
    _upgradeProgressCallback = progress;
    _upgradeLockSuccessCallback = success;
    _upgradeFailedCallback = fail;

    _commandChannel.invokeListMethod(command, parameter);
  }

// 数据接收
  static void _onEvent(dynamic value) {
    print('TTLock listen: $value');

    Map map = value;
    String command = map["command"];
    Map data = map["data"] == null ? {} : map["data"];
    int resultState = map["resultState"];

    if (resultState == TTLockUpgradeReuslt.fail.index) {
      int errorCode = map["errorCode"];
      String errorMessage =
          map["errorMessage"] == null ? "" : map["errorMessage"];
      _errorCallback(command, errorCode, errorMessage);
    } else if (resultState == TTLockUpgradeReuslt.progress.index) {
      //中间状态的回调（��加 IC卡、指��）
      _progressCallback(command, data);
    } else {
      //成功的回调
      _successCallback(command, data);
    }
  }

  // 错误处理
  static void _onError(Object value) {
    print('TTLockUpgradePlugin Error: $value');
  }

  static void _successCallback(String command, Map data) {
    _upgradeLockSuccessCallback(data["lockData"]);
  }

  static void _progressCallback(String command, Map data) {
    TTLockUpgradeStatus status = TTLockUpgradeStatus.values[data["status"]];
    int progress = data["progress"] == null ? 0 : data["progress"];
    _upgradeProgressCallback(status, progress);
  }

  static void _errorCallback(
      String command, int errorCode, String errorMessage) {
    _upgradeFailedCallback(TTLockUpgradeError.values[errorCode], errorMessage);
  }
}
