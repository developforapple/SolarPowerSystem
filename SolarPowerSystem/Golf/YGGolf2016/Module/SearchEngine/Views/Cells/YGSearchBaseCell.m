//
//  YGSearchBaseCell.m
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchBaseCell.h"

@implementation YGSearchBaseCell

+ (void)load
{
    if (!kYGSearchFeedCell) {
        // 动态多图模式下有不同的图片数量和间距
        // 屏幕不一样 cell的id也不一样
        if (IS_4_7_INCH_SCREEN){
            kYGSearchFeedCell = @"YGSearchFeedCell_375";
        }else if (IS_5_5_INCH_SCREEN){
            kYGSearchFeedCell = @"YGSearchFeedCell_414";
        }else{
            kYGSearchFeedCell = @"YGSearchFeedCell_320";
        }
    }
}

+ (UIImage *)defaultPlaceholder
{
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"defeat_goods_"];  //原图名就是这样的 ┑(￣Д ￣)┍
    });
    return image;
}

+ (NSDictionary *)_cellIdentifierDict
{
    static NSDictionary *cellIdentifierMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellIdentifierMapping = @{kYGSearchHeaderFooterCell:@(YGSearchCellTypeHeaderFooter),
                                  kYGSearchCourseCell:      @(YGSearchCellTypeCourse),
                                  kYGSearchCommodityCell:   @(YGSearchCellTypeCommodity),
                                  kYGSearchUserCell:        @(YGSearchCellTypeUser),
                                  kYGSearchYueduCell:       @(YGSearchCellTypeYuedu),
                                  kYGSearchFeedCell:        @(YGSearchCellTypeFeed)};
    });
    return cellIdentifierMapping;
}

+ (NSString *)cellIdentifierForType:(YGSearchCellType)type
{
    NSDictionary *dict = [self _cellIdentifierDict];
    for (NSString *identifier in dict) {
        if ([dict[identifier] integerValue] == type) {
            return identifier;
        }
    }
    return kYGSearchCourseCell;
}

+ (YGSearchCellType)cellTypeForIdentifier:(NSString *)identifier
{
    return (YGSearchCellType)[[self _cellIdentifierDict][identifier] integerValue];
}

+ (YGSearchCellType)cellTypeForSearchType:(YGSearchType)searchType
{
    YGSearchCellType cellType = YGSearchCellTypeHeaderFooter;
    switch (searchType) {
        case YGSearchTypeAll:       {                                       break;}
        case YGSearchTypeFeed:      {   cellType = YGSearchCellTypeFeed;    break;}
        case YGSearchTypeUser:      {   cellType = YGSearchCellTypeUser;    break;}
        case YGSearchTypeCoach:     {   cellType = YGSearchCellTypeUser;    break;}
        case YGSearchTypeCourse:    {   cellType = YGSearchCellTypeCourse;  break;}
        case YGSearchTypeCommodity: {   cellType = YGSearchCellTypeCommodity;break;}
        case YGSearchTypeYuedu:     {   cellType = YGSearchCellTypeYuedu;   break;}
    }
    return cellType;
}

- (void)configureWithEntity:(id)entity
{
    _entity = entity;
}

@end


NSString *const kYGSearchHeaderFooterCell   = @"YGSearchHeaderFooterCell";
NSString *const kYGSearchCourseCell         = @"YGSearchCourseCell";
NSString *const kYGSearchCommodityCell      = @"YGSearchCommodityCell";
NSString *const kYGSearchUserCell           = @"YGSearchUserCell";
NSString *const kYGSearchYueduCell          = @"YGSearchYueduCell";

// 这个值需要根据设备做修改！
NSString * kYGSearchFeedCell;
