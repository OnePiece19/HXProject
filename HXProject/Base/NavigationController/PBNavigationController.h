//
//  PBNavigationController.h
//  PartyBuild
//
//  Created by HX on 2019/6/26.
//  Copyright © 2019 非公党建. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBNavigationController : UINavigationController

/**
 *  返回到指定的类视图
 *
 *  @param ClassName 类名
 *  @param animated  是否动画
 */
-(BOOL)popToAppointViewController:(NSString *)ClassName animated:(BOOL)animated;


@end

NS_ASSUME_NONNULL_END
