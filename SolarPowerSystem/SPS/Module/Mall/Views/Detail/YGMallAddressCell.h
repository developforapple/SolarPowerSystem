//
//  YGMallAddressCell.h
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGMallAddressModel.h"

UIKIT_EXTERN NSString *const kYGMallAddressCell;

@interface YGMallAddressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *selectedIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property (strong, readonly, nonatomic) YGMallAddressModel *address;
- (void)configureWithAddress:(YGMallAddressModel *)address;

@property (copy, nonatomic) void (^willEditAddress)(YGMallAddressModel *address);

@end
