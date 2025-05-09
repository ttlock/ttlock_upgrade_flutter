package com.ttlock.upgrade.ttlock_upgrade_flutter.constant;

public class Command {
    public static final String METHOD_CHANNEL_NAME = "com.ttlock/command/upgrade";
    public static final String EVENT_CHANNEL_NAME = "com.ttlock/listen/upgrade";
    
    public static final String START_UPGRADE = "startUpgradeLock";
    public static final String STOP_UPGRADE = "stopUpgradeLock";

    public static final String START_UPGRADE_GATEWAY = "startUpgradeGateway";

    public static final String STOP_UPGRADE_GATEWAY = "stopUpgradeGateway";

    public static final String START_UPGRADE_GATEWAY_BY_FIRMWARE_PACKAGE = "startUpgradeGatewayByFirmwarePackage";

}
