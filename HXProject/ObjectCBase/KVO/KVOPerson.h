//
//  KVOPerson.h
//  HXProject
//
//  Created by HX on 2021/8/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KVOPerson : NSObject
{
    @public
    NSInteger age;
}

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *sex;

@property (copy, nonatomic) NSString *address;

@property (strong, nonatomic) NSMutableArray *mArray;



@end

NS_ASSUME_NONNULL_END
