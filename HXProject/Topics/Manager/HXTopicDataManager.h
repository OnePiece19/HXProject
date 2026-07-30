//
//  HXTopicDataManager.h
//  HXProject
//
//  主题数据管理器 - 单例
//

#import <Foundation/Foundation.h>

@class HXSectionModel, HXTopicModel;

NS_ASSUME_NONNULL_BEGIN

@interface HXTopicDataManager : NSObject

+ (instancetype)sharedManager;

/// 所有章节（按配置文件顺序）
- (NSArray<HXSectionModel *> *)allSections;

/// 关键词搜索
- (NSArray<HXTopicModel *> *)searchTopics:(NSString *)keyword;

/// 切换收藏状态
- (void)toggleFavorite:(NSString *)topicId;

/// 获取所有收藏
- (NSArray<HXTopicModel *> *)favoriteTopics;

@end

NS_ASSUME_NONNULL_END