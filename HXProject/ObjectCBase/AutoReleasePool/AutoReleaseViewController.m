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

// 新线程调用方法，里边为需要执行的任务
void * run(void *param) {
//    NSLog(@"%@", [NSThread currentThread]);
    for (int i = 0; i< 100000; i++) {
        NSString *str = [NSString stringWithFormat:@"%@", @"sajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdas"];
    }

    _objc_autoreleasePoolPrint();
    
    return NULL;
}

- (IBAction)didCLickBtn:(UIButton *)sender {
    
    pthread_t thread;
    // 开启线程——执行任务
    pthread_create(&thread, NULL, run, NULL);
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
//
//    NSLog(@"主线程 %@",[NSThread currentThread]);
//    _objc_autoreleasePoolPrint();
//    _testThread = [[NSThread alloc] initWithTarget:self
//                                                   selector:@selector(testBuild)
//                                                     object:nil];
//    [_testThread start];
    
    // 创建线程——定义一个pthread_t类型变量
       pthread_t thread;
       // 开启线程——执行任务
       pthread_create(&thread, NULL, run, NULL);
       /*
       pthread_create(&thread, NULL, run, NULL); 中各项参数含义：
       第一个参数&thread是线程对象
       第二个和第四个是线程属性，可赋值NULL
       第三个run表示指向函数的指针(run对应函数里是需要在新线程中执行的任务)
       */
    
    NSLog(@"%@",_obj);
}
- (void)testBuild{
//    AutoReleaseObject * p = _testObject;
//    [NSThread sleepForTimeInterval:3];
    NSLog(@"子线程 %@",[NSThread currentThread]);
    NSString *str = [NSString stringWithFormat:@"%@", @"sajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdassajkdjaskldaskdjasldjlasjkdasdas"];

    _objc_autoreleasePoolPrint();
//    NSLog(@"子线程结束 %@",str);
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
