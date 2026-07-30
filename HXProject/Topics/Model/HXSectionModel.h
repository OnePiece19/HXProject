//
//  HXSectionModel.h
//  HXProject
//
//  章节分组模型
//

#import <Foundation/Foundation.h>

@class HXTopicModel;

NS_ASSUME_NONNULL_BEGIN

@interface HXSectionModel : NSObject

@property (nonatomic, copy) NSString *sectionId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *subtitle;

/// 该章节下的所有知识点
@property (nonatomic, copy) NSArray<HXTopicModel *> *topics;

/// 当前是否折叠（默认 NO = 展开）
@property (nonatomic, assign) BOOL collapsed;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END