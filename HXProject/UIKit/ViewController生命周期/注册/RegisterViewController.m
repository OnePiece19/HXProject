//
//  RegisterViewController.m
//  StudentManageSyatem
//
//  Created by 蒲悦蓉 on 2019/8/7.
//  Copyright © 2019 蒲悦蓉. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
@property UIImageView *grayImageView;
@property UIAlertView *baseAlert;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image = [UIImage imageNamed:@"landback3.PNG"];
    [self.view addSubview:imageView];
    
    _nameTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(70, 280, 235, 50)];
    _nameTextFiled.tag = 1;
    _psdTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(70, 350, 235, 50)];
    _psdTextFiled.tag = 2;
    _nameTextFiled.backgroundColor = [UIColor colorWithRed:0.42f green:0.76f blue:0.93f alpha:1.00f];
    _nameTextFiled.alpha = 1;
    _psdTextFiled.alpha = 1;
    _psdTextFiled.backgroundColor = [UIColor colorWithRed:0.42f green:0.76f blue:0.93f alpha:1.00f];
    _nameTextFiled.placeholder = @"请输入八位用户名";
    _psdTextFiled.placeholder = @"请输入八位以上密码";
    _nameTextFiled.keyboardType = UIKeyboardTypeDefault;
    _psdTextFiled.keyboardType = UIKeyboardTypeDefault;
    _nameTextFiled.font = [UIFont systemFontOfSize:22];
    _psdTextFiled.font = [UIFont systemFontOfSize:22];
    _nameTextFiled.delegate = self;
    _psdTextFiled.delegate = self;
    [self.view addSubview:_nameTextFiled];
    [self.view addSubview:_psdTextFiled];
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerButton setTitle:@"确认注册" forState:UIControlStateNormal];
    [registerButton setFrame:CGRectMake(138, 460, 100, 30)];
    [registerButton addTarget:self action:@selector(pressRegiste) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setBackgroundColor:[UIColor colorWithRed:0.42f green:0.76f blue:0.93f alpha:1.00f]];
    registerButton.titleLabel.alpha = 1;
    registerButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setFrame:CGRectMake(20, 50, 150, 40)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.jpeg"]  forState:UIControlStateNormal];
    [backButton setTitle:@"返回登陆" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setFont:[UIFont systemFontOfSize: 20]];
    [backButton addTarget:self action:@selector(pressBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)pressBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_nameTextFiled resignFirstResponder];
    [_psdTextFiled resignFirstResponder];
}

- (void)performDismiss
{
    [_grayImageView removeFromSuperview];
    [_baseAlert dismissWithClickedButtonIndex:0 animated:YES];
}
- (void)pressRegiste
{
    if (([_nameTextFiled.text length] < 8) || ([_psdTextFiled.text length] < 8)){
        _grayImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _grayImageView.backgroundColor = [UIColor grayColor];
        _grayImageView.alpha = 0.5;
        [self.view addSubview:_grayImageView];
        _baseAlert = [[UIAlertView alloc]
                      initWithTitle:nil  message:@"请输入正确格式的学号及密码"
                      delegate:self cancelButtonTitle:nil
                      otherButtonTitles: nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector: @selector(performDismiss) userInfo:nil repeats:NO];
        [_baseAlert show];
    } else {
        [self.delegate pushName:_nameTextFiled.text pushPsd:_psdTextFiled.text];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
   
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
