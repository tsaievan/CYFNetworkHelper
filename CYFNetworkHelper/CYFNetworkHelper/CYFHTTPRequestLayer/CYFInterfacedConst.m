//
//  CYFInterfacedConst.m
//  CYFNetworkHelper
//
//  Created by tsaievan on 28/3/2019.
//  Copyright © 2019 tsaievan. All rights reserved.
//

#import "CYFInterfacedConst.h"

#if DevelopServer

NSString *const kApiPrefix = @"http://192.168.10.10:8080";

#elif TestServer
NSString *const kApiPrefix = @"https://www.sina.com";

#elif ProductServer
NSString *const kApiPrefix = @"https://www.qq.com";

#endif

///< 登录
NSString *const kLogin = @"/login";

///< 退出
NSString *const kExit = @"/exit";
