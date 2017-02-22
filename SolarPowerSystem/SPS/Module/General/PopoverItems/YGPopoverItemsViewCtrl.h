//
//  YGPopoverItemsViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/11/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBasePopViewController.h"

@class YGPopoverItem;

@interface YGPopoverItemsViewCtrl : YGBasePopViewController

- (void)setupItems:(NSArray *)items
          callback:(void (^)(YGPopoverItem *item))callback;

@end

typedef NS_ENUM(NSUInteger, YGPopoverItemType) {
    YGPopoverItemTypeHome, //首页
    YGPopoverItemTypeMall, //商城首页
    YGPopoverItemTypeMallList, //商品精选列表
    YGPopoverItemTypeMallCart, //商城购物车
    YGPopoverItemTypeCourseHome, //球场
    YGPopoverItemTypeTeachingHome,  //教学
    YGPopoverItemTypeTeachBookingHome, //教学
};

@interface YGPopoverItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *iconName;
@property (assign, nonatomic) YGPopoverItemType type;

+ (instancetype)itemWithType:(YGPopoverItemType)type;

+ (void)performDefaultOpeaterOfItem:(YGPopoverItem *)item fromNavi:(UINavigationController *)navi;

@end
