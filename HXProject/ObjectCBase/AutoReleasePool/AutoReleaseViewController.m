//
//  AutoReleaseViewController.m
//  HXProject
//
//  Created by HX on 2021/8/18.
//

#import "AutoReleaseViewController.h"
#import "AutoReleaseObject.h"

extern void _objc_autoreleasePoolPrint(void);


@interface AutoReleaseViewController (){
    __weak id _testObject;
    NSThread *_testThread;
}

@property (nonatomic, weak) NSString * obj;

@end

@implementation AutoReleaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
        
    _testThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(testBuild)
                                                     object:nil];
    [_testThread start];
    
    NSLog(@"%@",_obj);
}
- (void)testBuild{
//    AutoReleaseObject * p = _testObject;
    [NSThread sleepForTimeInterval:3];
    
    NSString *str = [NSString stringWithFormat:@"%@", @"sajkdjaskldaskdjasldjlasjkdasdas"];
    
    
    NSLog(@"子线程结束 %@",str);
}
#warning todo

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear : %@", _testObject);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear : %@", _testObject);
}

- (void)testButton{
    NSLog(@"testButton : %@", _testObject);
}

@end
