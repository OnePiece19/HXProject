//
//  HXRunTimeViewController.m
//  HXProject
//
//  Created by HX on 2021/9/6.
//

#import "HXRunTimeViewController.h"

@interface LGPerson : NSObject
@property (nonatomic, retain) NSString *kc_name;
- (void)saySomething;
@end

@implementation LGPerson
- (void)saySomething{
    NSLog(@"%s - %@",__func__,self.kc_name);
}
@end




@interface HXRunTimeViewController ()

@end

@implementation HXRunTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    
    Class cls = [LGPerson class];
    void  *kc = &cls;
    [(__bridge id)kc saySomething];
    
    
    LGPerson *person = [LGPerson alloc];
    [person saySomething];
    
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
