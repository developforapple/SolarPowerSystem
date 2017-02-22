//
//  YGMallCartGroupCell.h
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGMallCartGroup;
@class YGMallCart;

UIKIT_EXTERN NSString *const kYGMallCartGroupCell;

/**
 商城购物车商品列表一组商品的头部cell
 */
@interface YGMallCartGroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectionBtn;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupTitleLabel;

@property (copy, nonatomic) void (^groupSelectionBlock)(YGMallCartGroup *group);

@property (strong, readonly, nonatomic) YGMallCartGroup *group;
- (void)configureWithGroup:(YGMallCartGroup *)group inCart:(YGMallCart *)cart;

@end
