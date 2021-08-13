//
//  PBViewController.m
//  PartyBuild
//
//  Created by HX on 2019/6/26.
//  Copyright © 2019 非公党建. All rights reserved.
//

#import "PBViewController.h"
#import <objc/runtime.h>

@interface PBViewController ()

@property (nonatomic,strong) UIImageView* noDataView;

@end

@implementation PBViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kWhiteColor;
    self.isShowLeftBack = YES;
    
    [kNotificationCenter addObserver:self selector:@selector(backBtnClicked) name:kNotiRootClickBack object:nil];
}

- (void)dealloc {
    NSArray *arrayChildClass = [self findAllOf: [self class]];
    NSString *name =   [NSString stringWithCString:object_getClassName([arrayChildClass lastObject]) encoding:NSUTF8StringEncoding];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    PBLog(@"==========%@已释放============",name);
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return _StatusBarStyle;
}

#pragma mark - Event Response

- (void)backBtnClicked {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Public Methods

-(void)showNoDataImage {
    _noDataView=[[UIImageView alloc] init];
    [_noDataView setImage:[UIImage imageNamed:@"generl_nodata"]];
    [self.view.subviews enumerateObjectsUsingBlock:^(UITableView* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UITableView class]]) {
            [_noDataView setFrame:CGRectMake(0, 0,obj.frame.size.width, obj.frame.size.height)];
            [obj addSubview:_noDataView];
        }
    }];
}

-(void)removeNoDataImage {
    if (_noDataView) {
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
}

- (void)showLoadingAnimation {
    
}

- (void)stopLoadingAnimation {
    
}

/**
 导航栏添加图标按钮
 */
- (void)addNavigationItemWithImageNames:(NSArray *)imageNames isLeft:(BOOL)isLeft target:(id)target action:(SEL)action tags:(NSArray *)tags{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    NSInteger i = 0;
    for (NSString * imageName in imageNames) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        if (isLeft) {
            [btn setContentEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
        }else{
            [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        }
        btn.tag = [tags[i++] integerValue];
        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [items addObject:item];
    }
    if (isLeft) {
        self.navigationItem.leftBarButtonItems = items;
    } else {
        self.navigationItem.rightBarButtonItems = items;
    }
}

/**
 导航栏添加文本按钮
 */
- (void)addNavigationItemWithTitles:(NSArray *)titles isLeft:(BOOL)isLeft target:(id)target action:(SEL)action tags:(NSArray *)tags{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    NSMutableArray * buttonArray = [NSMutableArray array];
    NSInteger i = 0;
    for (NSString * title in titles) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [btn setTitle:title forState:UIControlStateNormal];
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = SYSTEMFONT(16);
        [btn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        btn.tag = [tags[i++] integerValue];
        [btn sizeToFit];
        
        //设置偏移
        if (isLeft) {
            [btn setContentEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
        }else{
            [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        }
        
        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [items addObject:item];
        [buttonArray addObject:btn];
    }
    if (isLeft) {
        self.navigationItem.leftBarButtonItems = items;
    } else {
        self.navigationItem.rightBarButtonItems = items;
    }
}

#pragma mark - Private Methods

/// 获取当前控制器下的子类
- (NSArray *)findAllOf:(Class)defaultClass{
    int count = objc_getClassList(NULL, 0);
    if (count <= 0) {
        return [NSArray arrayWithObject:defaultClass];
    }
    NSMutableArray *output = [NSMutableArray arrayWithObject:defaultClass];
    Class *classes = (Class *) malloc(sizeof(Class) * count);
    objc_getClassList(classes, count);
    for (int i = 0; i < count; ++i) {
        if (defaultClass == class_getSuperclass(classes[i])){
            [output addObject:classes[i]];
        }
    }
    free(classes);
    return [NSArray arrayWithArray:output];
}

#pragma mark - Getter

#pragma mark - Setter

/** 动态更新状态栏颜色 */
-(void)setStatusBarStyle:(UIStatusBarStyle)StatusBarStyle{
    /**
     * UIStatusBarStyleDefault
     * UIStatusBarStyleLightContent
     * UIStatusBarStyleBlackTranslucent
     * UIStatusBarStyleBlackOpaque
     */
    _StatusBarStyle=StatusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

/**
 *  是否显示返回按钮
 */
- (void)setIsShowLeftBack:(BOOL)isShowLeftBack{
    _isShowLeftBack = isShowLeftBack;
    NSInteger VCCount = self.navigationController.viewControllers.count;
    
    // 下面判断的意义是 当VC所在的导航控制器中的VC个数大于1 或者 是present出来的VC时，才展示返回按钮，其他情况不展示
    if (isShowLeftBack && ( VCCount > 1 || self.navigationController.presentingViewController != nil)) {
        [self addNavigationItemWithImageNames:@[@"nav_back"] isLeft:YES target:self action:@selector(backBtnClicked) tags:@[@1000]];
    } else {
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem * NULLBar=[[UIBarButtonItem alloc]initWithCustomView:[UIView new]];
        self.navigationItem.leftBarButtonItem = NULLBar;
    }
}

#pragma mark -  屏幕旋转

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait; // 默认进去类型
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; //当前支持的旋转类型
}

- (BOOL)shouldAutorotate {
    return YES; // 是否支持旋转
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
