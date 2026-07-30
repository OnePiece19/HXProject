//
//  ClickPopViewController.m
//  UIViewController的生命周期
//
//  Created by 蒲悦蓉 on 2019/9/24.
//  Copyright © 2019 蒲悦蓉. All rights reserved.
//

#import "ClickPopViewController.h"

@interface ClickPopViewController ()

@end

@implementation ClickPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"clickPop";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(100, 150, 75, 40)];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:@"clickPop" forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 10;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button addTarget:self action:@selector(ClickPop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    // Do any additional setup after loading the view.
}
- (void)ClickPop:(UIButton*)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadView {
    NSLog(@"\n\n点击Pop界面  loadView");
    [super loadView];
}

/*x出现*/
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"\n\n点击Pop界面  viewWillAppear");
}
/*布局*/
- (void)viewWillLayoutSubviews {
    NSLog(@"\n\n点击Pop界面  viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
}

// view 已经布局其 Subviews
- (void)viewDidLayoutSubviews {
    NSLog(@"\n\n点击Pop界面  viewDidLayoutSubviews");
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"\n\n点击Pop界面  viewDidAppear");
}
/*消失*/
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"\n\n点击Pop界面  viewWillDisappear");
}
- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"\n\n点击Pop界面  viewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%s", __FUNCTION__);
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    NSLog(@"\n\n点击Pop界面  dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
