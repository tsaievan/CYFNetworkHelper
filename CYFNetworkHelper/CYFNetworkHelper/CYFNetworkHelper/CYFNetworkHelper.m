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
#import "CYFNetworkCache.h"


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
static NSLock *_lock;

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
    ///< 锁操作 @synchronized是效率最低的
    //    @synchronized (self) {
    ///< 遍历请求task数组, 逐个取消
    
    [[self lock] lock];
    [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
        [task cancel];
    }];
    ///< 整个数组清空
    [[self allSessionTask] removeAllObjects];
    //    }
    [[self lock] unlock];
}

+ (void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) {
        return;
    }
    ///< 锁操作 @synchronized是效率最低的
    //    @synchronized (self) {
    [[self lock] lock];
    [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
            [task cancel];
            [[self allSessionTask] removeObject:task];
            *stop = YES;
        }
    }];
    [[self lock] unlock];
    //    }
}

#pragma mark - GET请求无缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
                  success:(CYFHttpRequestSuccess)success
                   failue:(CYFHttpRequestFailed)failue {
    return [self GET:URL parameters:parameters responseCache:nil success:success failue:failue];
}

#pragma mark - POST请求无缓存
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
                   success:(CYFHttpRequestSuccess)success
                    failue:(CYFHttpRequestFailed)failue {
    return [self POST:URL parameters:parameters responseCache:nil success:success failue:failue];
}

#pragma mark - GET请求自动缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
            responseCache:(CYFHttpRequestCache)responseCache
                  success:(CYFHttpRequestSuccess)success
                   failue:(CYFHttpRequestFailed)failue {
    ///< 首先读取缓存
    responseCache != nil ? responseCache([CYFNetworkCache httpCacheForURL:URL parameters:parameters]) : nil;
    NSURLSessionTask *sessionTask = [_sessionManager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ///< 如果成功
        if (_isOpenLog) {
            CYFLog(@"responseObject = %@", responseObject);
        }
        ///< 从任务数组中移除网络请求task
        [[self allSessionTask] removeObject:task];
        ///< 走成功的回调
        success ? success(responseObject) : nil;
        ///< 对数据进行异步缓存
        responseCache != nil ? [CYFNetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            CYFLog(@"error = %@", error);
        }
        ///< 移除任务
        [[self allSessionTask] removeObject:task];
        ///< 回调
        failue ? failue(error) : nil;
    }];
    ///< 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
    return sessionTask;
}

+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
             responseCache:(CYFHttpRequestCache)responseCache
                   success:(CYFHttpRequestSuccess)success
                    failue:(CYFHttpRequestFailed)failue {
    ///< 首先读取缓存
    responseCache != nil ? responseCache([CYFNetworkCache httpCacheForURL:URL parameters:parameters]) : nil;
    NSURLSessionTask *task = [_sessionManager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            CYFLog(@"responseObject = %@", responseObject);
        }
        ///< 任务数组中删除数据
        [[self allSessionTask] removeObject:task];
        ///< 成功的回调
        success ? success(responseObject) : nil;
        ///< 设置缓存
        responseCache != nil ? [CYFNetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            CYFLog(@"error = %@", error);
        }
        ///< 任务数组中删除数据
        [[self allSessionTask] removeObject:task];
        ///< 失败的回调
        failue ? failue(error) : nil;
    }];
    ///< 添加进任务数组
    task ? [[self allSessionTask] addObject:task] : nil;
    return task;
}

+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(CYFHttpProgress)progress
                                         success:(CYFHttpRequestSuccess)success
                                         failure:(CYFHttpRequestFailed)failue {
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        (failue && error) ? failue(error) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        ///< 回到主线程, 更新进度
        ///< 同步的
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            CYFLog(@"responseObject = %@", responseObject);
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            CYFLog(@"error = %@", error);
        }
        [[self allSessionTask] removeObject:task];
        failue ? failue(error) : nil;
    }];
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
    return sessionTask;
}

#pragma mark - 上传多张图片
+ (NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                               parameters:(id)parameters
                                     name:(NSString *)name
                                   images:(NSArray <UIImage *> *)images
                                fileNames:(NSArray <NSString *> *)fileNames
                               imageScale:(CGFloat)imageScale
                                imageType:(NSString *)imageType
                                 progress:(CYFHttpProgress)progress
                                  success:(CYFHttpRequestSuccess)success
                                  failure:(CYFHttpRequestFailed)failue {
    NSURLSessionTask *sesstionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSUInteger i = 0; i < images.count; i++) {
            ///< 图片经过等比压缩后得到的二进制文件
            NSData *imageData = UIImageJPEGRepresentation(images[i], imageScale ? : 1.f);
            ///< 默认图片的文件名, 若fileName为nil就使用
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = NSStringFormat(@"%@%ld.%@", str, i, imageType ? : @"jpg");
            [formData appendPartWithFileData:imageData name:name fileName:fileNames ? NSStringFormat(@"%@.%@", fileNames[i], imageType ? : @"jpg") : imageFileName mimeType:NSStringFormat(@"image/%@", imageType ? : @"jpg")];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        ///< 主线程同步操作, 这里是会阻塞当前线程, 然后等主线程的任务完成之后, 才会继续走子线程的代码
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            CYFLog(@"responseObject = %@", responseObject);
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            CYFLog(@"error = %@", error);
        }
        [[self allSessionTask] removeObject:task];
        failue ? failue(error) : nil;
    }];
    sesstionTask ? [[self allSessionTask] addObject:sesstionTask] : nil;
    return sesstionTask;
}

#pragma mark - 下载文件
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                             progress:(CYFHttpProgress)progress
                              success:(void(^)(NSString *))success
                              failure:(CYFHttpRequestFailed)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        ///< 主线程中更新下载进度
        ///< 同步的
        dispatch_sync(dispatch_get_main_queue(), ^{
           progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        ///< 拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: fileDir ? fileDir : @"Download"];
        ///< 打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        ///< 创建download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        ///< 拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        ///< 返回文件位置的URL地址
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if (failure && error) {
            failure(error);
            return;
        }
        success ? success(filePath.absoluteString) : nil;
    }];
    ///< 开始下载
    [downloadTask resume];
    
    ///< 把下载任务加进任务数组中
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil;
    
    return downloadTask;
}

#pragma mark - 初始化AFHTTPSessionManager相关属性

+ (void)load {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)initialize {
    ///< 初始会话对象
    _sessionManager = [AFHTTPSessionManager manager];
    ///< 设置超时时长为30秒
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

#pragma mark - 重置AFHTTPSessionManager相关属性

+ (void)setAFHTTPSessionManagerProperty:(void (^)(AFHTTPSessionManager *))sessionManager {
    sessionManager ? sessionManager(_sessionManager) : nil;
}

+ (void)setRequestSerializer:(CYFRequestSerializer)requestSerializer {
    _sessionManager.requestSerializer = requestSerializer == CYFRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)setResponseSerializer:(CYFResponseSerializer)responseSerializer {
    _sessionManager.responseSerializer = responseSerializer == CYFResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time {
    _sessionManager.requestSerializer.timeoutInterval = time;
}

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

+ (void)openNetworkActivityIndicator:(BOOL)open {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = open;
}

/**
 存储所有请求task数组
 */
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}

+ (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}
@end


#pragma mark - NSDictionary, NSArray的分类

#ifdef DEBUG

@implementation NSArray(CYF)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    [strM appendString:@")"];
    return strM;
}

@end

@implementation NSDictionary (CYF)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    [strM appendString:@"}\n"];
    return strM;
}

@end

#endif
