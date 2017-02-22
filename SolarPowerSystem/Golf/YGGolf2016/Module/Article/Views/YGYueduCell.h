//
//  YGArticleCell.h
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGYueduCommon.h"

FOUNDATION_EXTERN NSString *const kYGYueduNormalCellID;
FOUNDATION_EXTERN NSString *const kYGYueduImageCellID;
FOUNDATION_EXTERN NSString *const kYGYueduVideoCellID;
FOUNDATION_EXTERN NSString *const kYGYueduVideoCellID2;

@interface YGYueduCell : UITableViewCell

// 向tableView注册所有类型的cell
+ (void)registerYueDuCellsInTableView:(UITableView *)tableView;

// cell identifier
+ (NSString *)cellIdentifierForType:(YGYueduCellType)type;
// cell type
+ (YGYueduCellType)cellTypeForIdentifier:(NSString *)identifier;

// 用于push的navi
@property (weak, nonatomic) UIViewController *viewCtrl;
// 标题
@property (weak, nonatomic) IBOutlet UILabel *articleTitleLabel;
// 全部imageView
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *articleImageViews;
// 标签
@property (weak, nonatomic) IBOutlet UILabel *articleCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleSourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleVideoLengthLabel;
// 视频相关
@property (weak, nonatomic) IBOutlet UIButton *videoPlayBtn;

// cell 内容
@property (nonatomic,assign) int articleID;
@property (strong, readonly, nonatomic) YueduArticleBean *article;
@property (nonatomic,strong) id data;

// article的viewModel应在外部已经生成了
- (void)configureWithArticle:(YueduArticleBean *)article;

@property (assign, nonatomic) BOOL categoryActionEnabled;
@property (copy, nonatomic) void (^categoryAction)(YueduArticleBean *article);

@end
