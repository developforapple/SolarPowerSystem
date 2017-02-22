//
//  YGPayThridPlatformCell.h
//  Golf
//
//  Created by bo wang on 2016/12/2.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGPayPlatformItem.h"

UIKIT_EXTERN NSString *const kYGPayThridPlatformCell;

@interface YGPayThridPlatformCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *platformNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *platformDescLabel;
@property (weak, nonatomic) IBOutlet UIImageView *decorateImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@property (strong, readonly, nonatomic) YGPayPlatformItem *platformItem;
- (void)configureWithItem:(YGPayPlatformItem *)item;

@property (copy, nonatomic) void (^selectionDidChanged)(YGPayPlatformItem *item);

@end
