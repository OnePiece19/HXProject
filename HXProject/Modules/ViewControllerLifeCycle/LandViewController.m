//
//  LandViewController.m
//  StudentManageSyatem
//
//  Created by 蒲悦蓉 on 2019/8/7.
//  Copyright © 2019 蒲悦蓉. All rights reserved.
//

#import "LandViewController.h"
#import "RegisterViewController.h"

@interface LandViewController ()
@property UITextField *nameTextFiled;
@property UITextField *psdTextFiled;
@property NSString *nameStr;
@property NSString *psdStr;
@property UIButton *psdButton;
@end

@implementation LandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *view = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [view setImage:[UIImage imageNamed:@"landback2.PNG"]];
    [self.view addSubview:view];
    
    _nameTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(150, 280, 200, 50)];
    _nameTextFiled.tag = 1;
    _psdTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(150, 350, 200, 50)];
    _psdTextFiled.tag = 2;
    _nameTextFiled.backgroundColor = [UIColor colorWithRed:0.49f green:0.64f blue:0.93f alpha:1.00f];
    _nameTextFiled.alpha = 1;
    _psdTextFiled.alpha = 1;
    _psdTextFiled.backgroundColor = [UIColor colorWithRed:0.49f green:0.64f blue:0.93f alpha:1.00f];
    _nameTextFiled.placeholder = @"请输入用户名";
    _psdTextFiled.placeholder = @"请输入密码";
    _nameTextFiled.keyboardType = UIKeyboardTypeDefault;
    _psdTextFiled.keyboardType = UIKeyboardTypeDefault;
    [_psdTextFiled addTarget:self action:@selector(pressChange) forControlEvents:UIControlEventEditingChanged];
    _psdTextFiled.secureTextEntry = YES;
    _nameTextFiled.font = [UIFont systemFontOfSize:22];
    _psdTextFiled.font = [UIFont systemFontOfSize:22];
    _nameTextFiled.delegate = self;
    _psdTextFiled.delegate = self;
    [self.view addSubview:_nameTextFiled];
    [self.view addSubview:_psdTextFiled];
    
    _psdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"psd0.PNG"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_psdButton setImage:image forState:UIControlStateNormal];
    [_psdButton setFrame:CGRectMake(10, 290, 100, 100)];
    [self.view addSubview:_psdButton];
    
    UIButton *landButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [landButton setTitle:@"登陆" forState:UIControlStateNormal];
    [landButton setFrame:CGRectMake(62, 460, 100, 30)];
    [landButton addTarget:self action:@selector(pressLand:) forControlEvents:UIControlEventTouchUpInside];
    [landButton setBackgroundColor:[UIColor colorWithRed:0.84f green:0.53f blue:0.55f alpha:1.00f]];
    [landButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    landButton.titleLabel.alpha = 1;
    landButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:landButton];
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setFrame:CGRectMake(250, 460, 100, 30)];
    [registerButton addTarget:self action:@selector(pressRegiste) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setBackgroundColor:[UIColor colorWithRed:0.84f green:0.53f blue:0.55f alpha:1.00f]];
    registerButton.titleLabel.alpha = 1;
    registerButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_nameTextFiled resignFirstResponder];
    [_psdTextFiled resignFirstResponder];
    UIImage *image = [UIImage imageNamed:@"psd0.PNG"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_psdButton setImage:image forState:UIControlStateNormal];
}
- (void)pressChange
{
    UIImage *image = [UIImage imageNamed:@"psd1.PNG"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_psdButton setImage:image forState:UIControlStateNormal];
}


- (void)pressRegiste {
    RegisterViewController *reVC = [[RegisterViewController alloc] init];
    reVC.delegate = self;
    reVC.nameTextFiled.text = self.nameTextFiled.text;
    reVC.psdTextFiled.text = self.psdTextFiled.text;
    [self presentViewController:reVC animated:YES completion:nil];
}

- (void)pushName:(NSString *)nameStr pushPsd:(NSString *)psdStr
{
    _nameTextFiled.text = nameStr;
    _nameStr = nameStr;
    _psdTextFiled.text = psdStr;
    _psdStr = psdStr;
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
