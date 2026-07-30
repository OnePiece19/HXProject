//
//  PBColorMacros.h
//  PartyBuild
//
//  Created by HX on 2019/6/25.
//  Copyright © 2019 非公党建. All rights reserved.
//

#ifndef PBColorMacros_h
#define PBColorMacros_h


/// 颜色设置
#define kClearColor         [UIColor clearColor]
#define kWhiteColor         [UIColor whiteColor]
#define kBlackColor         [UIColor blackColor]
#define kGrayColor          [UIColor grayColor]
#define kGray2Color         [UIColor lightGrayColor]
#define kBlueColor          [UIColor blueColor]
#define kRedColor           [UIColor redColor]
#define kRGB(r, g, b)       [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define kRGBA(r, g, b, a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kRandomColor        ([UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0f])

/// 转换16进制Color （16进制->10进制）
#define kColorFromHexRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/// 转换16进制Color （16进制->10进制），带透明度
#define kColorFromHexRGBA(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

/// app主色调
#define CAPPMainColor           kRGB(214.0, 60.0, 43.0)

/// 导航栏
#define CNavBgColor             CAPPMainColor
#define CNavBgFontColor         [UIColor colorWithHexString:@"ffffff"]
#define CNavWebProgressColor    [UIColor colorWithHexString:@"0485d1"]

/// 标签栏
#define CTabFontColor           kRGB(153.0, 153.0, 153.0)
#define CTabFontColorLight      CAPPMainColor

/// 默认页面背景色
#define CViewBgColor            [UIColor colorWithHexString:@"f2f2f2"]

#endif /* PBColorMacros_h */
