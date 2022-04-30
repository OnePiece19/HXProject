//
//  HXTabConfigureManager.h
//  HXProject
//
//  Created by hx on 2022/4/30.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXTabSettingModel : JSONModel

@property (nonatomic, copy) NSString *tabBackgroundColor;
@property (nonatomic, copy) NSString *tabSplitLineColor;

@end


@interface HXTabModel : JSONModel

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

@property (nonatomic, strong) HXTabSettingModel *tabStetingInfo;

@property (nonatomic, strong) NSMutableArray <HXTabModel *> *tabSourceList;

- (NSString *)getSourcePathWithName:(NSString *)sourceName type:(nullable NSString *)type bundle:(nullable NSString *)bundleName;

@end


NS_ASSUME_NONNULL_END
