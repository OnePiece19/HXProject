//
//  HXUIHomeViewController.m
//  HXProject
//
//  Created by HX on 2021/8/25.
//

#import "HXUIHomeViewController.h"
#import "HXEventTestViewController.h"
#import "OffScreenViewController.h"

@interface HXUIHomeViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation HXUIHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

    [self presentViewController:[[cls alloc] init] animated:YES completion:nil];
    
//    UIWindow * rootWindow =  [UIApplication sharedApplication].windows.firstObject;
//    HXEventTestViewController * eventVC = [[UIViewController alloc] initWithNibName:@"HXEventTestViewController" bundle:[NSBundle mainBundle]];
//
//    rootWindow.rootViewController = eventVC;
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
                            @"title" : @"Event Test",
                            @"class" : @"KVCViewController"
                            },
                        @{
                            @"title" : @"离屏渲染",
                            @"class" : @"OffScreenViewController"
                            },
                        @{
                            @"title" : @"UIViewController生命周期",
                            @"class" : @"LifeCycleViewController"
                            },
                        @{
                            @"title" : @"KVO crash test",
                            @"class" : @"TestKVOCrashVC"
                            },
                        @{
                            @"title" : @"Auto release test",
                            @"class" : @"AutoReleaseViewController"
                            }
                        
                        
                        ];
    }
    return _dataSource;
}


@end
