//
//  AppDelegate.m
//  HXProject
//
//  Created by hx on 2021/6/29.
//

#import "AppDelegate.h"
#import "HXUncaughtExceptionHandle.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"应用程序启动");
//    while (YES) {
//        NSLog(@"11111");
//    }
    [HXUncaughtExceptionHandle installUncaughtSignalExceptionHandler];
    return YES;
}


#pragma mark - UISceneSession lifecycle

//1.如果没有在APP的Info.plist文件中包含scene的配置数据，或者要动态更改场景配置数据，需要实现此方法。 UIKit会在创建新scene前调用此方法。
//参数options是一个UISceneConnectionOptions类，官方解释：它包含了为什么要创建一个新的scene的信息。根据参数信息判断是否要创建一个新的scene
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    NSLog(@"创建了新的场景");
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

//方法会返回一个UISceneConfiguration对象，其包含其中包含场景详细信息，包括要创建的场景类型，用于管理场景的委托对象以及包含要显示的初始视图控制器的情节提要。 如果未实现此方法，则必须在应用程序的Info.plist文件中提供场景配置数据。
//总结下：默认在info.plist中进行了配置， 不用实现该方法也没有关系。如果没有配置就需要实现这个方法并返回一个UISceneConfiguration对象。
//在分屏中关闭其中一个或多个scene时候回调用。
- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    NSLog(@"场景被释放");
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

#pragma mark --如果使用SceneDelegate，原先AppDelegate的生命周期方法不再起作用。

#pragma mark 程序失去焦点的时候调用（不能跟用户进行交互了）

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive-失去焦点");
}


#pragma mark 当应用程序进入后台的时候调用（点击HOME键）

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground-进入后台");
}


#pragma mark 当应用程序进入前台的时候调用

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground-进入前台");
}


#pragma mark 当应用程序获取焦点的时候调用

// 获取焦点之后才可以跟用户进行交互
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive-获取焦点");
}


#pragma mark 程序在某些情况下被终结时会调用这个方法

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate-被关闭");
}


//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    if([[url scheme] isEqualToString:@"hxProject"]) {
//        [application setApplicationIconBadgeNumber:10];
//
//        while (YES) {
//            NSLog(@"1111");
//        }
//        return YES;
//    }
//
//    while (YES) {
//        NSLog(@"1111");
//    }
//    return NO;
//}

- (BOOL)application:(UIApplication*)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString*)sourceApplication annotation:(nonnull id)annotation {
    NSLog(@"%@",[url host] );
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {

    // 监听linePay付款完后wap界面跳转

//    [self handleOpenFromLinePayWithUrl:url];
    NSLog(@"%@",[url host] );
    
    return YES;

}

//-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
////  打印出来的就是项目A传递过来的参数
//    NSLog(@"%@",[url host] );
//
//    return YES;
//}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"%@",[url scheme]);
    return YES;
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    NSLog(@"%@",[url scheme]);
//    return YES;
//}


//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
//    if([[url scheme] isEqualToString:@"hxProject"]) {
//        [app setApplicationIconBadgeNumber:10];
//        return YES;
//    }
//    return NO;
//}

@end
