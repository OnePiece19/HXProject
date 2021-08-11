// AFNetworkActivityIndicatorManager.h
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

#import <Foundation/Foundation.h>

#import <TargetConditionals.h>

#if TARGET_OS_IOS

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AFNetworkActivityIndicatorManager` manages the state of the network activity indicator in the status bar. When enabled, it will listen for notifications indicating that a session task has started or finished, and start or stop animating the indicator accordingly. The number of active requests is incremented and decremented much like a stack or a semaphore, and the activity indicator will animate so long as that number is greater than zero.

 You should enable the shared instance of `AFNetworkActivityIndicatorManager` when your application finishes launching. In `AppDelegate application:didFinishLaunchingWithOptions:` you can do so with the following code:

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

 By setting `enabled` to `YES` for `sharedManager`, the network activity indicator will show and hide automatically as requests start and finish. You should not ever need to call `incrementActivityCount` or `decrementActivityCount` yourself.

 See the Apple Human Interface Guidelines section about the Network Activity Indicator for more information:
 http://developer.apple.com/library/iOS/#documentation/UserExperience/Conceptual/MobileHIG/UIElementGuidelines/UIElementGuidelines.html#//apple_ref/doc/uid/TP40006556-CH13-SW44
 */
NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.")
@interface AFNetworkActivityIndicatorManager : NSObject

// 指示管理器是否已启用的布尔值。
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

// 一个布尔值，指示网络活动指示器管理器当前是否处于活动状态。
@property (readonly, nonatomic, assign, getter=isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;

/*
 原来这是AF对请求菊花显示做的一个优化处理，试问如果一个请求时间很短，那么菊花很可能闪一下就结束了。如果很多请求过来，那么菊花会不停的闪啊闪，这显然并不是我们想要的效果。

 所以多了这两个参数：
 1）在一个请求开始的时候，我延迟一会在去转菊花，如果在这延迟时间内，请求结束了，那么我就不需要去转菊花了。
 2）但是一旦转菊花开始，哪怕很短请求就结束了，我们还是会去转一个时间再去结束，这时间就是延迟结束的时间。
 */

// 转菊花延迟开始的时间，默认1s
@property (nonatomic, assign) NSTimeInterval activationDelay;
// 转菊花延迟结束的时间，默认0.17s
@property (nonatomic, assign) NSTimeInterval completionDelay;


+ (instancetype)sharedManager;

/**
 增加活动网络请求的数量。如果此数字在递增之前为零，则将开始设置状态栏“网络活动指示器”的动画。
 */
- (void)incrementActivityCount;

/**
 减少活动网络请求的数量。如果该数字在递减后变为零，则将停止设置状态栏网络活动指示器的动画。
 */
- (void)decrementActivityCount;

/**
 设置要在隐藏/显示网络活动指示器管理器时执行的自定义方法
 */
- (void)setNetworkingActivityActionWithBlock:(nullable void (^)(BOOL networkActivityIndicatorVisible))block;

@end

NS_ASSUME_NONNULL_END

#endif
