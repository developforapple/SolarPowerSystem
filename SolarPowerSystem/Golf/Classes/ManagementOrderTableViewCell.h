//
//  ManagementOrderTableViewCell.h
//  Golf
//
//  Created by zhengxi on 15/12/16.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kManagementOrderTableViewCell;

@interface ManagementOrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *signLabel;
@property (weak, nonatomic) IBOutlet UILabel *trailingLabel;

@end
