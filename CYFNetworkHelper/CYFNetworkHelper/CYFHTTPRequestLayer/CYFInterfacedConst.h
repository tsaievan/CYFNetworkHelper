//
//  CYFInterfacedConst.h
//  CYFNetworkHelper
//
//  Created by tsaievan on 28/3/2019.
//  Copyright © 2019 tsaievan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 将项目中的所有接口写在这里,方便统一管理, 降低耦合
 
 这里通过宏定义来切换你当前的服务器类型
 将你要切换的服务器类型宏后面置为真(即>0即可), 其余为假(置为0)
 如下: 现在的状态为测试服务器
 这样做切换方便, 不用来回每个网络请求修改请求域名, 降低出错事件
 
 */

#define DevelopServer 0
#define TestServer 1
#define ProductServer 0

///< 接口前缀 - 开发服务器
UIKIT_EXTERN NSString *const kApiPrefix;

#pragma mark - 详细接口地址
///< 登录
UIKIT_EXTERN NSString *const kLogin;

///< 退出
UIKIT_EXTERN NSString *const kExit;


