
//
//  CYFNetworkCache.m
//  CYFNetworkHelper
//
//  Created by tsaievan on 26/3/2019.
//  Copyright © 2019 tsaievan. All rights reserved.
//

#import "CYFNetworkCache.h"
#import <YYCache.h>

static NSString *const kCYFNetworkResponseCache = @"kCYFNetworkResponseCache";

@implementation CYFNetworkCache

static YYCache *_dataCache;

///< initialize方法是懒加载的
+ (void)initialize {
    ///< 在initialize方法里面去进行YYCache对象的初始化
    _dataCache = [YYCache cacheWithName:kCYFNetworkResponseCache];
}

+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters {
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    ///< 异步缓存, 不会阻塞线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
}

+ (id)httpCacheForURL:(NSString *)URL parameters:(id)parameters {
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}

+ (NSInteger)getAllHttpCacheSize {
    
    ///< Returns the total cost (in bytes) of objects in this cache. This method may blocks the calling thread until file read finished.
    
    ///< 这里是磁盘缓存, 缓存中所有对象所占用的字节数
    ///< 这个方法可能会阻塞调用线程, 知道文件读取完成
    return [_dataCache.diskCache totalCost];
}

///< 清除所有的磁盘缓存
+ (void)removeAllHttpCache {
    [_dataCache.diskCache removeAllObjects];
}

/**
 将URL地址和参数转变为缓存要用到的key

 @param URL URL地址
 @param parameters 参数
 @return 缓存key
 */
+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if (!parameters || parameters.count == 0) {
        return URL;
    }
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:nil];
    NSString *paramString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@%@", URL, paramString];
}

@end
