//
//  HXTabConfigureManager.m
//  HXProject
//
//  Created by hx on 2022/4/30.
//

#import "HXTabConfigureManager.h"
#import <Foundation/NSJSONSerialization.h>

@implementation HXTabSettingModel : JSONModel

+(BOOL)propertyIsOptional:(NSString *)propertyName{
    return true;
}
@end


@implementation HXTabModel

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

- (HXTabSettingModel *)tabStetingInfo {
    if (!_tabStetingInfo) {
        NSString *tabSInfo = [self getSourcePathWithName:@"tabs.json"type:nil bundle:@"kid_tabconfigure"];
        NSData *tabData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:tabSInfo]];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:tabData options:NSJSONReadingMutableLeaves error:nil];
        
        _tabStetingInfo = [[HXTabSettingModel alloc] init];
        
        NSString *tabBg = [jsonDict objectForKeySafely:@"tabBackgroundColor"];
        NSString *tabLineBg = [jsonDict objectForKeySafely:@"tabSplitLineColor"];
        if (tabBg && tabBg.length > 0) {
            _tabStetingInfo.tabBackgroundColor = tabBg;
        }
        if (tabLineBg && tabLineBg.length > 0) {
            _tabStetingInfo.tabSplitLineColor = tabLineBg;
        }
    }
    return _tabStetingInfo;
}

- (NSMutableArray *)tabSourceList {
    if (!_tabSourceList) {
        NSString *tabSInfo = [self getSourcePathWithName:@"tabs.json"type:nil bundle:@"kid_tabconfigure"];
        NSData *tabData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:tabSInfo]];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:tabData options:NSJSONReadingMutableLeaves error:nil];
        
        _tabSourceList = @[].mutableCopy;
        
        NSArray *list = [jsonDict objectForKeySafely:@"tabs"];
        for (NSDictionary *info in list) {
            NSError *error;
            HXTabModel *currentM = [[HXTabModel alloc] initWithDictionary:info error:&error];
            [_tabSourceList addObject:currentM];
        }
       
    }
    return _tabSourceList;
}

@end
