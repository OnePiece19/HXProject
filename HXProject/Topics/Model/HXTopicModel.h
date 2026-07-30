//
//  HXTopicModel.h
//  HXProject
//
//  单个知识点模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXTopicModel : NSObject

@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *vcClass;

/// 是否已收藏（内存态，不持久化）
@property (nonatomic, assign) BOOL isFavorite;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END