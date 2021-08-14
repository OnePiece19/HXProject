//
//  KVOPerson.m
//  HXProject
//
//  Created by HX on 2021/8/14.
//

#import "KVOPerson.h"

@interface KVOPerson ()

{
    NSString *privateVar;
}
@property (strong, nonatomic) NSString *privateProperty;

@end

@implementation KVOPerson

-(NSMutableArray *)mArray {
    if (!_mArray) {
        _mArray = [NSMutableArray array];
    }
    return _mArray;
}

@end
