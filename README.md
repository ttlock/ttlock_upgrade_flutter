# ttlock_upgrade_flutter

## Developers Email list
ttlock-developers-email-list@googlegroups.com

## Lock Upgrade

import 'package:ttlock_upgrade_flutter/ttlock_upgrade.dart';


```
 TtlockUpgrade.startUpgradeLock(lockMac, lockData, firmwarePackage, (status, progress) {
        print(status);
        print(progress);
    }, (String newLockData) {
        print("upgrade success");
    }, (errorCode, errorMsg) {});

```


## Gateway Upgrade

import 'package:ttlock_upgrade_flutter/ttlock_upgrade.dart';

```
TtlockUpgrade.startUpgradeGateway(clientId, accessToken, gatewayId, gatewayMac, (status, progress) { 
        print(status);
        print(progress);
    }, () {
        print("upgrade success");
}, (errorCode, errorMsg) { })

```