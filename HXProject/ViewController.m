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


@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_titleArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleArray = @[
                    @{
                        @"title" : @"Unrecognized Selector Crash",
                        @"class" : @"TestUnrecognizedSelVC"
                        },
                    @{
                        @"title" : @"KVO Crash",
                        @"class" : @"TestKVOCrashVC"
                        },
                    @{
                        @"title" : @"KVC Crash",
                        @"class" : @"TestKVCCrashVC"
                        },
                    @{
                        @"title" : @"Notification Crash",
                        @"class" : @"TestNotificationCrashVC"
                        },
                    @{
                        @"title" : @"NSTimer Crash",
                        @"class" : @"TestTimerCrashVC"
                        },
                    @{
                        @"title" : @"Containers Crash",
                        @"class" : @"TestContainersVC"
                        },
                    @{
                        @"title" : @"NSNull Crash",
                        @"class" : @"TestNullVC"
                        }
                    ];
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellID = @"mainCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    cell.textLabel.text = [_titleArray[indexPath.row] objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item =  _titleArray[indexPath.row];
    Class cls = NSClassFromString([item objectForKey:@"class"]);
    [self presentViewController:[[cls alloc] init] animated:YES completion:nil];
}

/**
 * tableView初始化
 */
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeigh) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadingCompelete" object:nil userInfo:@{@"page":@(2)}];
}

@end
