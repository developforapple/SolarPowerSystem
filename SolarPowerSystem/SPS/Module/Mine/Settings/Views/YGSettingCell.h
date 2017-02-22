//
//  YGSettingCell.h
//  Golf
//
//  Created by zhengxi on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *trailingLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (strong, nonatomic) void (^switchButtonBlock) (BOOL);
@end
