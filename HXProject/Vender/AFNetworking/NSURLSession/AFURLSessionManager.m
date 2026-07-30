// AFURLSessionManager.m
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFURLSessionManager.h"
#import <objc/runtime.h>

// 正在进行的队列
static dispatch_queue_t url_session_manager_processing_queue() {
    static dispatch_queue_t af_url_session_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_processing_queue = dispatch_queue_create("com.alamofire.networking.session.manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });

    return af_url_session_manager_processing_queue;
}
// 已经完成的组
static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t af_url_session_manager_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_completion_group = dispatch_group_create();
    });

    return af_url_session_manager_completion_group;
}

NSString * const AFNetworkingTaskDidResumeNotification = @"com.alamofire.networking.task.resume";
NSString * const AFNetworkingTaskDidCompleteNotification = @"com.alamofire.networking.task.complete";
NSString * const AFNetworkingTaskDidSuspendNotification = @"com.alamofire.networking.task.suspend";
NSString * const AFURLSessionDidInvalidateNotification = @"com.alamofire.networking.session.invalidate";
NSString * const AFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification = @"com.alamofire.networking.session.download.file-manager-succeed";
NSString * const AFURLSessionDownloadTaskDidFailToMoveFileNotification = @"com.alamofire.networking.session.download.file-manager-error";

NSString * const AFNetworkingTaskDidCompleteSerializedResponseKey = @"com.alamofire.networking.task.complete.serializedresponse";
NSString * const AFNetworkingTaskDidCompleteResponseSerializerKey = @"com.alamofire.networking.task.complete.responseserializer";
NSString * const AFNetworkingTaskDidCompleteResponseDataKey = @"com.alamofire.networking.complete.finish.responsedata";
NSString * const AFNetworkingTaskDidCompleteErrorKey = @"com.alamofire.networking.task.complete.error";
NSString * const AFNetworkingTaskDidCompleteAssetPathKey = @"com.alamofire.networking.task.complete.assetpath";
NSString * const AFNetworkingTaskDidCompleteSessionTaskMetrics = @"com.alamofire.networking.complete.sessiontaskmetrics";

static NSString * const AFURLSessionManagerLockName = @"com.alamofire.networking.session.manager.lock";

typedef void (^AFURLSessionDidBecomeInvalidBlock)(NSURLSession *session, NSError *error);
typedef NSURLSessionAuthChallengeDisposition (^AFURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);

typedef NSURLRequest * (^AFURLSessionTaskWillPerformHTTPRedirectionBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request);
typedef NSURLSessionAuthChallengeDisposition (^AFURLSessionTaskDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
typedef id (^AFURLSessionTaskAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, void (^completionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential));
typedef void (^AFURLSessionDidFinishEventsForBackgroundURLSessionBlock)(NSURLSession *session);

typedef NSInputStream * (^AFURLSessionTaskNeedNewBodyStreamBlock)(NSURLSession *session, NSURLSessionTask *task);
typedef void (^AFURLSessionTaskDidSendBodyDataBlock)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^AFURLSessionTaskDidCompleteBlock)(NSURLSession *session, NSURLSessionTask *task, NSError *error);
#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
typedef void (^AFURLSessionTaskDidFinishCollectingMetricsBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLSessionTaskMetrics * metrics) AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif

typedef NSURLSessionResponseDisposition (^AFURLSessionDataTaskDidReceiveResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response);
typedef void (^AFURLSessionDataTaskDidBecomeDownloadTaskBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);
typedef void (^AFURLSessionDataTaskDidReceiveDataBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);
typedef NSCachedURLResponse * (^AFURLSessionDataTaskWillCacheResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse);

typedef NSURL * (^AFURLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
typedef void (^AFURLSessionDownloadTaskDidWriteDataBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^AFURLSessionDownloadTaskDidResumeBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes);
typedef void (^AFURLSessionTaskProgressBlock)(NSProgress *);

typedef void (^AFURLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);

#pragma mark - *** 网络任务的代理类

@interface AFURLSessionManagerTaskDelegate : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, weak) AFURLSessionManager *manager;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSProgress *uploadProgress;
@property (nonatomic, strong) NSProgress *downloadProgress;
@property (nonatomic, copy) NSURL *downloadFileURL;
#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
@property (nonatomic, strong) NSURLSessionTaskMetrics *sessionTaskMetrics AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif
@property (nonatomic, copy) AFURLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@property (nonatomic, copy) AFURLSessionTaskProgressBlock uploadProgressBlock;
@property (nonatomic, copy) AFURLSessionTaskProgressBlock downloadProgressBlock;
@property (nonatomic, copy) AFURLSessionTaskCompletionHandler completionHandler;

- (instancetype)initWithTask:(NSURLSessionTask *)task;

@end

@implementation AFURLSessionManagerTaskDelegate

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _mutableData = [NSMutableData data];
    _uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    _downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    
    __weak __typeof__(task) weakTask = task;
    // 初始化 上传&下载Progress
    for (NSProgress *progress in @[ _uploadProgress, _downloadProgress ])
    {
        progress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        progress.cancellable = YES;
        progress.cancellationHandler = ^{
            [weakTask cancel];
        };
        progress.pausable = YES;
        progress.pausingHandler = ^{
            [weakTask suspend];
        };
#if AF_CAN_USE_AT_AVAILABLE
        if (@available(macOS 10.11, *))
#else
        if ([progress respondsToSelector:@selector(setResumingHandler:)])
#endif
        {
            progress.resumingHandler = ^{
                [weakTask resume];
            };
        }
        
        [progress addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }
    return self;
}

- (void)dealloc {
    [self.downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}

#pragma mark - NSProgress Tracking

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
   if ([object isEqual:self.downloadProgress]) {
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(object);
        }
    }
    else if ([object isEqual:self.uploadProgress]) {
        if (self.uploadProgressBlock) {
            self.uploadProgressBlock(object);
        }
    }
}

static const void * const AuthenticationChallengeErrorKey = &AuthenticationChallengeErrorKey;

#pragma mark - NSURLSessionTaskDelegate
// 1、*** 对应 8 被从urlsession那转发到这
- (void)URLSession:(__unused NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    error = objc_getAssociatedObject(task, AuthenticationChallengeErrorKey) ?: error;
    //强引用self.manager，防止被提前释放；因为self.manager声明为weak,类似Block
    __strong AFURLSessionManager *manager = self.manager;

    __block id responseObject = nil;

    //用来存储一些相关信息，来发送通知用的
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[AFNetworkingTaskDidCompleteResponseSerializerKey] = manager.responseSerializer;

    //Performance Improvement from #2672
    //注意这行代码的用法，感觉写的很Nice...把请求到的数据data传出去，然后就不要这个值了释放内存
    NSData *data = nil; // 数据
    
    if (self.mutableData) {
        data = [self.mutableData copy];
        //We no longer need the reference, so nil it out to gain back some memory.
        self.mutableData = nil;
    }

#if AF_CAN_USE_AT_AVAILABLE && AF_CAN_INCLUDE_SESSION_TASK_METRICS
    if (@available(iOS 10, macOS 10.12, watchOS 3, tvOS 10, *)) {
        if (self.sessionTaskMetrics) {
            userInfo[AFNetworkingTaskDidCompleteSessionTaskMetrics] = self.sessionTaskMetrics;
        }
    }
#endif
    //继续给userinfo填数据
    if (self.downloadFileURL) {
        userInfo[AFNetworkingTaskDidCompleteAssetPathKey] = self.downloadFileURL;
    } else if (data) {
        userInfo[AFNetworkingTaskDidCompleteResponseDataKey] = data;
    }
    //错误处理
    if (error) {
        userInfo[AFNetworkingTaskDidCompleteErrorKey] = error;
        //可以自己自定义完成组 和自定义完成queue,完成回调
        dispatch_group_async(manager.completionGroup ?: url_session_manager_completion_group(), manager.completionQueue ?: dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response, responseObject, error);
            }
            //主线程中发送完成通知
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidCompleteNotification object:task userInfo:userInfo];
            });
        });
    } else {
        //url_session_manager_processing_queue AF的并行队列
        //如果成功则在一个AF的并行queue中，即全局正在进行的队列，去做数据解析等后续操作：
        dispatch_async(url_session_manager_processing_queue(), ^{
            NSError *serializationError = nil;
            //解析数据
            responseObject = [manager.responseSerializer responseObjectForResponse:task.response data:data error:&serializationError];
            //如果是下载文件，那么responseObject为下载的路径
            if (self.downloadFileURL) {
                responseObject = self.downloadFileURL;
            }
            //写入userInfo
            if (responseObject) {
                userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey] = responseObject;
            }
            //如果解析错误
            if (serializationError) {
                userInfo[AFNetworkingTaskDidCompleteErrorKey] = serializationError;
            }
            //回调结果
            //这边还做了一个判断，如果自定义了GCD完成组completionGroup和完成队列的话completionQueue，会在加入这个组和在队列中回调Block。否则默认的是AF的创建的组，和主队列
            /*
             manager.completionGroup : 自定义完成组
             url_session_manager_completion_group() : AF定义的全局，已经完成的组
             manager.completionQueue : 自定义完成队列
             dispatch_get_main_queue() : AF默认主队列回调
             */
            dispatch_group_async(manager.completionGroup ?: url_session_manager_completion_group(), manager.completionQueue ?: dispatch_get_main_queue(), ^{
                NSLog(@"***** %@",[NSThread currentThread]);
                
                if (self.completionHandler) {
                    self.completionHandler(task.response, responseObject, serializationError);
                }
                // 回到主线程，发送了任务完成的通知：
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidCompleteNotification object:task userInfo:userInfo];
                });
            });
        });
    }
}

#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10)) {
    self.sessionTaskMetrics = metrics;
}
#endif

#pragma mark - NSURLSessionDataDelegate

// 2、 *** 对应 11 NSUrlSession代理转发到这里，拼接了需要回调的数据。
- (void)URLSession:(__unused NSURLSession *)session dataTask:(__unused NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    self.downloadProgress.totalUnitCount = dataTask.countOfBytesExpectedToReceive;
    self.downloadProgress.completedUnitCount = dataTask.countOfBytesReceived;
    // 拼接数据
    [self.mutableData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    self.uploadProgress.totalUnitCount = task.countOfBytesExpectedToSend;
    self.uploadProgress.completedUnitCount = task.countOfBytesSent;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    self.downloadProgress.totalUnitCount = totalBytesExpectedToWrite;
    self.downloadProgress.completedUnitCount = totalBytesWritten;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    self.downloadProgress.totalUnitCount = expectedTotalBytes;
    self.downloadProgress.completedUnitCount = fileOffset;
}

// 3、下载成功了被NSUrlSession代理转发到这里
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    self.downloadFileURL = nil;

    if (self.downloadTaskDidFinishDownloading) {
        //得到自定义下载路径
        self.downloadFileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (self.downloadFileURL) {
            //把下载路径移动到我们自定义的下载路径
            NSError *fileManagerError = nil;

            if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:self.downloadFileURL error:&fileManagerError]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:fileManagerError.userInfo];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification object:downloadTask userInfo:nil];
            }
        }
    }
}

@end

#pragma mark - 方法交换、动态添加方法

/**
 *  A workaround for issues related to key-value observing the `state` of an `NSURLSessionTask`.
 *
 *  See:
 *  - https://github.com/AFNetworking/AFNetworking/issues/1477
 *  - https://github.com/AFNetworking/AFNetworking/issues/2638
 *  - https://github.com/AFNetworking/AFNetworking/pull/2702
 */

static inline void af_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static inline BOOL af_addMethod(Class theClass, SEL selector, Method method) {
    return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
}

static NSString * const AFNSURLSessionTaskDidResumeNotification  = @"com.alamofire.networking.nsurlsessiontask.resume";
static NSString * const AFNSURLSessionTaskDidSuspendNotification = @"com.alamofire.networking.nsurlsessiontask.suspend";

#pragma mark - 交换系统Session类内部方法

//如果不要这个swizzle则问题不会再出现，但是这样会导致AF中很多UIKit的扩展都不能正常使用。
@interface _AFURLSessionTaskSwizzling : NSObject

@end

@implementation _AFURLSessionTaskSwizzling
//一级一级去获取父类，如果实现了resume方法，则进行替换。

+ (void)load {
    /**
     WARNING: Trouble Ahead
     https://github.com/AFNetworking/AFNetworking/pull/2702
     1、NSURLSessionTasks是一组class的统称，如果你仅仅使用提供的API来获取NSURLSessionTask的class，并不一定返回的是你想要的那个
     （获取NSURLSessionTask的class目的是为了获取其resume方法）
     2、简单地使用[NSURLSessionTask class]并不起作用。你需要新建一个NSURLSession，并根据创建的session再构建出一个NSURLSessionTask对象才行。
     3、iOS 7上，localDataTask（下面代码构造出的NSURLSessionDataTask类型的变量，为了获取对应Class）的类型是 __NSCFLocalDataTask，__NSCFLocalDataTask继承自__NSCFLocalSessionTask，__NSCFLocalSessionTask继承自__NSCFURLSessionTask。
     4、iOS8上，localDataTask的类型为__NSCFLocalDataTask，__NSCFLocalDataTask继承自__NSCFLocalSessionTask，__NSCFLocalSessionTask继承自NSURLSessionTask
     5、iOS7上，__NSCFLocalSessionTask和__NSCFURLSessionTask是仅有的两个实现了resume和suspend方法的类，另外__NSCFLocalSessionTask中的resume和suspend并没有调用其父类（即__NSCFURLSessionTask）方法，这也意味着两个类的方法都需要进行method swizzling。
     6、iOS 8上，NSURLSessionTask是唯一实现了resume和suspend方法的类。这也意味着其是唯一需要进行method swizzling的类
     因为NSURLSessionTask并不是在每个iOS版本中都存在，所以把这些放在此处（即load函数中），比如给一个dummy class添加swizzled方法都会变得很方便，管理起来也方便。
     */

    // 0)判断是否存在 NSURLSessionTask 类
    if (NSClassFromString(@"NSURLSessionTask")) {
        // 1) 首先构建一个NSURLSession对象session，再通过session构建出一个_NSCFLocalDataTask变量
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *localDataTask = [session dataTaskWithURL:nil];
#pragma clang diagnostic pop
        // 2) 获取到af_resume实现的指针
        IMP originalAFResumeIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(af_resume)));
        Class currentClass = [localDataTask class];
        // 3) 检查当前class是否实现了resume。如果实现了，继续第4步。
        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            // 4) 获取到当前class的父类（superClass）
            Class superClass = [currentClass superclass];
            // 5) 获取到当前class对于resume实现的指针
            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            // 6) 获取到父类对于resume实现的指针
            IMP superclassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            // 7) 如果当前class对于resume的实现和父类不一样（类似iOS7上的情况），并且当前class的resume实现和af_resume不一样，才进行method swizzling。
            /*
             首先可以注意class_getInstanceMethod这个方法，它会获取到当前类继承链逐级往上，第一个实现的该方法。所以说它获取到的方法不能确定是当前类还是父类的。而且这里也没有用dispatch_once_t来保证一个方法只交换一次，那万一这是父类的方法，当前类换一次，父类又换一次，不是等于没交换么？...请注意这行判断：
             */
            if (classResumeIMP != superclassResumeIMP && originalAFResumeIMP != classResumeIMP) {
                //执行交换的函数
                [self swizzleResumeAndSuspendMethodForClass:currentClass];
            }
            // 8) 设置当前操作的class为其父类class，重复步骤3~8
            currentClass = [currentClass superclass];
        }
        
        [localDataTask cancel];
        [session finishTasksAndInvalidate];
    }
}
//其引用的交换的函数
+ (void)swizzleResumeAndSuspendMethodForClass:(Class)theClass {
    Method afResumeMethod = class_getInstanceMethod(self, @selector(af_resume));
    Method afSuspendMethod = class_getInstanceMethod(self, @selector(af_suspend));
//    那iOS7两个类都交换了af_resume，那岂不是父类换到子类方法了?...只能说又是没仔细看代码的...注意AF是去向当前类添加af_resume方法，然后去交换当前类的af_resume。所以说根本不会出现这种情况...
    if (af_addMethod(theClass, @selector(af_resume), afResumeMethod)) {
        af_swizzleSelector(theClass, @selector(resume), @selector(af_resume));
    }
    if (af_addMethod(theClass, @selector(af_suspend), afSuspendMethod)) {
        af_swizzleSelector(theClass, @selector(suspend), @selector(af_suspend));
    }
}

- (NSURLSessionTaskState)state {
    NSAssert(NO, @"State method should never be called in the actual dummy class");
    return NSURLSessionTaskStateCanceling;
}

- (void)af_resume {
    NSAssert([self respondsToSelector:@selector(state)], @"Does not respond to state");
    NSURLSessionTaskState state = [self state];
    [self af_resume];
    
    if (state != NSURLSessionTaskStateRunning) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNSURLSessionTaskDidResumeNotification object:self];
    }
}

- (void)af_suspend {
    NSAssert([self respondsToSelector:@selector(state)], @"Does not respond to state");
    NSURLSessionTaskState state = [self state];
    [self af_suspend];
    
    if (state != NSURLSessionTaskStateSuspended) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNSURLSessionTaskDidSuspendNotification object:self];
    }
}

@end

#pragma mark -

@interface AFURLSessionManager ()
@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;
@property (readonly, nonatomic, copy) NSString *taskDescriptionForSessionTasks;
@property (readwrite, nonatomic, strong) NSLock *lock;


// 一大堆的session代理---> NSURLSessionDelegate、NSURLSessionTaskDelegate、NSURLSessionDataDelegate、NSURLSessionDownloadDelegate

@property (readwrite, nonatomic, copy) AFURLSessionDidBecomeInvalidBlock sessionDidBecomeInvalid;
@property (readwrite, nonatomic, copy) AFURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;
@property (readwrite, nonatomic, copy) AFURLSessionDidFinishEventsForBackgroundURLSessionBlock didFinishEventsForBackgroundURLSession AF_API_UNAVAILABLE(macos);
@property (readwrite, nonatomic, copy) AFURLSessionTaskWillPerformHTTPRedirectionBlock taskWillPerformHTTPRedirection;
@property (readwrite, nonatomic, copy) AFURLSessionTaskAuthenticationChallengeBlock authenticationChallengeHandler;
@property (readwrite, nonatomic, copy) AFURLSessionTaskNeedNewBodyStreamBlock taskNeedNewBodyStream;
@property (readwrite, nonatomic, copy) AFURLSessionTaskDidSendBodyDataBlock taskDidSendBodyData;
@property (readwrite, nonatomic, copy) AFURLSessionTaskDidCompleteBlock taskDidComplete;
#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
@property (readwrite, nonatomic, copy) AFURLSessionTaskDidFinishCollectingMetricsBlock taskDidFinishCollectingMetrics AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif
@property (readwrite, nonatomic, copy) AFURLSessionDataTaskDidReceiveResponseBlock dataTaskDidReceiveResponse;
@property (readwrite, nonatomic, copy) AFURLSessionDataTaskDidBecomeDownloadTaskBlock dataTaskDidBecomeDownloadTask;
@property (readwrite, nonatomic, copy) AFURLSessionDataTaskDidReceiveDataBlock dataTaskDidReceiveData;
@property (readwrite, nonatomic, copy) AFURLSessionDataTaskWillCacheResponseBlock dataTaskWillCacheResponse;
@property (readwrite, nonatomic, copy) AFURLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@property (readwrite, nonatomic, copy) AFURLSessionDownloadTaskDidWriteDataBlock downloadTaskDidWriteData;
@property (readwrite, nonatomic, copy) AFURLSessionDownloadTaskDidResumeBlock downloadTaskDidResume;

@end

@implementation AFURLSessionManager

- (instancetype)init {
    return [self initWithSessionConfiguration:nil];
}

#pragma mark - 核心配置方法

/*
1、self.operationQueue.maxConcurrentOperationCount = 1;这个operationQueue就是我们代理回调的queue。这里把代理回调的线程并发数设置为1了。

2、第二就是我们初始化了一些属性，其中包括self.mutableTaskDelegatesKeyedByTaskIdentifier字典，这个是用来让每一个请求task和我们自定义的AF代理来建立映射用的，其实AF对task的代理进行了一个封装，并且转发代理到AF自定义的代理，这是AF比较重要的一部分。

3、获取当前session的所有未完成的task，为了防止后台回来，重新初始化这个session，一些之前的后台请求任务，导致程序的crash。
 
 */
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }

    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }

    self.sessionConfiguration = configuration;
    // queue并发线程数为1，这个是代理回调的queue
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    // 各种响应转码
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    // ssl证书，是验证证书，还是公钥，还是不用
    self.securityPolicy = [AFSecurityPolicy defaultPolicy];

#if !TARGET_OS_WATCH
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
#endif
    // 设置存储NSURL task与AFURLSessionManagerTaskDelegate的词典（重点，在AFNet中，每一个task都会被匹配一个AFURLSessionManagerTaskDelegate 来做task的delegate事件处理）
    self.mutableTaskDelegatesKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];
    
    // 置AFURLSessionManagerTaskDelegate 词典的锁，确保词典在多线程访问时的线程安全
    self.lock = [[NSLock alloc] init];
    self.lock.name = AFURLSessionManagerLockName;
    
    // 为所管理的session的所有task设置完成块,此方法为生成session之后就调用
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        //开始的时候应该什么都没有
        for (NSURLSessionDataTask *task in dataTasks) {
            [self addDelegateForDataTask:task uploadProgress:nil downloadProgress:nil completionHandler:nil];
        }

        for (NSURLSessionUploadTask *uploadTask in uploadTasks) {
            [self addDelegateForUploadTask:uploadTask progress:nil completionHandler:nil];
        }

        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            [self addDelegateForDownloadTask:downloadTask progress:nil destination:nil completionHandler:nil];
        }
    }];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 核心创建 session

- (NSURLSession *)session {
    
    @synchronized (self) {
        if (!_session) {
            //注意代理，代理的继承，实际上NSURLSession去判断了，你实现了哪个方法会去调用，包括子代理的方法！
            /*
             self.operationQueue.maxConcurrentOperationCount = 1;
             1）首先我们要明确一个概念，这里的并发数仅仅是回调代理的线程并发数。而不是请求网络的线程并发数。请求网络是由NSUrlSession来做的，它内部维护了一个线程池，用来做网络请求。它调度线程,基于底层的CFSocket去发送请求和接收数据。这些线程是并发的。
             
             */
            _session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
            /* -- AFUrlSessionManager一共实现了如上图所示这么一大堆NSUrlSession相关的代理。

             ### `NSURLSessionDelegate`

             - `URLSession:didBecomeInvalidWithError:`
             - `URLSession:didReceiveChallenge:completionHandler:`
             - `URLSessionDidFinishEventsForBackgroundURLSession:`

             ### `NSURLSessionTaskDelegate`

             - `URLSession:willPerformHTTPRedirection:newRequest:completionHandler:`
             - `URLSession:task:didReceiveChallenge:completionHandler:`
             - `URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`
             - `URLSession:task:needNewBodyStream:`
             - `URLSession:task:didCompleteWithError:`<重要 转发-> AFURLSessionManagerTaskDelegate>

             ### `NSURLSessionDataDelegate`

             - `URLSession:dataTask:didReceiveResponse:completionHandler:`
             - `URLSession:dataTask:didBecomeDownloadTask:`
             - `URLSession:dataTask:didReceiveData:`
             - `URLSession:dataTask:willCacheResponse:completionHandler:`

             ### `NSURLSessionDownloadDelegate`

             - `URLSession:downloadTask:didFinishDownloadingToURL:`
             - `URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:`
             - `URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:`
             */
            
        }
    }
    return _session;
}

#pragma mark - task任务Resume和Suspend状态的通知方法

- (NSString *)taskDescriptionForSessionTasks {
    return [NSString stringWithFormat:@"%p", self];
}
// 对外发送taskDidResume通知
- (void)taskDidResume:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    if ([task respondsToSelector:@selector(taskDescription)]) {
        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidResumeNotification object:task];
            });
        }
    }
}
// 对外发送taskDidSuspend通知
- (void)taskDidSuspend:(NSNotification *)notification {
    NSURLSessionTask *task = notification.object;
    if ([task respondsToSelector:@selector(taskDescription)]) {
        if ([task.taskDescription isEqualToString:self.taskDescriptionForSessionTasks]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingTaskDidSuspendNotification object:task];
            });
        }
    }
}

#pragma mark - 根据task去《查询》delegate
- (AFURLSessionManagerTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);

    AFURLSessionManagerTaskDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];

    return delegate;
}

#pragma mark - 根据task去 《添加》delegate
- (void)setDelegate:(AFURLSessionManagerTaskDelegate *)delegate forTask:(NSURLSessionTask *)task {
    // 断言，如果没有这个参数，debug下crash在这
    NSParameterAssert(task);
    NSParameterAssert(delegate);
    
    // 加锁保证字典线程安全
    [self.lock lock];
    // 将AF delegate放入以taskIdentifier标记的词典中（同一个NSURLSessionTask中的taskIdentifier是唯一的）
    // 这个方法主要就是把AF代理和task建立映射，存在了一个我们事先声明好的字典里。
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
    
    // 添加task开始和暂停的通知
    [self addNotificationObserverForTask:task];
    
    [self.lock unlock];
}

#pragma mark - 根据task去《删除》delegate
- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);

    [self.lock lock];
    [self removeNotificationObserverForTask:task];
    [self.mutableTaskDelegatesKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

#pragma mark - 核心方法
- (void)addDelegateForDataTask:(NSURLSessionDataTask *)dataTask
                uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
              downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    /*
     总结一下:
     1）这个方法，生成了一个AFURLSessionManagerTaskDelegate,这个其实就是AF的自定义代理。我们请求传来的参数，都赋值给这个AF的代理了。
     2）delegate.manager = self;代理把AFURLSessionManager这个类作为属性了,我们可以看到：
     这个属性是弱引用的，所以不会存在循环引用的问题。
     3）我们调用了[self setDelegate:delegate forTask:dataTask];
     */

    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] initWithTask:dataTask];
    
    // AFURLSessionManagerTaskDelegate与AFURLSessionManager建立相互关系
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    
    // 这个taskDescriptionForSessionTasks用来发送开始和挂起通知的时候会用到,就是用这个值来Post通知，来两者对应
    dataTask.taskDescription = self.taskDescriptionForSessionTasks;
    
    // ***** 将AF delegate对象 与 dataTask建立关系 ******
    [self setDelegate:delegate forTask:dataTask];
    
    // 设置AF delegate的上传进度，下载进度块。
    delegate.uploadProgressBlock = uploadProgressBlock;
    delegate.downloadProgressBlock = downloadProgressBlock;
}

- (void)addDelegateForUploadTask:(NSURLSessionUploadTask *)uploadTask
                        progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
               completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] initWithTask:uploadTask];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;

    uploadTask.taskDescription = self.taskDescriptionForSessionTasks;

    [self setDelegate:delegate forTask:uploadTask];

    delegate.uploadProgressBlock = uploadProgressBlock;
}

- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                          progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                       destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    AFURLSessionManagerTaskDelegate *delegate = [[AFURLSessionManagerTaskDelegate alloc] initWithTask:downloadTask];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;

    if (destination) {
        delegate.downloadTaskDidFinishDownloading = ^NSURL * (NSURLSession * __unused session, NSURLSessionDownloadTask *task, NSURL *location) {
            return destination(location, task.response);
        };
    }

    downloadTask.taskDescription = self.taskDescriptionForSessionTasks;

    [self setDelegate:delegate forTask:downloadTask];

    delegate.downloadProgressBlock = downloadProgressBlock;
}



#pragma mark -

- (NSArray *)tasksForKeyPath:(NSString *)keyPath {
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return tasks;
}

- (NSArray *)tasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)dataTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)uploadTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)downloadTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

#pragma mark -

- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks resetSession:(BOOL)resetSession {
    if (cancelPendingTasks) {
        [self.session invalidateAndCancel];
    } else {
        [self.session finishTasksAndInvalidate];
    }
    if (resetSession) {
        self.session = nil;
    }
}

#pragma mark -

- (void)setResponseSerializer:(id <AFURLResponseSerialization>)responseSerializer {
    NSParameterAssert(responseSerializer);

    _responseSerializer = responseSerializer;
}

#pragma mark - 对task 添加 开始、挂起  监听
- (void)addNotificationObserverForTask:(NSURLSessionTask *)task {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidResume:) name:AFNSURLSessionTaskDidResumeNotification object:task];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidSuspend:) name:AFNSURLSessionTaskDidSuspendNotification object:task];
}

- (void)removeNotificationObserverForTask:(NSURLSessionTask *)task {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNSURLSessionTaskDidSuspendNotification object:task];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNSURLSessionTaskDidResumeNotification object:task];
}

#pragma mark -  父类核心类-入口

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
    // 适配iOS8以上
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    
    [self addDelegateForDataTask:dataTask uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completionHandler];

    return dataTask;
}

#pragma mark -

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request fromFile:fileURL];
    
    if (uploadTask) {
        [self addDelegateForUploadTask:uploadTask
                              progress:uploadProgressBlock
                     completionHandler:completionHandler];
    }

    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                         progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request fromData:bodyData];
    
    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];

    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithStreamedRequest:request];

    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];

    return uploadTask;
}

#pragma mark -

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
    
    [self addDelegateForDownloadTask:downloadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];

    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithResumeData:resumeData];

    [self addDelegateForDownloadTask:downloadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];

    return downloadTask;
}

#pragma mark -
- (NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task {
    return [[self delegateForTask:task] uploadProgress];
}

- (NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task {
    return [[self delegateForTask:task] downloadProgress];
}

#pragma mark - set方法 block

- (void)setSessionDidBecomeInvalidBlock:(void (^)(NSURLSession *session, NSError *error))block {
    self.sessionDidBecomeInvalid = block;
}

- (void)setSessionDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block {
    self.sessionDidReceiveAuthenticationChallenge = block;
}

#if !TARGET_OS_OSX
- (void)setDidFinishEventsForBackgroundURLSessionBlock:(void (^)(NSURLSession *session))block {
    self.didFinishEventsForBackgroundURLSession = block;
}
#endif

- (void)setTaskNeedNewBodyStreamBlock:(NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block {
    self.taskNeedNewBodyStream = block;
}

- (void)setTaskWillPerformHTTPRedirectionBlock:(NSURLRequest * (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block {
    self.taskWillPerformHTTPRedirection = block;
}

- (void)setTaskDidSendBodyDataBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block {
    self.taskDidSendBodyData = block;
}

- (void)setTaskDidCompleteBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSError *error))block {
    self.taskDidComplete = block;
}

#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)setTaskDidFinishCollectingMetricsBlock:(void (^)(NSURLSession * _Nonnull, NSURLSessionTask * _Nonnull, NSURLSessionTaskMetrics * _Nullable))block AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10)) {
    self.taskDidFinishCollectingMetrics = block;
}
#endif

- (void)setDataTaskDidReceiveResponseBlock:(NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block {
    self.dataTaskDidReceiveResponse = block;
}

- (void)setDataTaskDidBecomeDownloadTaskBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block {
    self.dataTaskDidBecomeDownloadTask = block;
}

- (void)setDataTaskDidReceiveDataBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block {
    self.dataTaskDidReceiveData = block;
}

- (void)setDataTaskWillCacheResponseBlock:(NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block {
    self.dataTaskWillCacheResponse = block;
}

- (void)setDownloadTaskDidFinishDownloadingBlock:(NSURL * (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block {
    self.downloadTaskDidFinishDownloading = block;
}

- (void)setDownloadTaskDidWriteDataBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block {
    self.downloadTaskDidWriteData = block;
}

- (void)setDownloadTaskDidResumeBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block {
    self.downloadTaskDidResume = block;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, session: %@, operationQueue: %@>", NSStringFromClass([self class]), self, self.session, self.operationQueue];
}

- (BOOL)respondsToSelector:(SEL)selector {
    if (selector == @selector(URLSession:didReceiveChallenge:completionHandler:)) {
        return self.sessionDidReceiveAuthenticationChallenge != nil;
    } else if (selector == @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)) {
        return self.taskWillPerformHTTPRedirection != nil;
    } else if (selector == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
        return self.dataTaskDidReceiveResponse != nil;
    } else if (selector == @selector(URLSession:dataTask:willCacheResponse:completionHandler:)) {
        return self.dataTaskWillCacheResponse != nil;
    }
#if !TARGET_OS_OSX
    else if (selector == @selector(URLSessionDidFinishEventsForBackgroundURLSession:)) {
        return self.didFinishEventsForBackgroundURLSession != nil;
    }
#endif

    return [[self class] instancesRespondToSelector:selector];
}


#pragma mark - 以下是代理 NSURLSessionDelegate

//1、当前这个session已经失效时，该代理方法被调用。
/*
 如果你使用finishTasksAndInvalidate函数使该session失效，
 那么session首先会先完成最后一个task，然后再调用URLSession:didBecomeInvalidWithError:代理方法，
 如果你调用invalidateAndCancel方法来使session失效，那么该session会立即调用上面的代理方法。
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (self.sessionDidBecomeInvalid) {
        self.sessionDidBecomeInvalid(session, error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDidInvalidateNotification object:session];
}

// 2、https认证
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    NSAssert(self.sessionDidReceiveAuthenticationChallenge != nil, @"`respondsToSelector:` implementation forces `URLSession:didReceiveChallenge:completionHandler:` to be called only if `self.sessionDidReceiveAuthenticationChallenge` is not nil");
    NSURLCredential *credential = nil;
    NSURLSessionAuthChallengeDisposition disposition = self.sessionDidReceiveAuthenticationChallenge(session, challenge, &credential);
    // 完成挑战
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - NSURLSessionTaskDelegate
//4、被服务器重定向的时候调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSURLRequest *redirectRequest = request;
    // step1. 看是否有对应的user block 有的话转发出去，通过这4个参数，返回一个NSURLRequest类型参数，request转发、网络重定向.
    if (self.taskWillPerformHTTPRedirection) {
        //用自己自定义的一个重定向的block实现，返回一个新的request。
        redirectRequest = self.taskWillPerformHTTPRedirection(session, task, response, request);
    }
    if (completionHandler) {
        // step2. 用request重新请求
        completionHandler(redirectRequest);
    }
}

// 5、https认证，区别在于这个是non-session-level级别的认证，而之前的是session-level级别的。
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    //挑战处理类型为 默认
    /*
     NSURLSessionAuthChallengePerformDefaultHandling：默认方式处理
     NSURLSessionAuthChallengeUseCredential：使用指定的证书
     NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消挑战
    */
    BOOL evaluateServerTrust = NO;
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;

    // sessionDidReceiveAuthenticationChallenge是自定义方法，用来如何应对服务器端的认证挑战
    if (self.authenticationChallengeHandler) {
        id result = self.authenticationChallengeHandler(session, task, challenge, completionHandler);
        if (result == nil) {
            return;
        } else if ([result isKindOfClass:NSError.class]) {
            objc_setAssociatedObject(task, AuthenticationChallengeErrorKey, result, OBJC_ASSOCIATION_RETAIN);
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        } else if ([result isKindOfClass:NSURLCredential.class]) {
            credential = result;
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else if ([result isKindOfClass:NSNumber.class]) {
            disposition = [result integerValue];
            NSAssert(disposition == NSURLSessionAuthChallengePerformDefaultHandling || disposition == NSURLSessionAuthChallengeCancelAuthenticationChallenge || disposition == NSURLSessionAuthChallengeRejectProtectionSpace, @"");
            evaluateServerTrust = disposition == NSURLSessionAuthChallengePerformDefaultHandling && [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
        } else {
            @throw [NSException exceptionWithName:@"Invalid Return Value" reason:@"The return value from the authentication challenge handler must be nil, an NSError, an NSURLCredential or an NSNumber." userInfo:nil];
        }
    } else {
        evaluateServerTrust = [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    }

    if (evaluateServerTrust) {
        if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            objc_setAssociatedObject(task, AuthenticationChallengeErrorKey,
                                     [self serverTrustErrorForServerTrust:challenge.protectionSpace.serverTrust url:task.currentRequest.URL],
                                     OBJC_ASSOCIATION_RETAIN);
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    // 完成挑战
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (nonnull NSError *)serverTrustErrorForServerTrust:(nullable SecTrustRef)serverTrust url:(nullable NSURL *)url {
    NSBundle *CFNetworkBundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    NSString *defaultValue = @"The certificate for this server is invalid. You might be connecting to a server that is pretending to be “%@” which could put your confidential information at risk.";
    NSString *descriptionFormat = NSLocalizedStringWithDefaultValue(@"Err-1202.w", nil, CFNetworkBundle, defaultValue, @"") ?: defaultValue;
    NSString *localizedDescription = [descriptionFormat componentsSeparatedByString:@"%@"].count <= 2 ? [NSString localizedStringWithFormat:descriptionFormat, url.host] : descriptionFormat;
    NSMutableDictionary *userInfo = [@{
        NSLocalizedDescriptionKey: localizedDescription
    } mutableCopy];

    if (serverTrust) {
        userInfo[NSURLErrorFailingURLPeerTrustErrorKey] = (__bridge id)serverTrust;
    }

    if (url) {
        userInfo[NSURLErrorFailingURLErrorKey] = url;

        if (url.absoluteString) {
            userInfo[NSURLErrorFailingURLStringErrorKey] = url.absoluteString;
        }
    }

    return [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorServerCertificateUntrusted userInfo:userInfo];
}

// 6、当一个session task需要发送一个新的request body stream到服务器端的时候，调用该代理方法。
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler {
    NSInputStream *inputStream = nil;
    if (self.taskNeedNewBodyStream) {
        inputStream = self.taskNeedNewBodyStream(session, task);
    } else if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        inputStream = [task.originalRequest.HTTPBodyStream copy];
    }

    if (completionHandler) {
        completionHandler(inputStream);
    }
}
// 7、周期性地通知代理发送到服务器端数据的进度。
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    int64_t totalUnitCount = totalBytesExpectedToSend;
    if (totalUnitCount == NSURLSessionTransferSizeUnknown) {
        NSString *contentLength = [task.originalRequest valueForHTTPHeaderField:@"Content-Length"];
        if (contentLength) {
            totalUnitCount = (int64_t) [contentLength longLongValue];
        }
    }
    
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    
    if (delegate) {
        [delegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }

    if (self.taskDidSendBodyData) {
        self.taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalUnitCount);
    }
}

// 8、***task完成之后的回调，成功和失败都会回调这里《重要》
/*
  函数讨论：
  注意这里的error不会报告服务期端的error，他表示的是客户端这边的eroor，比如无法解析hostname或者连不上host主机。
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 根据task去取我们一开始创建绑定的delegate
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];

    // delegate may be nil when completing a task in the background
    if (delegate) {
        // ***把代理转发给我们绑定的delegate
        [delegate URLSession:session task:task didCompleteWithError:error];
        // 转发完移除delegate
        [self removeDelegateForTask:task];
    }
    // 自定义Block回调
    if (self.taskDidComplete) {
        self.taskDidComplete(session, task, error);
    }
}

#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10))
{
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    // Metrics may fire after URLSession:task:didCompleteWithError: is called, delegate may be nil
    if (delegate) {
        [delegate URLSession:session task:task didFinishCollectingMetrics:metrics];
    }

    if (self.taskDidFinishCollectingMetrics) {
        self.taskDidFinishCollectingMetrics(session, task, metrics);
    }
}
#endif

#pragma mark - NSURLSessionDataDelegate

// 9、收到服务器响应后调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    // 设置默认为继续进行
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    // 自定义去设置
    if (self.dataTaskDidReceiveResponse) {
        disposition = self.dataTaskDidReceiveResponse(session, dataTask, response);
    }

    if (completionHandler) {
        completionHandler(disposition);
    }
}
// 10、上面的代理如果设置为NSURLSessionResponseBecomeDownload，则会调用这个方法
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    //因为转变了task，所以要对task做一个重新绑定
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate) {
        [self removeDelegateForTask:dataTask];
        [self setDelegate:delegate forTask:downloadTask];
    }
    //执行自定义Block
    if (self.dataTaskDidBecomeDownloadTask) {
        self.dataTaskDidBecomeDownloadTask(session, dataTask, downloadTask);
    }
}
// 11、***当我们获取到数据就会调用，会被反复调用，请求到的数据就在这被拼装完整《重要》
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    [delegate URLSession:session dataTask:dataTask didReceiveData:data];

    if (self.dataTaskDidReceiveData) {
        self.dataTaskDidReceiveData(session, dataTask, data);
    }
}
// 12、当task接收到所有期望的数据后，session会调用此代理方法。
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    NSCachedURLResponse *cachedResponse = proposedResponse;

    if (self.dataTaskWillCacheResponse) {
        cachedResponse = self.dataTaskWillCacheResponse(session, dataTask, proposedResponse);
    }

    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#if !TARGET_OS_OSX
//3、 当session中所有已经入队的消息被发送出去后，会调用该代理方法。
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.didFinishEventsForBackgroundURLSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didFinishEventsForBackgroundURLSession(session);
        });
    }
}
#endif

#pragma mark - NSURLSessionDownloadDelegate

// 13、***下载完成的时候调用《重要》
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    //这个是session的，也就是全局的，后面的个人代理也会做同样的这件事
    if (self.downloadTaskDidFinishDownloading) {
        //调用自定义的block拿到文件存储的地址
        NSURL *fileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (fileURL) {
            delegate.downloadFileURL = fileURL;
            NSError *error = nil;
            //从临时的下载路径移动至我们需要的路径
            if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error]) {
                //如果移动出错
                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:error.userInfo];
            } else {
                //如果移动成功
                [[NSNotificationCenter defaultCenter] postNotificationName:AFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification object:downloadTask userInfo:nil];
            }

            return;
        }
    }
    // 转发代理
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}
//  14、***周期性地通知下载进度调用《重要》
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    // 转发
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
    // 交给自定义的Block去调用
    if (self.downloadTaskDidWriteData) {
        self.downloadTaskDidWriteData(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}
// 15、当下载被取消或者失败后重新恢复下载时调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    AFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    // 转发
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
    }
    // 交给自定义的Block去调用
    if (self.downloadTaskDidResume) {
        self.downloadTaskDidResume(session, downloadTask, fileOffset, expectedTotalBytes);
    }
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    NSURLSessionConfiguration *configuration = [decoder decodeObjectOfClass:[NSURLSessionConfiguration class] forKey:@"sessionConfiguration"];

    self = [self initWithSessionConfiguration:configuration];
    if (!self) {
        return nil;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.session.configuration forKey:@"sessionConfiguration"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithSessionConfiguration:self.session.configuration];
}

@end
