//
//  CYFHTTPRequest.m
//  CYFNetworkHelper
//
//  Created by tsaievan on 29/3/2019.
//  Copyright © 2019 tsaievan. All rights reserved.
//

#import "CYFHTTPRequest.h"
#import "CYFNetworkHelper.h"
#import "CYFInterfacedConst.h"

@implementation CYFHTTPRequest

///< 登录
+ (NSURLSessionTask *)getLoginWithParameters:(id)parameters
                                     success:(CYFRequestSuccess)success
                                     failure:(CYFRequestFailure)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@", kApiPrefix, kLogin];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

///< 退出
+ (NSURLSessionTask *)getExitWithParameters:(id)parameters
                                    success:(CYFRequestSuccess)success
                                    failure:(CYFRequestFailure)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@", kApiPrefix, kExit];
    return [self requestWithURL:url parameters:parameters success:success failure:failure];
}

/**
 配置好CYFNetworkHelper各项请求参数, 封装成一个公共的方法, 给以上方法调用
 相比在项目中分散的使用本网络框架或者其他网络框架, 可大大降低耦合, 方便维护
 在项目的后期, 你可以在公共请求方法内任意更换其他网络工具. 切换成本小
 */

#pragma mark - 请求的公共方法
+ (NSURLSessionTask *)requestWithURL:(NSString *)URL
                          parameters:(NSDictionary *)parameters
                             success:(CYFRequestSuccess)success
                             failure:(CYFRequestFailure)failure {
    ///< 在请求之前你可以统一配置你请求的相关参数, 设置请求头, 请求参数的格式, 返回数据的格式
    ///< 这样就不用每次请求都设置一遍相关参数
    ///< 设置请求头
    [CYFNetworkHelper setValue:@"9" forHTTPHeaderField:@"formType"];
    
    ///< 发起请求
    return [CYFNetworkHelper POST:URL parameters:parameters success:^(id responseObject) {
        ///< 在这里可以根据项目自定义其他一些重复操作, 比如加载页面时候的等待效果, 提醒弹窗等
        success ? success(responseObject) : nil;
    } failue:^(NSError *error) {
        
        ///< 同上
        failure ? failure(error) : nil;
    }];
}


@end
