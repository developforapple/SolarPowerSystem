//
//  YGSearchBaseCell.h
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGSearch.h"
#import "YGSearchViewModel.h"

@interface YGSearchBaseCell : UITableViewCell

+ (UIImage *)defaultPlaceholder;

+ (NSString *)cellIdentifierForType:(YGSearchCellType)type;
+ (YGSearchCellType)cellTypeForIdentifier:(NSString *)identifier;
+ (YGSearchCellType)cellTypeForSearchType:(YGSearchType)searchType;

@property (assign, nonatomic) YGSearchType searchType;

@property (strong, readonly, nonatomic) id entity;
- (void)configureWithEntity:(id )entity;


@end

FOUNDATION_EXTERN NSString *const kYGSearchHeaderFooterCell;//头部尾部的cell。
FOUNDATION_EXTERN NSString *const kYGSearchCourseCell;    //球场
FOUNDATION_EXTERN NSString *const kYGSearchCommodityCell; //商品
FOUNDATION_EXTERN NSString *const kYGSearchUserCell;    //用户和教练
FOUNDATION_EXTERN NSString *const kYGSearchYueduCell;    //头条

// 动态cell可能有多种
FOUNDATION_EXTERN NSString *kYGSearchFeedCell;
