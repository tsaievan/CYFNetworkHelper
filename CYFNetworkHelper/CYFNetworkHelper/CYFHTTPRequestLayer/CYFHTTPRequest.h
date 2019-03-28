//
//  CYFHTTPRequest.h
//  CYFNetworkHelper
//
//  Created by tsaievan on 29/3/2019.
//  Copyright © 2019 tsaievan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 以下的block的参数根据自己项目中的需求来定, 这里仅仅是一个演示的例子
 */

/**
 请求成功的block
 */
typedef void(^CYFRequestSuccess)(id response);

/**
 请求失败的block
 */
typedef void(^CYFRequestFailure)(NSError *error);

@interface CYFHTTPRequest : NSObject

#pragma mark - 登陆, 退出
+ (NSURLSessionTask *)getLoginWithParameters:(id)parameters
                                     success:(CYFRequestSuccess)success
                                     failure:(CYFRequestFailure)failure;

///< 退出
+ (NSURLSessionTask *)getExitWithParameters:(id)parameters
                                    success:(CYFRequestSuccess)success
                                    failure:(CYFRequestFailure)failure;



@end

NS_ASSUME_NONNULL_END
