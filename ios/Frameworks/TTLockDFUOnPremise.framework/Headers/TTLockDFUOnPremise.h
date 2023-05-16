
//  Created by TTLock on 2017/8/9.
//  Copyright © 2017年 TTLock. All rights reserved.
//  version:1.0.0

#import <Foundation/Foundation.h>
#import "TTDFUMacros.h"

@interface TTLockDFUOnPremise : NSObject

+ (instancetype _Nonnull  )shareInstance;

//only do dfu operation
- (void)startDfuWithFirmwarePackage:(NSString *_Nonnull)firmwarePackage
                           lockData:(NSString *_Nonnull)lockData
                       successBlock:(TTLockDFUSuccessBlock _Nullable )sblock
                          failBlock:(TTLockDFUFailBlock _Nullable )fblock;
/**
 When you receive a failBlock, you can call this method to retry
 */
- (void)retry;

- (void)endUpgrade;

@end
