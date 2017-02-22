//
//  YGMallSectionTitleView.h
//  Golf
//
//  Created by bo wang on 2016/10/18.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGMallSectionHeaderModel;

UIKIT_EXTERN const CGFloat kDefaultHeaderHeight;
UIKIT_EXTERN NSString *const kYGMallSectionTitleView;

/**
 作为商城首页的sectionHeader。在plain模式下无悬停效果。
 */
@interface YGMallSectionTitleView : UITableViewHeaderFooterView

+ (void)registerIn:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UIImageView *colorlumpView;
@property (weak, nonatomic) IBOutlet UILabel *sectionTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (strong, readonly, nonatomic) YGMallSectionHeaderModel *header;
- (void)configureWithHeader:(YGMallSectionHeaderModel *)header;

@end


typedef NS_ENUM(NSUInteger, YGMallSectionType) {
    YGMallSectionTypeCate,      //分类
    YGMallSectionTypeAuction,   //抢拍
    YGMallSectionTypeBrand,     //品牌
    YGMallSectionTypeActivity,  //活动
    YGMallSectionTypeTheme,     //主题
    YGMallSectionTypeCommodity  //普通商品
};

/**
 商城首页填充header的model
 */
@interface YGMallSectionHeaderModel : NSObject

@property (assign, nonatomic) YGMallSectionType type;
@property (strong, nonatomic) NSString *title;
@property (copy,   nonatomic) NSString *iconName;
@property (assign, nonatomic) BOOL showMoreBtn;   //是否显示“更多"按钮。默认为NO，是隐藏的
@property (copy, nonatomic) void (^moreActionBlock)(YGMallSectionHeaderModel *);

+ (instancetype)header:(YGMallSectionType)type;

+ (instancetype)header:(YGMallSectionType)type
                 title:(NSString *)title
                  icon:(NSString *)iconName
              callback:(void(^)(YGMallSectionHeaderModel *))callback;

+ (NSArray<YGMallSectionHeaderModel *> *)defaultSectionHeaders:(void(^)(YGMallSectionHeaderModel *header))callback;

@end
