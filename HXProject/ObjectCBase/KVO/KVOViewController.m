//
//  KVOViewController.m
//  HXProject
//
//  Created by HX on 2021/8/14.
//

#import "KVOViewController.h"
#import "KVOPerson.h"

@interface KVOViewController ()

@property (nonatomic, strong) KVOPerson * person;

@end

@implementation KVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [KVOPerson new];
    /* 1、注册方法
     ** target：  被观察对象
     ** observer：观察者对象
     ** keyPath： 被观察对象的属性的关键路径，不能为nil
     ** options： 观察的配置选项，包括观察的内容（枚举类型）：
               NSKeyValueObservingOptionNew：观察新值
               NSKeyValueObservingOptionOld：观察旧值
               NSKeyValueObservingOptionInitial：观察初始值，如果想在注册观察者后，立即接收一次回调，可以加入该枚举值
               NSKeyValueObservingOptionPrior：分别在值改变前后触发方法（即一次修改有两次触发）
     ** context： 可以传入任意数据（任意类型的对象或者C指针），在监听方法中可以接收到这个数据，是KVO中的一种传值方式
                 如果传的是一个对象，必须在移除观察之前持有它的强引用，否则在监听方法中访问context就可能导致Crash
     */
    
    // 监听属性
    [self.person addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    // 监听集合
    [self.person addObserver:self forKeyPath:@"mArray" options:(NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld) context:NULL];
    
    [self.person addObserver:self forKeyPath:@"privateVar" options:(NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld) context:NULL];
    
    [self.person addObserver:self forKeyPath:@"privateProperty" options:(NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld) context:NULL];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"keyPath:%@",keyPath);    // keyPath:name
    NSLog(@"object:%@",object);      // object:<KVOPerson: 0x6000023dc7c0>
    NSLog(@"change:%@",change);      // change:{ kind = 1; new = "张三"; old = "<null>"; }
    NSLog(@"context:%@",context);    // context:(null)
    
    /*
     ** keyPath：被观察对象的属性的关键路径
     ** object： 被观察对象
     ** change： 字典 NSDictionary<NSKeyValueChangeKey, id>，属性值更改的详细信息，根据注册方法中options参数传入的枚举来返回
                 key为 NSKeyValueChangeKey 枚举类型
                 {
                     1.NSKeyValueChangeKindKey：存储本次改变的信息（change字典中默认包含这个key）
                     {
                         对应枚举类型 NSKeyValueChange
                         typedef NS_ENUM(NSUInteger, NSKeyValueChange) {
                             NSKeyValueChangeSetting     = 1,
                             NSKeyValueChangeInsertion   = 2,
                             NSKeyValueChangeRemoval     = 3,
                             NSKeyValueChangeReplacement = 4,
                         };
                         如果是对被观察对象属性（包括集合）进行赋值操作，kind 字段的值为 NSKeyValueChangeSetting
                         如果被观察的是集合对象，且进行的是（插入、删除、替换）操作，则会根据集合对象的操作方式来设置 kind 字段的值
                             插入：NSKeyValueChangeInsertion
                             删除：NSKeyValueChangeRemoval
                             替换：NSKeyValueChangeReplacement
                     }
                     2.NSKeyValueChangeNewKey：存储新值（如果options中传入NSKeyValueObservingOptionNew，change字典中就会包含这个key）
                     3.NSKeyValueChangeOldKey：存储旧值（如果options中传入NSKeyValueObservingOptionOld，change字典中就会包含这个key）
                     4.NSKeyValueChangeIndexesKey：如果被观察的是集合对象，且进行的是（插入、删除、替换）操作，则change字典中就会包含这个key，
                         这个key的value是一个NSIndexSet对象，包含更改关系中的索引
                     5.NSKeyValueChangeNotificationIsPriorKey：如果options中传入NSKeyValueObservingOptionPrior，则在改变前通知的change字典中会包含这个key。
                         这个key对应的value是NSNumber包装的YES，我们可以这样来判断是不是在改变前的通知[change[NSKeyValueChangeNotificationIsPriorKey] boolValue] == YES]
                 }
     ** context：注册方法中传入的context
     */
}

- (void)dealloc {
   [self.person removeObserver:self forKeyPath:@"name"];
}

#pragma mark - test kvo

- (IBAction)didClickChangeProperty:(UIButton *)sender {
    self.person.name= @"张三";
}

- (IBAction)didClickChangeSet:(UIButton *)sender {
    
//    [self.person.mArray addObject:@"2"]; //如果直接对数组进行操作，不会触发KVO
    
    NSMutableArray *array = [self.person mutableArrayValueForKey:@"mArray"];
    [array addObject:@"1"];
    [array replaceObjectAtIndex:0 withObject:@"2"];
    [array removeObjectAtIndex:0];
}

- (IBAction)didClickChangePrivateVar:(UIButton *)sender {
    
    [self.person setValue:@"李四" forKey:@"privateVar"];
    NSLog(@"%@",[self.person valueForKey:@"privateVar"]);
}

- (IBAction)didClickChangePrivateProperty:(UIButton *)sender {
    
    [self.person setValue:@"王五" forKey:@"privateProperty"];
    NSLog(@"%@",[self.person valueForKey:@"privateProperty"]);
}

@end
