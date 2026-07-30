//
//  SceneDelegate+UIService.m
//  HXProject
//
//  Created by hx on 2021/7/14.
//

#import "SceneDelegate+UIService.h"
#import "HXTabBarController.h"

#import "HXMainContainer.h"

@implementation SceneDelegate (UIService)


-(void)initWindowUIScene:(UIScene *)scene {
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    self.window.rootViewController = [HXTabBarController new];
    self.window.rootViewController = [HXMainContainer new];
    [self.window makeKeyAndVisible];
}


@end
