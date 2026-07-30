//
//  HXUncaughtExceptionHandle.h
//  HXProject
//
//  Created by HX on 2021/9/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXUncaughtExceptionHandle : NSObject

+ (void)installUncaughtSignalExceptionHandler;

@end

NS_ASSUME_NONNULL_END
