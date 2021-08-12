//
//  KVCPerson.h
//  HXProject
//
//  Created by HX on 2021/8/12.
//

#import <Foundation/Foundation.h>
#import "KVCAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface KVCPerson : NSObject

@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger sex;
@property (strong, nonatomic) NSNumber * age;

@property (strong, nonatomic) KVCAddress *address;

@end

NS_ASSUME_NONNULL_END
