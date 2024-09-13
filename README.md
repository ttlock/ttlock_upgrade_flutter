# ttlock_upgrade_flutter

## Developers Email list
ttlock-developers-email-list@googlegroups.com

## Lock Upgrade

import 'package:ttlock_upgrade_flutter/ttlock_upgrade.dart';
import 'package:ttlock_flutter/ttlock.dart';


```
//step1   
TtlockUpgrade.startUpgradeLock("lockmac", lockData, "firmwarePackage", (status, progress) {
    }, (String newLockData) {
        print("upgrade success:" + newLockData);

    }, (errorCode, errorMsg) {});

```


## Gateway Upgrade

import 'package:ttlock_upgrade_flutter/ttlock_upgrade.dart';
import 'package:ttlock_flutter/ttlock.dart';
```
TtlockUpgrade.startUpgradeGateway(gatewayMac, firmwarePackage, (status, progress) { }, () {
        print("upgrade success");
     }, (errorCode, errorMsg) { })

```