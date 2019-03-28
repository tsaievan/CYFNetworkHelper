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
typedef void(^CYFHttpRequestFailed)(NSError *error);

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
                            failue:(CYFHttpRequestFailed)failue;

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
                   failue:(CYFHttpRequestFailed)failue;

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
                             failue:(CYFHttpRequestFailed)failue;

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
                            failue:(CYFHttpRequestFailed)failue;


/**
 上传文件

 @param URL 请求地址
 @param parameters 请求参数
 @param name 文件对应服务器上的字段
 @param filePath 文件本地的沙盒路径
 @param progress 上传进度信息
 @param success 请求成功的回调
 @param failue 请求失败的回调
 @return 返回的对象可取消请求, 调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(CYFHttpProgress)progress
                                         success:(CYFHttpRequestSuccess)success
                                         failure:(CYFHttpRequestFailed)failue;


#pragma mark - 设置AFHTTPSessionManager相关属性
/**
 自定义sessionManager的一些属性(全局改)
 @param sessionManager AFHTTPSessionManager实例
 */
+ (void)setAFHTTPSessionManagerProperty:(void (^)(AFHTTPSessionManager *))sessionManager;


/**
 设置网络请求参数的格式: 默认为二进制格式
 ///< 设置请求数据为JSON格式
 CYFRequestSerializerJSON,
 ///< 设置请求数据为二进制格式
 CYFRequestSerializerHTTP,
 */
+ (void)setRequestSerializer:(CYFRequestSerializer)requestSerializer;



/**
 设置服务器响应数据格式: 默认为JSON格式
 ///< 设置响应数据为JSON格式
 CYFResponseSerializerJSON,
 ///< 设置响应数据为二进制格式
 CYFResponseSerializerHTTP,
 */
+ (void)setResponseSerializer:(CYFResponseSerializer)responseSerializer;

/**
 设置请求超时市场, 默认为30s

 @param time 超时时长
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

///< 设置请求头
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 是否打开网络状态转菊花: 默认打开

 @param open YES(打开) , NO(关闭)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;


/**
 配置自建证书的https请求

 @param cerPath 自建https证书的路径
 @param validatesDomainName 是否需要验证域名, 默认为YES, 如果证书的域名与请求的的域名
 不一致, 需要设置为NO, 即服务器使用其他可信任机构颁发的证书, 也可以建立连接, 这个非常危险
 建议打开.
 
 validatesDomainName = NO, 主要用于下列情况:
 客户端请求的是子域名, 而证书上的是另外一个域名. 因为SSL证书上的域名是独立的, 假如证书上
 注册的域名是www.google.com, 那么mail.google.com是无法通过验证的

 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath
                 validatesDomainName:(BOOL)validatesDomainName;

@end

