//
//  CYFNetworkHelper.m
//  CYFNetworkHelper
//
//  Created by tsaievan on 26/3/2019.
//  Copyright © 2019 tsaievan. All rights reserved.
//

#import "CYFNetworkHelper.h"
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>


#ifdef DEBUG
#define CYFLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define CYFLog(...)
#endif

#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

@implementation CYFNetworkHelper

static BOOL _isOpenLog; ///< 是否已开启日志打印
static NSMutableArray *_allSessionTask;
static AFHTTPSessionManager *_sessionManager;

+ (void)networkStatusWithBlock:(CYFNetworkStatus)networkStatus {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatus ? networkStatus(CYFNetworkStatusUnknown) : nil;
                if (_isOpenLog) {
                    CYFLog(@"未知网络");
                }
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus ? networkStatus(CYFNetworkStatusNotReachable) : nil;
                if (_isOpenLog) {
                    CYFLog(@"无网络");
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus ? networkStatus(CYFNetworkStatusReachableViaWWAN) : nil;
                if (_isOpenLog) {
                    CYFLog(@"手机自带网络");
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus ? networkStatus(CYFNetworkStatusReachableViaWiFi) : nil;
                if (_isOpenLog) {
                    CYFLog(@"WIFI网络");
                }
                break;
        }
    }];
}

+ (BOOL)isNetwork {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

+ (BOOL)isWWANNetwork {
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
}

+ (BOOL)isWiFiNetwork {
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
}

+ (void)openLog {
    _isOpenLog = YES;
}

+ (void)closeLog {
    _isOpenLog = NO;
}

+ (void)cancelAllRequest {
    @synchronized (self) {
        
    }
}

@end
