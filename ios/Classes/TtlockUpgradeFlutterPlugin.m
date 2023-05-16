#import "TtlockUpgradeFlutterPlugin.h"
#import <TTLockDFUOnPremise/TTLockDFUOnPremise.h>



@interface TtlockUpgradeFlutterPlugin() <FlutterStreamHandler>

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation TtlockUpgradeFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    //1.初始化接收对象
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.ttlock/command/upgrade"
                                     binaryMessenger:[registrar messenger]];
    TtlockUpgradeFlutterPlugin* instance = [[TtlockUpgradeFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    
    //2.初始化发送对象
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"com.ttlock/listen/upgrade" binaryMessenger:registrar.messenger];
    [eventChannel setStreamHandler:[self sharedInstance]];
}


+ (instancetype)sharedInstance{
    static TtlockUpgradeFlutterPlugin *instance = nil;
    if (!instance) {
        instance = [[self alloc] init];
    }
    return instance;
}




- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else if ([@"startUpgradeLock" isEqualToString:call.method]){
        
        NSDictionary *dict = call.arguments;
        NSString *lockData = dict[@"lockData"];
        NSString *firmwarePackage = dict[@"firmwarePackage"];
        
        [[TTLockDFUOnPremise shareInstance] startDfuWithFirmwarePackage:firmwarePackage lockData:lockData successBlock:^(UpgradeOpration type, NSInteger progress) {
            if (type == UpgradeOprationSuccess) {
                [self callbackCommand:call.method resultCode:0 data:dict errorCode:0 errorMessage:nil];
            }else{
                NSMutableDictionary *dict = [NSMutableDictionary new];
                dict[@"status"] = @(type);
                dict[@"progress"] = @(progress);
                [self callbackCommand:call.method resultCode:1 data:dict errorCode:0 errorMessage:nil];
            }
            
        } failBlock:^(UpgradeOpration type, UpgradeErrorCode code) {
            [self callbackCommand:call.method resultCode:2 data:dict errorCode:code - 1 errorMessage:nil];
        }];
    }else if ([@"startUpgradeGateway" isEqualToString:call.method]){
        NSDictionary *dict = call.arguments;
        NSString *gatewayMac = dict[@"gatewayMac"];
        NSString *accessToken = dict[@"accessToken"];
        NSString *clientId = dict[@"clientId"];
        NSNumber *gatewayId = dict[@"gatewayId"];
        
        
       
    }else if ([@"stopUpgradeLock" isEqualToString:call.method]){
        [[TTLockDFUOnPremise shareInstance] endUpgrade];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)callbackCommand:(NSString *)command  resultCode:(NSInteger) resultState data:(NSObject *)data errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage {
    NSMutableDictionary *resultDict = @{}.mutableCopy;
    resultDict[@"command"] = command;
    resultDict[@"errorMessage"] = errorMessage;
    resultDict[@"errorCode"] = @(errorCode);
    resultDict[@"resultState"] = @(resultState);
    resultDict[@"data"] = data;
    
    FlutterEventSink eventSink = [TtlockUpgradeFlutterPlugin sharedInstance].eventSink;
    if (eventSink == nil) {
        NSLog(@"TTLockUpgrade iOS native errro eventSink is nil");
    }else{
        eventSink(resultDict);
    }
}

#pragma mark  - FlutterStreamHandler
- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink{
    _eventSink = eventSink;
    return  nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}
@end
