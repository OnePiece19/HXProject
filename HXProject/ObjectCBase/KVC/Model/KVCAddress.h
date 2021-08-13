//
//  KVCAddress.h
//  HXProject
//
//  Created by HX on 2021/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KVCAddress : NSObject

@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *street;

@property (strong, nonatomic) NSNumber *cityNumber;
@property (assign, nonatomic) NSInteger streetNumber;


@end

NS_ASSUME_NONNULL_END
