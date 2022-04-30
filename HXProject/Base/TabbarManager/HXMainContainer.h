//
//  HXMainContainer.h
//  HXProject
//
//  Created by hx on 2022/4/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    KTabBarSelectIndexCourse = 0,       //课程
    KTabBarSelectIndexStudy,            //学习
    KTabBarSelectIndexSquare,           //广场
    KTabBarSelectIndexMain,             //我的
} KTabBarSelectIndex;

@interface HXMainContainer : UITabBarController

@property (nonatomic, assign) NSInteger lastSelectIdx;

@end

NS_ASSUME_NONNULL_END
