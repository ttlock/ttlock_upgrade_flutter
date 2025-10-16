import 'dart:async';

import 'package:flutter/services.dart';

enum TTLockUpgradeStatus { preparing, upgrading, recovering }
enum TTLockUpgradeReuslt { success, progress, fail }
enum TTDfuType { net, bluetooth }

enum TTDeviceType {
  WATER_METER,
  ELECTRIC_METER,
  KEYPAD
}

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
typedef TTSuccessCallback = void Function();
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

  static dynamic _upgradeSuccessCallback = () {};

  static TTUpgradeProgressCallback _upgradeProgressCallback =
      (TTLockUpgradeStatus status, int progress) {};

  static Future<String?> get platformVersion async {
    final String? version =
        await _commandChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  static final String START_UPGRADE_OTHER_DEVICE = "startUpgradeOtherDevice";

  static final String START_UPGRADE_OTHER_DEVICE_WITH_PACKAGE = "startUpgradeOtherDeviceWithPackage";

  static final String STOP_UPGRADE_OTHER_DEVICE = "stopUpgradeOtherDevice";

  static startUpgradeLock(
      String lockmac,
      String lockData,
      String firmwarePackage,
      TTUpgradeProgressCallback progressCallback,
      TTUpgradeLockSuccessCallback successCallback,
      TTUpgradeFailedCallback failedCallback) {
    Map map = Map();
    map["lockmac"] = lockmac;
    map["lockData"] = lockData;
    map["firmwarePackage"] = firmwarePackage;
    invoke("startUpgradeLock", map, successCallback, progressCallback,
        failedCallback);
  }

  static stopUpgradeLock() {
    invoke(
        "stopUpgradeLock",
        Map(),
        () {},
        (TTLockUpgradeStatus status, int progress) {},
        (TTLockUpgradeError error, String msg) {});
  }

  static startUpgradeGateway(
      TTDfuType dfuType,
      String clientId,
      String accessToken,
      int gatewayId,
      String gatewayMac,
      TTUpgradeProgressCallback progressCallback,
      TTSuccessCallback successCallback,
      TTUpgradeFailedCallback failedCallback) {
    Map map = Map();
    map["dfuType"] = dfuType;
    map["clientId"] = clientId;
    map["accessToken"] = accessToken;
    map["gatewayId"] = gatewayId;
    map["gatewayMac"] = gatewayMac;
    invoke("startUpgradeGateway", map, successCallback, progressCallback,
        failedCallback);
  }

  static startUpgradeGatewayByFirmwarePackage(
      String firmwarePackage,
      String gatewayMac,
      TTUpgradeProgressCallback progressCallback,
      TTSuccessCallback successCallback,
      TTUpgradeFailedCallback failedCallback) {
    Map map = Map();
    map["firmwarePackage"] = firmwarePackage;
    map["gatewayMac"] = gatewayMac;
    invoke("startUpgradeGatewayByFirmwarePackage", map, successCallback,
        progressCallback, failedCallback);
  }

  static stopUpgradeGateway() {
    invoke(
        "stopUpgradeGateway",
        Map(),
        () {},
        (TTLockUpgradeStatus status, int progress) {},
        (TTLockUpgradeError error, String msg) {});
  }

  static startUpgradeOtherDevice({
        required TTDeviceType deviceType,
        required String clientId,
        required String accessToken,
        required int deviceId,
        required String deviceMac,
        String? lockData,
        int? slotNumber,
        String? featureValue,
        required TTUpgradeProgressCallback progressCallback,
        required TTSuccessCallback successCallback,
        required TTUpgradeFailedCallback failedCallback
  }) {
    Map map = Map();
    map["deviceType"] = deviceType;
    map["clientId"] = clientId.toString();
    map["accessToken"] = accessToken;
    map["deviceId"] = deviceId;
    map["deviceMac"] = deviceMac;
    map["lockData"] = lockData??'';
    map["slotNumber"] = (slotNumber??0).toString();
    map["featureValue"] = featureValue??'';
    invoke(START_UPGRADE_OTHER_DEVICE, map, successCallback, progressCallback,
        failedCallback);
  }

  static startUpgradeOtherDeviceWithPackage({
    required TTDeviceType deviceType,
    required int deviceId,
    required String deviceMac,
    required String firmwarePackage,
    String? lockData,
    int? slotNumber,
    String? featureValue,
    required TTUpgradeProgressCallback progressCallback,
    required TTSuccessCallback successCallback,
    required TTUpgradeFailedCallback failedCallback
  }) {
    Map map = Map();
    map["deviceType"] = deviceType.name;
    map["deviceId"] = deviceId.toString();
    map["deviceMac"] = deviceMac;
    map["firmwarePackage"] = firmwarePackage;
    map["lockData"] = lockData??'';
    map["slotNumber"] = (slotNumber??0).toString();
    map["featureValue"] = featureValue??'';
    invoke(START_UPGRADE_OTHER_DEVICE_WITH_PACKAGE, map, successCallback, progressCallback,
        failedCallback);
  }

  static stopUpgradeOtherDevice() {
    invoke(
        STOP_UPGRADE_OTHER_DEVICE,
        Map(),
        () {},
        (TTLockUpgradeStatus status, int progress) {},
        (TTLockUpgradeError error, String msg) {});
  }




  static bool isListenEvent = false;
  static void invoke(String command, Object? parameter, dynamic success,
      TTUpgradeProgressCallback progress, TTUpgradeFailedCallback fail) {
    if (!isListenEvent) {
      isListenEvent = true;
      _listenChannel
          .receiveBroadcastStream("TTLockUpgradeListen")
          .listen(_onEvent, onError: _onError);
    }
    _upgradeProgressCallback = progress;
    _upgradeFailedCallback = fail;
    _upgradeSuccessCallback = success;
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
    if (command == "startUpgradeLock") {
      TTUpgradeLockSuccessCallback upgradeLockSuccessCallback =
          _upgradeSuccessCallback;
      upgradeLockSuccessCallback(data["lockData"]);
    } else if (command == "startUpgradeGateway"
        || command == "startUpgradeGatewayByFirmwarePackage"
    || command == START_UPGRADE_OTHER_DEVICE
    || command == START_UPGRADE_OTHER_DEVICE_WITH_PACKAGE) {
      _upgradeSuccessCallback();
    }
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
