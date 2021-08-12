//
//  HXNotificationViewController.m
//  HXProject
//
//  Created by HX on 2021/8/12.
//

#import "HXNotificationViewController.h"

@interface HXNotificationViewController ()

{
    id  newMessageObserver;
}

@end

@implementation HXNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self notificationCenter];
}

#pragma mark - 系统通知中心
- (void)notificationCenter {
    // 添加通知监听 method
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nothandle:) name:@"notify" object:nil];
    // 添加通知监听 block
    newMessageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"notify" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@ notify Block!",note.userInfo[@"notiKey"]);
    }];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notify" object:nil userInfo:@{@"notiKey":@"Hello word!"}];
}

- (void)nothandle:(NSNotification *)not{
    NSLog(@"%@",not.userInfo[@"notiKey"]);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:newMessageObserver];
}



@end
