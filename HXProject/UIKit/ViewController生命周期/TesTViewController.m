//
//  TesTViewController.m
//  UIViewController的生命周期
//
//  Created by 蒲悦蓉 on 2019/9/22.
//  Copyright © 2019 蒲悦蓉. All rights reserved.
//

#import "TesTViewController.h"

@interface TesTViewController ()

@end

@implementation TesTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"\n\n界面2  viewDidLoad开始");
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(100, 150, 75, 40)];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:@"dismiss" forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 10;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button addTarget:self action:@selector(ClickDismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
//    label.text = @"====  TestViewController  =====";
//    [self.view addSubview:label];
    
}
- (void)ClickDismiss:(UIButton*)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

    
    
/*什么时候被调用？
 每次访问UIViewController的view(比如controller.view、self.view)而且view为nil，loadView方法就会被调用。
 有什么作用？
 loadView方法是用来负责创建UIViewController的view
 */
- (void)loadView {
    NSLog(@"\n\n界面2  loadView");
    [super loadView];
}

/*x出现*/
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"\n\n界面2  viewWillAppear");
}
/*布局*/
- (void)viewWillLayoutSubviews {
    NSLog(@"\n\n界面2  viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
}

// view 已经布局其 Subviews
- (void)viewDidLayoutSubviews {
    NSLog(@"\n\n界面2  viewDidLayoutSubviews");
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"\n\n界面2  viewDidAppear");
}
 /*消失*/
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"\n\n界面2  viewWillDisappear");
}
- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"\n\n界面2  viewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%s", __FUNCTION__);
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    NSLog(@"\n\n界面2  dealloc");
    //    无需在重写的dealloc中添加[super dealloc]，因为sdk在编译的时候会自己添加上去。
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
