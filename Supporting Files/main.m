//
//  main.m
//  HXProject
//
//  Created by HX on 2021/8/11.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

extern void _objc_autoreleasePoolPrint(void);



int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
