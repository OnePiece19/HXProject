//
//  HXTabConfigureManager.h
//  HXProject
//
//  Created by hx on 2022/4/30.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXTabBarStyleModel : JSONModel

@property (nonatomic, copy) NSString *tabBackgroundColor;
@property (nonatomic, copy) NSString *tabSplitLineColor;

@end


@interface HXTabBarItemModel : JSONModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *navitationTitle;
@property (nonatomic, copy) NSString *imageNormal;
@property (nonatomic, copy) NSString *imageSelected;
@property (nonatomic, copy) NSString *imageLottie;
@property (nonatomic, copy) NSString *route;
@property (nonatomic, copy) NSString *navigateTo;//native路由
@property (nonatomic, copy) NSString *textColorNormal;
@property (nonatomic, copy) NSString *textColorSelected;

@property (nonatomic, assign) BOOL needDragRefresh;     //添加下拉刷新
@property (nonatomic, assign) BOOL needHideNavBar;      //显示隐藏导航条
@property (nonatomic, assign) BOOL needLoginValidate;   //是否需要登录验证
@property (nonatomic, assign) BOOL canScrollBouncing;   //是否可以滚动
/// NAV
@property (nonatomic, copy) NSString *navBarBorderColor;
@property (nonatomic, copy) NSString *navBarBgColor;
@property (nonatomic, copy) NSString *navTitleColor;
@property (nonatomic, assign) NSInteger navTitleWeight;

@end


@interface HXTabConfigureManager : NSObject

/// 设置TabBar样式模型
@property (nonatomic, strong) HXTabBarStyleModel *tabBarModel;

/// 设置TabBarItems样式模型
@property (nonatomic, strong) NSArray<HXTabBarItemModel *> *tabBarItemModelArray;


/// 获取资源路径
/// @param sourceName 资源名称
/// @param type 类型
/// @param bundleName bundle名称
- (NSString *)getSourcePathWithName:(NSString *)sourceName type:(nullable NSString *)type bundle:(nullable NSString *)bundleName;

/// 获取正常图片资源
/// @param itemModel 样式模型
- (UIImage *)getSourceImageNormalWithItemModel:(HXTabBarItemModel *)itemModel;

/// 获取选中图片资源
/// @param itemModel 样式模型
- (UIImage *)getSourceImageSelectedWithItemModel:(HXTabBarItemModel *)itemModel;

@end


NS_ASSUME_NONNULL_END
