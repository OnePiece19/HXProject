//
//  HXTopicDataManager.m
//  HXProject
//

#import "HXTopicDataManager.h"
#import "HXSectionModel.h"
#import "HXTopicModel.h"

@interface HXTopicDataManager ()

@property (nonatomic, copy) NSArray<HXSectionModel *> *sections;

@end

@implementation HXTopicDataManager

+ (instancetype)sharedManager {
    static HXTopicDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance loadConfig];
    });
    return instance;
}

- (void)loadConfig {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"topic_config" ofType:@"json"];
    if (!path) {
        NSLog(@"⚠️ topic_config.json not found in bundle");
        self.sections = @[];
        return;
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"⚠️ Failed to parse topic_config.json: %@", error);
        self.sections = @[];
        return;
    }

    NSArray *sectionDicts = root[@"sections"];
    NSMutableArray<HXSectionModel *> *models = [NSMutableArray arrayWithCapacity:sectionDicts.count];
    for (NSDictionary *dict in sectionDicts) {
        HXSectionModel *section = [[HXSectionModel alloc] initWithDictionary:dict];
        [models addObject:section];
    }
    self.sections = [models copy];
}

- (NSArray<HXSectionModel *> *)allSections {
    return self.sections;
}

- (NSArray<HXTopicModel *> *)searchTopics:(NSString *)keyword {
    if (keyword.length == 0) return @[];

    NSString *lowerKeyword = [keyword lowercaseString];
    NSMutableArray<HXTopicModel *> *results = [NSMutableArray array];

    for (HXSectionModel *section in self.sections) {
        for (HXTopicModel *topic in section.topics) {
            if ([[topic.title lowercaseString] containsString:lowerKeyword] ||
                [[topic.subtitle lowercaseString] containsString:lowerKeyword]) {
                [results addObject:topic];
            }
        }
    }
    return [results copy];
}

- (void)toggleFavorite:(NSString *)topicId {
    for (HXSectionModel *section in self.sections) {
        for (HXTopicModel *topic in section.topics) {
            if ([topic.topicId isEqualToString:topicId]) {
                topic.isFavorite = !topic.isFavorite;
                return;
            }
        }
    }
}

- (NSArray<HXTopicModel *> *)favoriteTopics {
    NSMutableArray<HXTopicModel *> *results = [NSMutableArray array];
    for (HXSectionModel *section in self.sections) {
        for (HXTopicModel *topic in section.topics) {
            if (topic.isFavorite) {
                [results addObject:topic];
            }
        }
    }
    return [results copy];
}

@end