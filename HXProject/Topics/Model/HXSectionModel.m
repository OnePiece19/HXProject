//
//  HXSectionModel.m
//  HXProject
//

#import "HXSectionModel.h"
#import "HXTopicModel.h"

@implementation HXSectionModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _sectionId  = [dict[@"id"] copy];
        _title      = [dict[@"title"] copy];
        _icon       = [dict[@"icon"] copy];
        _subtitle   = [dict[@"subtitle"] copy];
        _collapsed  = NO;

        NSArray *topicDicts = dict[@"topics"];
        NSMutableArray<HXTopicModel *> *models = [NSMutableArray arrayWithCapacity:topicDicts.count];
        for (NSDictionary *topicDict in topicDicts) {
            HXTopicModel *topic = [[HXTopicModel alloc] initWithDictionary:topicDict];
            [models addObject:topic];
        }
        _topics = [models copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<HXSectionModel: %@ - %@, %lu topics>",
            self.sectionId, self.title, (unsigned long)self.topics.count];
}

@end