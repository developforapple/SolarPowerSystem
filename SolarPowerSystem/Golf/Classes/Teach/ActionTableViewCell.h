//
//  ActionTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionTableViewCell : UITableViewCell

@property (copy, nonatomic) BlockReturn blockReturn;
@property (weak, nonatomic) IBOutlet UIButton *btnAction;

@end
