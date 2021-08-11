// UIImageView+AFNetworking.h
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

#if TARGET_OS_IOS || TARGET_OS_TV

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AFImageDownloader;

/**
 无论SDWebImage,还是YYKit,或者AF，都实现了这么个类目。
 */
@interface UIImageView (AFNetworking)

///------------------------------------
/// @name Accessing the Image Downloader
///------------------------------------

/**
 Set the shared image downloader used to download images.

 @param imageDownloader The shared image downloader used to download images.
 */
+ (void)setSharedImageDownloader:(AFImageDownloader *)imageDownloader;

/**
 The shared image downloader used to download images.
 */
+ (AFImageDownloader *)sharedImageDownloader;

///--------------------
/// @name Setting Image
///--------------------

// 给一个UIImageView去异步的请求一张图片
- (void)setImageWithURL:(NSURL *)url;
// 给一个UIImageView去异步的请求一张图片，并且可以设置一张占位图
- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(nullable UIImage *)placeholderImage;

// 给一个UIImageView去异步的请求一张图片，并且可以设置一张占位图，并有成功和失败的block回调
- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(nullable UIImage *)placeholderImage
                       success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                       failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure;

/**
 Cancels any executing image operation for the receiver, if one exists.
 */
- (void)cancelImageDownloadTask;

@end

NS_ASSUME_NONNULL_END

#endif
