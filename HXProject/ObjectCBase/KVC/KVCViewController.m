//
//  KVCViewController.m
//  HXProject
//
//  Created by HX on 2021/8/12.
//

#import "KVCViewController.h"
#import "KVCPerson.h"

@interface KVCViewController ()

/*
 * KVC全称是Key Value Coding(键值编码)，是一个基于NSKeyValueCoding非正式协议实现 的机制，它可以直接通过key值对对象的属性进行存取操作，而不需通过调用明确的存取方 法。这样就可以在运行时动态在访问和修改对象的属性，而不是在编译时确定。
 * KVC提供了一种间接访问属性方法或成员变量的机制，可以通过字符串来访问对象的的属性方法或成员变量。
 * KVC本质上是操作方法列表以及在内存中查找实例变量
 * 在实现了访问器方法的类中，使用点语法和KVC访问对象其实差别不大，二者可以任意混用 (因为KVC会首先搜索访问器方法，见下文)。但是没有访问器方法的类中，点语法无法使 用，这时KVC就有优势了。
 * KVC和KVO都是基于OC的动态特性和Runtime机制的。
 * 我们不能直接将基本数据类型通过KVC赋值，需要把数据转成NSNumber或NSValue类型传入

 * KVC设值、KVC取值、KVC使用keyPath、KVC处理异常、KVC处理数值和结构体类型属性、KVC键值验证（Key-Value Validation）、KVC处理集合、KVC处理字典
 */

@end

@implementation KVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self getsetVar];
    
    [self getsetPrivateVar];
    
    [self getsetMutableVar];
    
    [self handleSetArray];
    
    [self validateKVC];
}

// KVC 取值、设值 、keyPath、
- (void)getsetVar {
    KVCPerson * myself = [KVCPerson new];
    
    [myself setValue:@"Iron Man" forKey:@"name"];
    NSString * name = [myself valueForKey:@"name"];
    NSLog(@"name = %@",name);
    
    //注意，这⾥里里要想使⽤用keypath对adress的属性进⾏行行赋值，必须先给myself赋⼀一个Address对象
    KVCAddress *myAddress = [[KVCAddress alloc] init];
    [myself setValue:myAddress forKey:@"address"];
    
    [myself setValue:@"BeiJing" forKeyPath:@"address.city"];
    NSString * city = [myself valueForKeyPath:@"address.city"];
    NSLog(@"city = %@",city);
}

// 访问私有成员变量
- (void)getsetPrivateVar {
    // 这个操作对readonly的属性，@protected的成员变量，都可以正常访问。如果不想让外界访问类 的成员变量，则可以将accessInstanceVariablesDirectlygetter方法返回为NO。
    KVCPerson * myself = [KVCPerson new];
    [myself setValue:@"privateVar" forKey:@"privateVar"];
    [myself setValue:@"privateProperty" forKey:@"privateProperty"];
    
    NSLog(@"%@",[myself valueForKey:@"privateVar"]);
    NSLog(@"%@",[myself valueForKey:@"privateProperty"]);
}

// KVC多值操作、KVC 字典转模型
- (void)getsetMutableVar {
    KVCPerson * myself = [KVCPerson new];
    KVCAddress *myAddress = [[KVCAddress alloc] init];
    //批量量赋值
    NSDictionary *dic = @{@"name":@"xiaoMing",
                          @"sex":@1,
                          @"age":@12,
                          @"address":myAddress};
    
    [myself setValuesForKeysWithDictionary:dic];
    
    //批量量取值
    NSArray *keys = @[@"name",@"age",@"sex",@"address"];
    
    NSDictionary *values = [myself dictionaryWithValuesForKeys:keys];
    NSLog(@"%@",values);
    /*
     * Json里的字段数量和字段名字应该和model类所匹配，Json少了字段不会出现问题，但 是多了或者是字段名不对，就会崩溃。
     * 不需对基本数据类型做处理，例如int型转NSNumber，内部会自动作出处理
     * NSArray和NSDictionary等集合对象，value都不能是nil，否则会导致Crash
     */

    NSDictionary *dicJson = @{@"name":@"Iron Man",
                              @"sex":@1,
                              @"Age":@30,
                              @"address":myAddress};
    [myself setValuesForKeysWithDictionary:dicJson];
}

// KVC 集合属性操作
- (void)handleSetArray {

    //1. 集合操作符
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        KVCAddress * address = [[KVCAddress alloc] init];
        NSString *cityStr = [NSString stringWithFormat:@"city-%d",i];
        //批量量赋值
        NSDictionary *dic = @{@"city":cityStr,
                              @"street":@"street",
                              @"cityNumber":@(i),
                              @"streetNumber":@101 };
        [address setValuesForKeysWithDictionary:dic];
        [array addObject:address];
    }
    
    //返回数组中保存的对象的属性，返回值为数组
    NSArray *cityArray = [array valueForKeyPath:@"city"];
    NSLog(@"%@",cityArray);
    
    //@avg:平均值
    NSNumber *avg = [array valueForKeyPath:@"@avg.streetNumber"];
    NSLog(@"%@",avg);

    //@count:集合⾥里里对象的数量量
    NSNumber *count = [array valueForKeyPath:@"@count"];
    NSLog(@"%@",count);
      
    //@sum:总和
    NSNumber *sum = [array valueForKeyPath:@"@sum.streetNumber"];
    NSLog(@"%@",sum);
    
    //@max:最⼤大值
    NSNumber *max = [array valueForKeyPath:@"@max.cityNumber"];
    NSLog(@"%@",max);
    
    //@min:最⼩小值
    NSNumber *min = [array valueForKeyPath:@"@min.cityNumber"];
    NSLog(@"%@",min);
    
    //2. 数组操作符
    
    //@unionOfObjects将集合中的所有对象的同一个属性放在数组中返回
    NSArray *unionOfObjectCity = [array valueForKeyPath:@"@unionOfObjects.city"];
    NSLog(@"%@",unionOfObjectCity);
    
    NSArray *cityArrayOther = [array valueForKeyPath:@"city"];
    NSLog(@"%@",cityArrayOther);
    //@distinctUnionOfObjects将集合中对象的属性进行去重并返回
    NSArray *streetNumberArr = [array valueForKeyPath:@"@distinctUnionOfObjects.streetNumber"];
    NSLog(@"%@",streetNumberArr);
    
    //3. 嵌套操作符
    NSMutableArray *array2 = [NSMutableArray array];
    
    for (int i = 3; i < 9; i++) {
        KVCAddress * address = [[KVCAddress alloc] init];
        NSString *cityStr = [NSString stringWithFormat:@"city-%d",i];
        //批量量赋值
        NSDictionary *dic = @{@"city":cityStr,
                              @"street":@"street",
                              @"cityNumber":@(i),
                              @"streetNumber":@101 };
        [address setValuesForKeysWithDictionary:dic];
        [array2 addObject:address];
    }
    
    NSArray *unionArray = @[array,array2];
    
    // @unionOfArrays是用来操作集合内部的集合，将所有rightkeyPath对应的属性放在一个数组 中返回。
    NSArray *result1 = [unionArray valueForKeyPath:@"@unionOfArrays.city"];
    NSLog(@"%@",result1);
    // @distinctUnionOfArrays是用来操作集合内部的集合对象，将所有rightkeyPath对应的对象放 在一个数组中，并进行排重。
    NSArray *result2 = [unionArray valueForKeyPath:@"@distinctUnionOfArrays.city"];
    NSLog(@"%@",result2);
    // @distinctUnionOfSets是用来操作集合内部的集合对象，将所有rightkeyPath对应的对象放在一个set中，并进行排重。
//    NSSet * result3 = [unionArray valueForKeyPath:@"@distinctUnionOfSets.city"];
//    NSLog(@"%@",result3);
    
//    如果你想对集合里装的对象直接进行操作，可以将 right keyPath 直接写为 self。比如集合里装
//    的是NSNumber对象
}

#pragma mark - KVC 的搜索规则
    
    /* 基础Getter搜索模式
     1. 先找相应的getter方法(get<Key>,<key>,is<Key>,或者_<key>)，找到了则返回 (对象类型直接返回，其它类型进行转换);
     2. 没有找到，则寻找NSArray相应的方法;
     3. 没有找到，则寻找NSSet相应的方法;
     4. 如果还没有，且accessInstanceVariablesDirectly类属性返回的是YES，则去搜索实例
     变量(_<key>、_is<Key>、<key>、is<Key>)。如果发现了，则返回;
     5. 还没有，则转到valueForUndefinedKey:方法并抛出异常。
     */
    
    /* 基础Setter搜索模式
     1. 先找setter方法(set<Key>:或_set<Key>);
     2. 没找到，如果则accessInstanceVariablesDirectly类属性返回的是YES，则去查找实 例变量(_<key>、_is<Key>、<key>、is<Key>)，若找到，则赋值;
     3. 没有找到setter方法和实例变量，则转到setValue:forUndefinedKey:方法，并抛出 异常。
     */
#pragma mark - KVC 属性验证
- (void)validateKVC {
    /*
     在调用 KVC 前可以先进行验证 key(keyPath) 和 value 的正确性，验证通过下面两个方法进 行。验证方法默认实现返回 YES，可以通过重写对应的方法修改验证逻辑。
     注意:验证方法需要我们手动调用，并不会在进行 KVC 的过程中自动调用。
     */
    /*
    //key⽅方法
    - (BOOL)validateValue:(inout id _Nullable * _Nonnull)ioValue forKey:(NSString *)inKey error:(out NSError **)outError;
    
    //keyPath⽅方法
    - (BOOL)validateValue:(inout id _Nullable * _Nonnull)ioValueforKeyPath:(NSString *)inKeyPath error:(out NSError **)outError;
     */
    KVCPerson *person = [[KVCPerson alloc] init];
    
    NSNumber *age = @10;
    NSError* error;
    NSString *key = @"ageerror";
    BOOL isValid = [person validateValue:&age forKey:key error:&error];
    if (isValid) {
        NSLog(@"键值匹配");
        [person setValue:age forKey:key];
    } else {
        NSLog(@"键值不匹配");
    }
}

#pragma mark - KVC 异常信息和异常处理
    /*
     * 给某个非对象的属性赋值为 nil 时,会抛出 NSInvalidArgumentException 的异常并崩溃。
     */
//  - (nullable id)valueForUndefinedKey:(NSString *)key;
//  - (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;
//  - (void)setNilValueForKey:(NSString *)key;

- (void)testKVCCrash {
    //    1. key 不是对象的属性，造成崩溃
    //    [self testKVCCrash1];
    //    2. keyPath 不正确，造成崩溃
    //    [self testKVCCrash2];
    //    3. key 为 nil，造成崩溃
    //    [self testKVCCrash4];
    //    4. value 为 nil，为非对象设值，造成崩溃
    //    [self testKVCCrash4];
}


// 1. key 不是对象的属性，造成崩溃
- (void)testKVCCrash1 {
    // 崩溃日志：[<KVCCrashObject 0x600000d48ee0> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key XXX.;
    KVCPerson *person = [[KVCPerson alloc] init];
    [person setValue:@"152XXXX" forKey:@"phoneNum"];
}
// 2. keyPath 不正确，造成崩溃
- (void)testKVCCrash2 {
    // 崩溃日志：[<KVCCrashObject 0x60000289afb0> valueForUndefinedKey:]: this class is not key value coding-compliant for the key XXX.
    KVCPerson *person = [[KVCPerson alloc] init];
    [person setValue:@"中国" forKeyPath:@"address.country"];
}
// 3. key 为 nil，造成崩溃
- (void)testKVCCrash3 {
    // 崩溃日志：'-[KVCCrashObject setValue:forKey:]: attempt to set a value for a nil key
    NSString *keyName;
    // key 为 nil 会崩溃，如果传 nil 会提示警告，传空变量则不会提示警告
    KVCPerson *person = [[KVCPerson alloc] init];
    [person setValue:@"value" forKey:keyName];
}
// 4. value 为 nil，造成崩溃
- (void)testKVCCrash4 {
    // 崩溃日志：[<KVCCrashObject 0x6000028a6780> setNilValueForKey]: could not set nil as the value for the key XXX.
    // value 为 nil 会崩溃
    KVCPerson *person = [[KVCPerson alloc] init];
    [person setValue:nil forKey:@"age"];
}
    

@end
