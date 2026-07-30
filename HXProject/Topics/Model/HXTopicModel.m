//
//  HXTopicModel.m
//  HXProject
//

#import "HXTopicModel.h"

@implementation HXTopicModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _topicId   = [dict[@"id"] copy];
        _title     = [dict[@"title"] copy];
        _icon      = [dict[@"icon"] copy];
        _subtitle  = [dict[@"subtitle"] copy];
        _vcClass   = [dict[@"vcClass"] copy];
        _isFavorite = NO;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<HXTopicModel: %@ - %@>", self.topicId, self.title];
}

@end