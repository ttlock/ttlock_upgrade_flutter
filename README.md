# ttlock_upgrade_flutter

## Developers Email list
ttlock-developers-email-list@googlegroups.com

## Lock Upgrade

import 'package:ttlock_upgrade_flutter/ttlock_upgrade.dart';
import 'package:ttlock_flutter/ttlock.dart';


```
//step1   
TTLock.setLockEnterUpgradeMode(lockData, () {
    print("Set lock enter upgrade mode success");

    //step2
    TtlockUpgrade.startUpgradeLock("lockmac", lockData, "firmwarePackage", (status, progress) {
    
    }, () {
        print("upgrade success");

        //step3
        TTLock.getLockSystemInfo(lockData, (lockSystemInfoModel) {
          //upload new lockData from lockSystemInfoModel.lockData to your server
        }, (errorCode, errorMsg) { });

    }, (errorCode, errorMsg) {});

}, (errorCode, errorMsg) {});

```


## Gateway Upgrade

import 'package:ttlock_upgrade_flutter/ttlock_upgrade.dart';
import 'package:ttlock_flutter/ttlock.dart';
```
//step1   
TTGateway.setGatewayEnterUpgradeMode(mac, () {

    //step2   
    TtlockUpgrade.startUpgradeGateway(gatewayMac, firmwarePackage, (status, progress) { }, () {
        print("upgrade success");
     }, (errorCode, errorMsg) { })
 }, (errorCode, errorMsg) { })

```