//
//  PBURLConst.h
//  PartyBuild
//
//  Created by HX on 2019/6/25.
//  Copyright © 2019 非公党建. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DevelopSever 1
#define TestSever    0
#define ProductSever 0


/** 接口前缀-开发服务器*/
UIKIT_EXTERN NSString *const kApiPrefix;

/** 用户登录 */
UIKIT_EXTERN NSString *const URL_LOGINAPI_LOGIN;

/** 用户退出 */
UIKIT_EXTERN NSString *const URL_LOGINAPI_LOGOUT;

/** 首页banner图 */
UIKIT_EXTERN NSString *const URL_HOME_BANNER;

/** 首页新闻列表 */
UIKIT_EXTERN NSString *const URL_HOME_NEWSLIST;

/** 日程标记 */
UIKIT_EXTERN NSString *const URL_HOME_SCHEDULEMARK;

/** 日程列表 */
UIKIT_EXTERN NSString *const URL_HOME_SCHEDULELIST;

/** 创建日程 */
UIKIT_EXTERN NSString *const URL_HOME_SCHEDULCREATE;
