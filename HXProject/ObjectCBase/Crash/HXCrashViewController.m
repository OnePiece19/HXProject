//
//  HXCrashViewController.m
//  HXProject
//
//  Created by HX on 2021/9/9.
//

#import "HXCrashViewController.h"

@interface HXCrashViewController ()

@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation HXCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor cyanColor];
    
    self.dataArray = @[@"a",@"b",@"c",@"d",@"e"];
}


- (IBAction)didClickArrayException:(UIButton *)sender {
    NSLog(@"%@",self.dataArray[10]);
    
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
