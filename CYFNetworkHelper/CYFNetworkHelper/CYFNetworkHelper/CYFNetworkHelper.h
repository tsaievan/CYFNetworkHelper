//
//  CYFNetworkHelper.h
//  CYFNetworkHelper
//
//  Created by tsaievan on 26/3/2019.
//  Copyright © 2019 tsaievan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFNetworkCache.h"

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


/**
 GET请求, 无缓存

 @param URL 请求地址
 @param parameters 请求参数
 @param success 请求成功的回调
 @param failue 请求失败的回调
 @return 返回的对象可取消请求, 调用cancel方法
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(id)parameters
                           success:(CYFHttpRequestSuccess)success
                            failue:(CYFRequestFailed)failue;

/**
 GET请求, 自动缓存

 @param URL 请求地址
 @param parameters 请求参数
 @param responseCache 缓存数据的回调
 @param success 请求成功的回调
 @param failue 请求失败的回调
 @return 返回的对象可取消请求, 调用cancel方法
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
            responseCache:(CYFHttpRequestCache)responseCache
                  success:(CYFHttpRequestSuccess)success
                   failue:(CYFRequestFailed)failue;

/**
 POST请求, 无缓存

 @param URL 请求地址
 @param parameters 请求参数
 @param success 请求成功的回调
 @param failue 请求失败的回调
 @return 返回的对象可取消请求, 调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(id)parameters
                            success:(CYFHttpRequestSuccess)success
                             failue:(CYFRequestFailed)failue;

/**
 POST请求

 @param URL 请求地址
 @param parameters 请求参数
 @param responseCache 缓存数据的回调
 @param success 请求成功的回调
 @param failue 请求失败的回调
 @return 返回对象可取消请求, 调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                        parameters:(id)parameters
                     responseCache:(CYFHttpRequestCache)responseCache
                           success:(CYFHttpRequestSuccess)success
                            failue:(CYFRequestFailed)failue;

@end

