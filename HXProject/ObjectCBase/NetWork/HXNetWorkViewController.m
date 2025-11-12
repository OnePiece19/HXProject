//
//  HXNetWorkViewController.m
//  HXProject
//
//  Created by hx on 2023/3/16.
//

#import "HXNetWorkViewController.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"

@interface HXNetWorkViewController ()

@end

@implementation HXNetWorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
get:{
    //1.确定请求路径
    NSString * url_str = [NSString stringWithFormat:@"http://api.androidhive.info/volley/person_object.json"];
    NSURL *url = [NSURL URLWithString:url_str];
    //2.创建请求对象
    //请求对象内部默认已经包含了请求头和请求方法（GET）
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.获得会话对象
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //4.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            //6.解析服务器返回的数据
            //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"get--\n %@",dict);
        }
    }];
    //5.执行任务
    [dataTask resume];
}
    
post:{
    //1、请求地址
    NSURL *url = [NSURL URLWithString:@"http://tiku.t.eoffcn.com/apiv3/user/register/login"];
    //2、创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    //3、设置请求参数
    //关于parameters是NSDictionary拼接后的NSString.关于拼接看后面拼接方法说明
    NSDictionary * param = @{@"phone":@"15201010075",
                             @"format":@"form",
                             @"passwd":@"96e79218965eb72c92a549dd5a330112",
                             @"device_id":@"983464FF20334E899C717D4CFE1F97C2",
                             @"channel_id":@"141fe1da9ee82816cc1",
                             @"system":@"12.2",
                             @"platform":@"iphone",
                             @"passcode":@"111111",
                             @"version":@"3.2.0",
                             @"sign":@"6c8f55f7a1c78f21ad7797d6a95f3cee",
                             @"appid":@"tiku"
    };
    NSString * parameters = [self parameters:param];
    request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    //4、设置请求session
    NSURLSession *session = [NSURLSession sharedSession];
    //5、设置网络请求的返回接收器
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            //6.解析服务器返回的数据
            //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"post--\n %@",dict);
        }
    }];
   //开始请求
   [dataTask resume];
}
    
    // 使用AFNetWorking发送get请求
AFGet:{
    
    NSString * url_str = [NSString stringWithFormat:@"http://api.androidhive.info/volley/person_object.json"];
    
    [[AFHTTPSessionManager manager] GET:url_str parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"AFGet --\n %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
    
    
    UIImageView * imageV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageV];
    
    NSString * urlStr = @"https://t8.baidu.com/it/u=1484500186,1503043093&fm=79&app=86&size=h300&n=0&g=4n&f=jpeg?sec=1601541987&t=928ea83a7dff0a6d9f082e8785ecf9ee";
    [imageV setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
}


/**
 拼接字典数据

 @param parameters 参数
 @return 拼接后的字符串
 */
-(NSString *)parameters:(NSDictionary *)parameters
{
    //创建可变字符串来承载拼接后的参数
    NSMutableString *parameterString = [NSMutableString new];
    //获取parameters中所有的key
    NSArray *parameterArray = parameters.allKeys;
    for (int i = 0;i < parameterArray.count;i++) {
    //根据key取出所有的value
        id value = parameters[parameterArray[i]];
    //把parameters的key 和 value进行拼接
        NSString *keyValue = [NSString stringWithFormat:@"%@=%@",parameterArray[i],value];
        if (i == parameterArray.count || i == 0) {
        //如果当前参数是最后或者第一个参数就直接拼接到字符串后面，因为第一个参数和最后一个参数不需要加 “&”符号来标识拼接的参数
            [parameterString appendString:keyValue];
        }else
        {
        //拼接参数， &表示与前面的参数拼接
            [parameterString appendString:[NSString stringWithFormat:@"&%@",keyValue]];
        }
    }
    return parameterString;
}



@end
