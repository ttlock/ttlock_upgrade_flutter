package com.ttlock.upgrade.ttlock_upgrade_flutter;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.ttlock.bl.sdk.api.LockDfuClient;
import com.ttlock.bl.sdk.api.TTLockClient;
import com.ttlock.bl.sdk.callback.DfuCallback;
import com.ttlock.bl.sdk.callback.GetLockSystemInfoCallback;
import com.ttlock.bl.sdk.constant.Constant;
import com.ttlock.bl.sdk.entity.DeviceInfo;
import com.ttlock.bl.sdk.entity.LockError;
import com.ttlock.bl.sdk.util.DigitUtil;
import com.ttlock.bl.sdk.util.LogUtil;
import com.ttlock.upgrade.ttlock_upgrade_flutter.constant.Command;
import com.ttlock.upgrade.ttlock_upgrade_flutter.constant.Field;
import com.ttlock.upgrade.ttlock_upgrade_flutter.model.TTLockUpgradeError;
import com.ttlock.upgrade.ttlock_upgrade_flutter.model.TTLockUpgradeStatus;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** TtlockUpgradeFlutterPlugin */
public class TtlockUpgradeFlutterPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private EventChannel eventChannel;

  private EventChannel.EventSink events;

  private Map<String, String> params;

  private Context context;

  public static final int ResultStateSuccess = 0;
  public static final int ResultStateProgress = 1;
  public static final int ResultStateFail = 2;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), Command.METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    eventChannel = new EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), Command.EVENT_CHANNEL_NAME);
    eventChannel.setStreamHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    TTLockClient.getDefault().prepareBTService(context);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//    if (call.method.equals("getPlatformVersion")) {
//      result.success("Android " + android.os.Build.VERSION.RELEASE);
//    } else {
////      result.notImplemented();
//    }
    params = (Map<String, String>) call.arguments;
    switch (call.method) {
      case Command.START_UPGRADE:
          startUpgrade();
        break;
      case Command.STOP_UPGRADE:
          stopUpgrade();
        break;
    }
  }

  private void startUpgrade() {
//    ("E0:6B:FA:67:CC:09", "lockData", "MTEyLDQxLDExMSwxMTAsMTA0LDEyMSwxMTQsMTIzLDEyNyw5OCwxMDAsMTAxLDY0LDExMCwxMTQsNDEsNDksNDEsNTgsNjEsNjMsNjIsNjIsNTEsNTksNTcsNjMsNTYsNTAsNjEsNTksNTksNTksNTksNDEsMzksNDEsMTI2LDEyMSwxMDMsNDEsNDksNDEsOTksMTI3LDEyNywxMjMsNDksMzYsMzYsMTIyLDk4LDEwMSw5OCwxMjYsMTIzLDEwNiwxMDQsOTYsMTA2LDEwOCwxMTAsMzcsMTIwLDEwNCw5OCwxMTAsMTAxLDExMCwxMjEsMzcsMTA0LDEwMSwzNiwxMDksOTgsMTIxLDEwMiwxMjQsMTA2LDEyMSwxMTAsMzYsODgsNjksODQsNTAsNTgsNTYsNTAsMzUsODgsNTcsNTksNTcsNzcsODQsODgsNjksNTAsNTgsNTYsNTAsMzgsNjYsNjksOTUsMzQsMzUsODgsMzQsODQsNjEsMzcsNjMsMzcsNTgsNTgsMzcsNTcsNTcsNTksNTcsNTksNjEsMzcsMTA1LDk4LDEwMSw0MSwxMTgsMTAx",
//    String lockData = "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\n";
//    params.put(Field.LOCK_DATA, lockData);
    LockDfuClient.getDefault().startDfu(context, params.get(Field.LOCK_DATA), params.get(Field.LOCK_MAC), params.get(Field.FIRMWARE_PACKAGE), new DfuCallback() {
      @Override
      public void onDfuSuccess(String deviceAddress) {
          getLockSysInfo(params.get(Field.LOCK_DATA), params.get(Field.LOCK_MAC));
      }

      @Override
      public void onStatusChanged(int status) {

      }

      @Override
      public void onDfuAborted(String deviceAddress) {

      }

      @Override
      public void onProgressChanged(String deviceAddress, int percent, float speed, float avgSpeed, int currentPart, int partsTotal) {
        Map<String, Object> data = new HashMap<>();
        data.put("status", TTLockUpgradeStatus.upgrading.ordinal());
        data.put("progress", percent);
        progressCallbackCommand(Command.START_UPGRADE, data);
      }

      @Override
      public void onError(int errorCode, String errorContent) {
          errorCallbackCommand(Command.START_UPGRADE, TTLockUpgradeError.upgradeFail.ordinal(), errorContent);
      }
    });
  }

  private void getLockSysInfo(final String lockData, final String lockMac) {
      new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
        @Override
        public void run() {
           TTLockClient.getDefault().getLockSystemInfo(lockData, lockMac, new GetLockSystemInfoCallback() {
             @Override
             public void onGetLockSystemInfoSuccess(DeviceInfo deviceInfo) {
               Map<String, String> data = new HashMap<>();
               data.put("lockData", deviceInfo.getLockData());
               successCallbackCommand(Command.START_UPGRADE, data);
             }

             @Override
             public void onFail(LockError lockError) {
                errorCallbackCommand(Command.START_UPGRADE, TTLockUpgradeError.getSpecialValueError.ordinal(), lockError.getErrorMsg());
             }
           });
        }
      }, 3000);
  }

  private void stopUpgrade() {
    LockDfuClient.getDefault().abortDfu();
    successCallbackCommand(Command.STOP_UPGRADE, new HashMap());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    this.events = events;
  }

  @Override
  public void onCancel(Object arguments) {

  }

  public void successCallbackCommand(String command, Map data) {
    HashMap<String, Object> resultMap = new HashMap<>();
    resultMap.put("command", command);
    resultMap.put("resultState", ResultStateSuccess);
    resultMap.put("data", data);
    events.success(resultMap);
  }

  public void progressCallbackCommand(String command, Map data) {
    HashMap<String, Object> resultMap = new HashMap<>();
    resultMap.put("command", command);
    resultMap.put("resultState", ResultStateProgress);
    resultMap.put("data", data);
    events.success(resultMap);
  }

  public void errorCallbackCommand(String command, int errorCode, String errorMessage) {
    HashMap<String, Object> resultMap = new HashMap<>();
    resultMap.put("command", command);
    resultMap.put("resultState", ResultStateFail);
    resultMap.put("errorCode", errorCode);
    resultMap.put("errorMessage", errorMessage);
    events.success(resultMap);
  }


}
