//
//  HXHomeViewController.m
//  HXProject
//
//  Created by HX on 2021/8/13.
//

#import "HXHomeViewController.h"
#import <HXLeetCode/TouchNum.h>


@interface HXHomeViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation HXHomeViewController

#define HTLog(_var) \
{ \
    NSString *name = @#_var; \
    NSLog(@"%@: %p, %@,", name, _var, [_var class]); \
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [TouchNum new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    NSString *a = @"a";
//    NSMutableString *b = [a mutableCopy];
//    NSString *c = [a copy];
//    NSString *d = [[a mutableCopy] copy];
//    NSString *e = [NSString stringWithString:a];
//    NSString *f = [NSString stringWithFormat:@"f"];
//    NSString *string1 = [NSString stringWithFormat:@"abcdefg"];
//    NSString *string2 = [NSString stringWithFormat:@"abcdefghi"];
//    NSString *string3 = [NSString stringWithFormat:@"abcdefghij"];
//    HTLog(a);
//    HTLog(b);
//    HTLog(c);
//    HTLog(d);
//    HTLog(e);
//    HTLog(f);
//    HTLog(string1);
//    HTLog(string2);
//    HTLog(string3);
//
//    NSLog(@"%d",[string1 isKindOfClass:[NSString class]]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellID = @"mainCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    cell.textLabel.text = [_dataSource[indexPath.row] objectForKey:@"title"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item =  _dataSource[indexPath.row];
    Class cls = NSClassFromString([item objectForKey:@"class"]);
    UIViewController * vc = (UIViewController *)[[cls alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[
                        @{
                            @"title" : @"KVC",
                            @"class" : @"KVCViewController"
                            },
                        @{
                            @"title" : @"KVC crash test",
                            @"class" : @"TestKVCCrashVC"
                            },
                        @{
                            @"title" : @"KVO",
                            @"class" : @"KVOViewController"
                            },
                        @{
                            @"title" : @"KVO crash test",
                            @"class" : @"TestKVOCrashVC"
                            },
                        @{
                            @"title" : @"Auto release test",
                            @"class" : @"AutoReleaseViewController"
                            },
                        @{
                            @"title" : @"Run Time",
                            @"class" : @"HXRunTimeViewController"
                            },
                        @{
                            @"title" : @"Crash 分析",
                            @"class" : @"HXCrashViewController"
                            },
                        @{
                            @"title" : @"MVVM",
                            @"class" : @"HXMVVMViewController"
                            }
                        ];
    }
    return _dataSource;
}

@end
