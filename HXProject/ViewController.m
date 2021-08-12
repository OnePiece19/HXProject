//
//  ViewController.m
//  HXProject
//
//  Created by HX on 2021/8/11.
//

#import "ViewController.h"
#import "HXNotificationViewController.h"

#import "KVCViewController.h"
#import "TestKVCCrashVC.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"通知中心验证" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 100, 60);
    [btn addTarget:self action:@selector(testNotification) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.center = self.view.center;
    
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn1 setTitle:@"KVC验证" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn1.frame = CGRectMake(0, 0, 100, 60);
    [btn1 addTarget:self action:@selector(testKVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    btn1.center = self.view.center;
    CGRect frame = btn1.frame;
    frame.origin.y += 60.0f;
    btn1.frame = frame;
}

- (void)testNotification {
    HXNotificationViewController *vc = [HXNotificationViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)testKVC {
    TestKVCCrashVC *vc = [TestKVCCrashVC new];
    [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController pushViewController:vc animated:YES];

}

@end
