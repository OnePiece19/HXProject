//
//  RegisterViewController.h
//  StudentManageSyatem
//
//  Created by 蒲悦蓉 on 2019/8/7.
//  Copyright © 2019 蒲悦蓉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol RegisterViewControllerDelegate <NSObject>
- (void)pushName:(NSString*)nameStr pushPsd: (NSString*)psdStr;
@end
@interface RegisterViewController : UIViewController
<UITextFieldDelegate>
@property id<RegisterViewControllerDelegate>delegate;
@property UITextField *nameTextFiled;
@property UITextField *psdTextFiled;
@end

NS_ASSUME_NONNULL_END
