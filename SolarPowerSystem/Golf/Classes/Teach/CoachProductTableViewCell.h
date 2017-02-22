//
//  CoachProductTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachProductTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOldPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnAction;
@property (weak, nonatomic) IBOutlet UILabel *labelFanxian;
@property (strong,nonatomic) TeachProductDetail *tpd;

@property (copy,nonatomic) BlockReturn blockReturn;
@end
