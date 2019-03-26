//
//  CYFNetworkHelper.h
//  CYFNetworkHelper
//
//  Created by tsaievan on 26/3/2019.
//  Copyright © 2019 tsaievan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFNetworkCache.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CYFNetworkStatusType) {
    ///< 未知网络
    CYFNetworkStatusUnknown,
    ///< 无网络
    CYFNetworkStatusNotReachable,
    ///< 手机网络
    CYFNetworkStatusReachableViaWWAN,
    ///< WIFI网络
    CYFNetworkStatusReachableViaWiFi
};

typedef NS_ENUM(NSUInteger, CYFRequestSerializer) {
    ///< 设置请求数据为JSON格式
    CYFRequestSerializerJSON,
    ///< 设置请求数据为二进制格式
    CYFRequestSerializerHTTP,
};

typedef NS_ENUM(NSUInteger, CYFResponseSerializer) {
    ///< 设置响应数据为JSON格式
    CYFResponseSerializerJSON,
    ///< 设置响应数据为二进制格式
    CYFResponseSerializerHTTP,
};

///< 请求成功的block
typedef void(^CYFHttpRequestSuccess)(id responseObject);

///< 请求失败的block
typedef void(^CYFRequestFailed)(NSError *error);

///< 缓存的block
typedef void(^CYFHttpRequestCache)(id responseCache);

///< 上传或者下载进度, Progress.completedUnitCount; 当前大小, Progress.totalUnitCount
typedef void(^CYFHttpProgress)(NSProgress *progress);

///< 网络状态的block
typedef void(^CYFNetworkStatus)(CYFNetworkStatusType status);

///< 向前声明
@class AFHTTPSessionManager;
@interface CYFNetworkHelper : NSObject

/**
 有网: YES, 无网: NO
 */
+ (BOOL)isNetwork;

/**
 有手机网络:YES 无手机网络:NO
 */
+ (BOOL)isWWANNetwork;

/**
 有wifi网络:YES 无wifi网络:NO
 */
+ (BOOL)isWiFiNetwork;

/**
 取消所有HTTP请求
 */
+ (void)cancelAllRequest;

/**
 实时获取网络状态, 通过block回调实时调取(此方法可以多次调用)
 */
+ (void)networkStatusWithBlock:(CYFNetworkStatus)networkStatus;

/**
 取消置顶URL的HTTP对象
 */
+ (void)cancelRequestWithURL:(NSString *)URL;

/**
 开启日志打印
 */
+ (void)openLog;

/**
 关闭日志打印, 默认关闭
 */
+ (void)closeLog;

@end

NS_ASSUME_NONNULL_END
