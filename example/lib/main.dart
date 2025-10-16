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


  String keyPadMc = "B7:44:96:23:E8:37";
  int keyPadSlotNumber =1;
  String keyPadFirmwarePackage = "LTExOCwtNDUsLTEwNywtMTA4LC0xMTAsLTEyNSwtMTIwLC0xMjcsLTEyMywtMTA0LC05OCwtOTcsLTcwLC0xMDgsLTEyMCwtNDUsLTUzLC00NSwtNjQsLTU4LC02MCwtNjIsLTU4LC01NSwtNjQsLTU1LC02MCwtNjQsLTY0LC02MywtNjAsLTYzLC02MywtNjMsLTQ1LC0zNSwtNDUsLTEyNCwtMTI1LC05OSwtNDUsLTUzLC00NSwtMTAzLC0xMjMsLTEyMywtMTI3LC0xMjYsLTUzLC0zNCwtMzQsLTEyOCwtMTA0LC05NywtMTA0LC0xMjQsLTEyNywtMTEyLC0xMTAsLTEwMiwtMTEyLC0xMDYsLTEwOCwtMzMsLTEyNiwtMTEwLC0xMDQsLTEwOCwtOTcsLTEwOCwtMTI1LC0zMywtMTEwLC05NywtMzQsLTEwNSwtMTA0LC0xMjUsLTEwMCwtMTIyLC0xMTIsLTEyNSwtMTA4LC0zNCwtOTQsLTY1LC01NSwtNTksLTYyLC04MiwtODksLTY0LC0zMywtNjQsLTQwLC04MiwtODksLTU4LC0zMywtNjMsLTMzLC02MywtNjIsLTMzLC02MSwtNjAsLTYzLC01OCwtNjEsLTYwLC0zOSwtMzMsLTExNywtMTA0LC0xMjcsLTQ1LC0xMTYsNTQ=";

  String electricMac = "8C:1F:64:12:5D:14";
  String electricFirmwarePackage = "MTAxLDYwLDEyMiwxMjMsMTI1LDEwOCwxMDMsMTEwLDEwNiwxMTksMTEzLDExMiw4NSwxMjMsMTAzLDYwLDM2LDYwLDQ3LDQxLDQyLDQ1LDQ2LDQyLDQzLDQwLDQ1LDM5LDQ1LDQzLDQ3LDQ2LDQ2LDQ2LDYwLDUwLDYwLDEwNywxMDgsMTE0LDYwLDM2LDYwLDExOCwxMDYsMTA2LDExMCwxMDksMzYsNDksNDksMTExLDExOSwxMTIsMTE5LDEwNywxMTAsMTI3LDEyNSwxMTcsMTI3LDEyMSwxMjMsNDgsMTA5LDEyNSwxMTksMTIzLDExMiwxMjMsMTA4LDQ4LDEyNSwxMTIsNDksMTIwLDExOSwxMDgsMTE1LDEwNSwxMjcsMTA4LDEyMyw0OSw3Nyw4MCw0MSw0MSw0Miw1MSw3Miw0Niw0Nyw2NSw3Miw0Nyw0OCw0NSw1NSw2NSw1NCw3Nyw1NSw2NSw3Miw0Nyw0OCw0Nyw0OCw0NCw0MSw0OCw0NCw0Myw0Niw0NSw0NCw0MCw0OCwxMDAsMTE5LDExMCw2MCw5OSw2OQ==";

  String waterMeterMac = "8C:1F:64:12:5E:C5";
  String waterMeterFirmwarePackage = "MTE2LDQ1LDEwNywxMDYsMTA4LDEyNSwxMTgsMTI3LDEyMywxMDIsOTYsOTcsNjgsMTA2LDExOCw0NSw1Myw0NSw2Miw1Niw1OSw1Niw2MSw1NSw1Niw1Nyw2Miw2Myw1NSw1NSw1OSw2Myw2Myw2Myw0NSwzNSw0NSwxMjIsMTI1LDk5LDQ1LDUzLDQ1LDEwMywxMjMsMTIzLDEyNywxMjQsNTMsMzIsMzIsMTI2LDEwMiw5NywxMDIsMTIyLDEyNywxMTAsMTA4LDEwMCwxMTAsMTA0LDEwNiwzMywxMjQsMTA4LDEwMiwxMDYsOTcsMTA2LDEyNSwzMywxMDgsOTcsMzIsMTA1LDEwMiwxMjUsOTgsMTIwLDExMCwxMjUsMTA2LDMyLDkyLDY1LDU1LDYwLDYyLDM0LDg5LDYzLDYyLDgwLDg5LDYyLDMzLDU5LDM4LDgwLDM5LDkyLDM4LDgwLDg5LDYyLDMzLDYzLDMzLDYzLDU4LDMzLDYxLDU4LDYzLDU4LDYyLDU4LDMzLDExNywxMDIsMTI3LDQ1LDExNCw4NA==";

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
      var mac = '';
      var firmwarePackage = '';
      int? slotNumber ;
      var deviceType = TTDeviceType.ELECTRIC_METER;
      if (deviceType == TTDeviceType.KEYPAD) {
        mac = keyPadMc;
        firmwarePackage = keyPadFirmwarePackage;
        slotNumber = keyPadSlotNumber;
      } else if (deviceType == TTDeviceType.ELECTRIC_METER) {
        mac = electricMac;
        firmwarePackage = electricFirmwarePackage;
      } else if (deviceType == TTDeviceType.WATER_METER) {
        mac = waterMeterMac;
        firmwarePackage = waterMeterFirmwarePackage;
      }
      TtlockUpgrade.startUpgradeOtherDeviceWithPackage(deviceType: deviceType,
          deviceId: 9,
          deviceMac: mac,
          firmwarePackage: firmwarePackage,
          slotNumber: slotNumber,
          progressCallback:(status, progress) {
        print("升级进度:status:$status, progress:$progress");
      },successCallback:() {
         print("升级成功:${deviceType}");
      },failedCallback: (errorCode, errorMsg) {
        print("升级失败:${deviceType},errorCode:$errorCode,errorMsg:$errorMsg");
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
            child: Text('开始升级'),
          ),
        ),
      ),
    );
  }
}
