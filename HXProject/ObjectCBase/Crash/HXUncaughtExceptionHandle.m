//
//  HXUncaughtExceptionHandle.m
//  HXProject
//
//  Created by HX on 2021/9/9.
//

#import "HXUncaughtExceptionHandle.h"
#import <SCLAlertView.h>
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <stdatomic.h>


NSString * const HXUncaughtExceptionHandlerSignalExceptionName = @"HXUncaughtExceptionHandlerSignalExceptionName";
NSString * const HXUncaughtExceptionHandlerSignalExceptionReason = @"HXUncaughtExceptionHandlerSignalExceptionReason";
NSString * const HXUncaughtExceptionHandlerSignalKey = @"HXUncaughtExceptionHandlerSignalKey";
NSString * const HXUncaughtExceptionHandlerAddressesKey = @"HXUncaughtExceptionHandlerAddressesKey";
NSString * const HXUncaughtExceptionHandlerFileKey = @"HXUncaughtExceptionHandlerFileKey";
NSString * const HXUncaughtExceptionHandlerCallStackSymbolsKey = @"HXUncaughtExceptionHandlerCallStackSymbolsKey";


atomic_int  HXUncaughtExceptionCount = 0;

const int32_t     HXUncaughtExceptionMaximum = 8;
const NSInteger   HXUncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger   HXUncaughtExceptionHandlerReportAddressCount = 5;


@implementation HXUncaughtExceptionHandle

+ (void)installUncaughtSignalExceptionHandler {
    
    NSSetUncaughtExceptionHandler(&HXExceptionHandlers);
}

// Exception
void HXExceptionHandlers(NSException *exception){
    NSLog(@"%s",__func__);
    int32_t exceptionCount = atomic_fetch_add_explicit(&HXUncaughtExceptionCount,1,memory_order_relaxed);
    if (exceptionCount > HXUncaughtExceptionMaximum) {
        return;
    }
    // 获取堆栈信息  -  model 编程思想
//    NSArray * callStack = [HXUncaughtExceptionHandle ]
    
}

- (void)hx_handleException:(NSException *)exception {
    // 保存上传到服务器
//    NSDictionary * userinfo = [exception userInfo];
}

// 保存崩溃信息
- (void)saveCrash:(NSException *)exception file:(NSString *)file {

    NSArray *stackArray = [[exception userInfo] objectForKey:HXUncaughtExceptionHandlerCallStackSymbolsKey];// 异常的堆栈信息
    NSString *reason = [exception reason];// 出现异常的原因
    NSString *name = [exception name];// 异常名称
    
    // 或者直接用代码，输入这个崩溃信息，以便在console中进一步分析错误原因
    // NSLog(@"crash: %@", exception);
    
    NSString * _libPath  = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file];

    if (![[NSFileManager defaultManager] fileExistsAtPath:_libPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:_libPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    
    NSString * savePath = [_libPath stringByAppendingFormat:@"/error%@.log",timeString];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@",name, reason, stackArray];
    
    BOOL sucess = [exceptionInfo writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"保存崩溃日志 sucess:%d,%@",sucess,savePath);
}

@end
