// AFNetworkActivityIndicatorManager.m
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

#import "AFNetworkActivityIndicatorManager.h"

#if TARGET_OS_IOS
#import "AFURLSessionManager.h"

typedef NS_ENUM(NSInteger, AFNetworkActivityManagerState) {
    AFNetworkActivityManagerStateNotActive,     // 没有请求
    AFNetworkActivityManagerStateDelayingStart, // 请求延迟开始
    AFNetworkActivityManagerStateActive,        // 请求进行中
    AFNetworkActivityManagerStateDelayingEnd    // 请求延迟结束
};
// 转菊花延迟开始的时间，默认1s
static NSTimeInterval const kDefaultAFNetworkActivityManagerActivationDelay = 1.0;
// 转菊花延迟结束的时间，默认0.17s
static NSTimeInterval const kDefaultAFNetworkActivityManagerCompletionDelay = 0.17;

static NSURLRequest * AFNetworkRequestFromNotification(NSNotification *notification) {
    if ([[notification object] respondsToSelector:@selector(originalRequest)]) {
        return [(NSURLSessionTask *)[notification object] originalRequest];
    } else {
        return nil;
    }
}

typedef void (^AFNetworkActivityActionBlock)(BOOL networkActivityIndicatorVisible);

@interface AFNetworkActivityIndicatorManager ()
@property (readwrite, nonatomic, assign) NSInteger activityCount;
@property (readwrite, nonatomic, strong) NSTimer *activationDelayTimer; // 转菊花延迟开始_计时器
@property (readwrite, nonatomic, strong) NSTimer *completionDelayTimer; // 转菊花延迟技术_计时器
@property (readonly, nonatomic, getter = isNetworkActivityOccurring) BOOL networkActivityOccurring; // 网络正在请求
@property (nonatomic, copy) AFNetworkActivityActionBlock networkActivityActionBlock;
@property (nonatomic, assign) AFNetworkActivityManagerState currentState;
@property (nonatomic, assign, getter=isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;

- (void)updateCurrentStateForNetworkActivityChange;
@end

@implementation AFNetworkActivityIndicatorManager

+ (instancetype)sharedManager {
    static AFNetworkActivityIndicatorManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    // 设置状态为没有request活跃
    self.currentState = AFNetworkActivityManagerStateNotActive;
    // 开始通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkRequestDidStart:)
                                                 name:AFNetworkingTaskDidResumeNotification
                                               object:nil];
    // 挂起通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkRequestDidFinish:)
                                                 name:AFNetworkingTaskDidSuspendNotification
                                               object:nil];
    // 完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkRequestDidFinish:)
                                                 name:AFNetworkingTaskDidCompleteNotification
                                               object:nil];
    // 初始化时间
    self.activationDelay = kDefaultAFNetworkActivityManagerActivationDelay;
    self.completionDelay = kDefaultAFNetworkActivityManagerCompletionDelay;

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_activationDelayTimer invalidate];
    [_completionDelayTimer invalidate];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled == NO) {
        [self setCurrentState:AFNetworkActivityManagerStateNotActive];
    }
}

- (void)setNetworkingActivityActionWithBlock:(void (^)(BOOL networkActivityIndicatorVisible))block {
    self.networkActivityActionBlock = block;
}

- (BOOL)isNetworkActivityOccurring {
    @synchronized(self) {
        return self.activityCount > 0;
    }
}

#pragma mark - 核心-设置网络状态的方法
- (void)setNetworkActivityIndicatorVisible:(BOOL)networkActivityIndicatorVisible {
    if (_networkActivityIndicatorVisible != networkActivityIndicatorVisible) {
        @synchronized(self) {
            _networkActivityIndicatorVisible = networkActivityIndicatorVisible;
        }
        //支持自定义的Block，去自己控制小菊花
        if (self.networkActivityActionBlock) {
            self.networkActivityActionBlock(networkActivityIndicatorVisible);
        } else {
            //否则默认AF根据该Bool，去控制状态栏小菊花是否显示
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:networkActivityIndicatorVisible];
        }
    }
}

// 增加请求活跃数
- (void)incrementActivityCount {
    @synchronized(self) {
        self.activityCount++;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCurrentStateForNetworkActivityChange];
    });
}
//减少请求活跃数
- (void)decrementActivityCount {
    @synchronized(self) {
        self.activityCount = MAX(_activityCount - 1, 0);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCurrentStateForNetworkActivityChange];
    });
}
//请求开始
- (void)networkRequestDidStart:(NSNotification *)notification {
    if ([AFNetworkRequestFromNotification(notification) URL]) {
        [self incrementActivityCount]; // 增加请求活跃数
    }
}
//请求结束
- (void)networkRequestDidFinish:(NSNotification *)notification {
    if ([AFNetworkRequestFromNotification(notification) URL]) {
        [self decrementActivityCount]; // 减少请求活跃数
    }
}

#pragma mark - Internal State Management 核心方法

//根据状态，设置当前小菊花状态
- (void)setCurrentState:(AFNetworkActivityManagerState)currentState {
    @synchronized(self) {
        if (_currentState != currentState) {
            _currentState = currentState;
            switch (currentState) {
                // 如果为不活跃
                case AFNetworkActivityManagerStateNotActive:
                    //取消两个延迟用的timer
                    [self cancelActivationDelayTimer];
                    [self cancelCompletionDelayTimer];
                    [self setNetworkActivityIndicatorVisible:NO];// 设置小菊花不可见
                    break;
                
                case AFNetworkActivityManagerStateDelayingStart:
                    [self startActivationDelayTimer];// 开启一个定时器延迟去转菊花
                    break;
                case AFNetworkActivityManagerStateActive:// 如果是活跃状态
                    [self cancelCompletionDelayTimer];   // 取消延迟完成的timer
                    [self setNetworkActivityIndicatorVisible:YES];
                    break;
                case AFNetworkActivityManagerStateDelayingEnd: // 延迟完成状态
                    [self startCompletionDelayTimer];          // 开启延迟完成timer
                    break;
            }
        }
    }
}

// 更新当前网络活动状态
// 根据当前的状态，来判断下一个状态应该是什么
- (void)updateCurrentStateForNetworkActivityChange {
    //如果是允许小菊花
    if (self.enabled) {
        switch (self.currentState) {
            // 不活跃 -> 判断是否活跃
            case AFNetworkActivityManagerStateNotActive:
                if (self.isNetworkActivityOccurring) {//判断活跃数，大于0为YES
                    [self setCurrentState:AFNetworkActivityManagerStateDelayingStart];
                }
                break;
            // 请求延迟开始
            case AFNetworkActivityManagerStateDelayingStart:
                //No op. Let the delay timer finish out.
                break;
            // 请求进行中 -> 判断是否结束
            case AFNetworkActivityManagerStateActive:
                if (!self.isNetworkActivityOccurring) {
                    [self setCurrentState:AFNetworkActivityManagerStateDelayingEnd];
                }
                break;
            // 请求延迟结束 -> 判断是否活跃
            case AFNetworkActivityManagerStateDelayingEnd:
                if (self.isNetworkActivityOccurring) {
                    [self setCurrentState:AFNetworkActivityManagerStateActive];
                }
                break;
        }
    }
}
//开始任务到结束的时间，默认为1秒，如果1秒就结束，那么不转菊花，延迟去开始转
- (void)startActivationDelayTimer {
    self.activationDelayTimer = [NSTimer
                                 timerWithTimeInterval:self.activationDelay target:self selector:@selector(activationDelayTimerFired) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.activationDelayTimer forMode:NSRunLoopCommonModes];
}

- (void)activationDelayTimerFired {
    //活跃状态，即活跃数大于1才转
    if (self.networkActivityOccurring) {
        [self setCurrentState:AFNetworkActivityManagerStateActive];
    } else {
        [self setCurrentState:AFNetworkActivityManagerStateNotActive];
    }
}
//完成任务到下一个任务开始，默认为0.17秒，如果0.17秒就开始下一个，那么不停  延迟去结束菊花转
- (void)startCompletionDelayTimer {
    [self.completionDelayTimer invalidate];
    self.completionDelayTimer = [NSTimer timerWithTimeInterval:self.completionDelay target:self selector:@selector(completionDelayTimerFired) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.completionDelayTimer forMode:NSRunLoopCommonModes];
}

- (void)completionDelayTimerFired {
    [self setCurrentState:AFNetworkActivityManagerStateNotActive];
}

- (void)cancelActivationDelayTimer {
    [self.activationDelayTimer invalidate];
}

- (void)cancelCompletionDelayTimer {
    [self.completionDelayTimer invalidate];
}

@end

#endif
