//
//  TextTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTextValue;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (copy, nonatomic) void (^rightBtnAction)(void);

@end
