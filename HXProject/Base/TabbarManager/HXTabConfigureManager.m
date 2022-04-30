//
//  HXTabConfigureManager.m
//  HXProject
//
//  Created by hx on 2022/4/30.
//

#import "HXTabConfigureManager.h"
#import <Foundation/NSJSONSerialization.h>

@implementation HXTabBarStyleModel : JSONModel

+(BOOL)propertyIsOptional:(NSString *)propertyName{
    return true;
}
@end


@implementation HXTabBarItemModel

+(BOOL)propertyIsOptional:(NSString *)propertyName{
    return true;
}

@end


@implementation HXTabConfigureManager

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSString *)getSourcePathWithName:(NSString *)sourceName type:(nullable NSString *)type bundle:(nullable NSString *)bundleName {
    NSString *sourcePath;
    if (bundleName && [bundleName isKindOfClass:[NSString class]] && bundleName.length > 0) {
        NSURL *hybridBundleURL = [[NSBundle mainBundle] URLForResource:bundleName withExtension:@"bundle"];
        sourcePath = [[NSBundle bundleWithURL:hybridBundleURL] pathForResource:sourceName ofType:type];
    } else {
        sourcePath = [[NSBundle mainBundle] pathForResource:sourceName ofType:type];
    }
    return sourcePath;
}

- (UIImage *)getSourceImageNormalWithItemModel:(HXTabBarItemModel *)itemModel {
    NSString *imgNormalTemp;
    if ([UIScreen mainScreen].scale < 3) {
        imgNormalTemp = [NSString stringWithFormat:@"%@@2x",itemModel.imageNormal];
    } else {
        imgNormalTemp = [NSString stringWithFormat:@"%@@3x",itemModel.imageNormal];
    }
    NSString *imgNormalPath = [self getSourcePathWithName:imgNormalTemp type:@"png" bundle:@"kid_tabconfigure"];
    
    UIImage * imageNormal;
    if (imgNormalPath.length > 0) {
        imageNormal = [[UIImage imageWithContentsOfFile:imgNormalPath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        imageNormal = [[UIImage imageNamed:imgNormalTemp] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    return imageNormal;
}

- (UIImage *)getSourceImageSelectedWithItemModel:(HXTabBarItemModel *)itemModel {
    NSString *imgSelectedTemp;
    if ([UIScreen mainScreen].scale < 3) {
        imgSelectedTemp = [NSString stringWithFormat:@"%@@2x",itemModel.imageSelected];
    } else {
        imgSelectedTemp = [NSString stringWithFormat:@"%@@3x",itemModel.imageSelected];
    }
    NSString *imgSelectedPath = [self getSourcePathWithName:imgSelectedTemp type:@"png" bundle:@"kid_tabconfigure"];
    
    UIImage * imageSelected;
    if (imgSelectedPath.length > 0) {
        imageSelected = [[UIImage imageWithContentsOfFile:imgSelectedPath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        imageSelected = [[UIImage imageNamed:imgSelectedTemp] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    return imageSelected;
}

- (HXTabBarStyleModel *)tabBarModel {
    if (!_tabBarModel) {
        NSString *tabSInfo = [self getSourcePathWithName:@"tabs.json"type:nil bundle:@"kid_tabconfigure"];
        NSData *tabData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:tabSInfo]];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:tabData options:NSJSONReadingMutableLeaves error:nil];
        
        _tabBarModel = [[HXTabBarStyleModel alloc] init];
        NSString *tabBg = [jsonDict objectForKeySafely:@"tabBackgroundColor"];
        NSString *tabLineBg = [jsonDict objectForKeySafely:@"tabSplitLineColor"];
        if (tabBg && tabBg.length > 0) {
            _tabBarModel.tabBackgroundColor = tabBg;
        }
        if (tabLineBg && tabLineBg.length > 0) {
            _tabBarModel.tabSplitLineColor = tabLineBg;
        }
    }
    return _tabBarModel;
}

- (NSArray *)tabBarItemModelArray {
    if (!_tabBarItemModelArray) {
        NSString *tabSInfo = [self getSourcePathWithName:@"tabs.json"type:nil bundle:@"kid_tabconfigure"];
        NSData *tabData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:tabSInfo]];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:tabData options:NSJSONReadingMutableLeaves error:nil];

        NSMutableArray * tempMutArr = [NSMutableArray new];
        NSArray *list = [jsonDict objectForKeySafely:@"tabs"];
        for (NSDictionary *info in list) {
            NSError *error;
            HXTabBarItemModel *currentM = [[HXTabBarItemModel alloc] initWithDictionary:info error:&error];
            [tempMutArr addObject:currentM];
        }
        _tabBarItemModelArray = [tempMutArr copy];
    }
    return _tabBarItemModelArray;
}

@end
