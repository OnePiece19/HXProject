//
//  PBURLConst.m
//  PartyBuild
//
//  Created by HX on 2019/6/25.
//  Copyright © 2019 非公党建. All rights reserved.
//

#import "PBURLConst.h"

#if DevelopSever
/** 接口前缀-开发服务器*/
NSString *const kApiPrefix = @"http://party-api.t.eoffcn.com/";
#elif TestSever
/** 接口前缀-测试服务器*/
NSString *const kApiPrefix = @"http://party-api.t.eoffcn.com/";
#elif ProductSever
/** 接口前缀-生产服务器*/
NSString *const kApiPrefix = @"http://party-api.eoffcn.com/";
#endif



NSString *const URL_LOGINAPI_LOGIN      = @"api/v1/user/login";

NSString *const URL_LOGINAPI_LOGOUT     = @"api/v1/user/logout";

NSString *const URL_HOME_BANNER         = @"api/v1/news/recommend";

NSString *const URL_HOME_NEWSLIST       = @"api/v1/news/list";

NSString *const URL_HOME_SCHEDULEMARK   = @"api/v1/schedule/allMark";

NSString *const URL_HOME_SCHEDULELIST   = @"api/v1/schedule/list";

NSString *const URL_HOME_SCHEDULCREATE  = @"api/v1/schedule/create";
