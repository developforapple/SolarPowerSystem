//
//  TitleValueTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReservationModel.h"

@interface TitleValueTableViewCell : UITableViewCell

@property (strong, nonatomic) ReservationModel *rm;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelValue;
@property (weak, nonatomic) IBOutlet UILabel *labelValue2;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;

@property (copy, nonatomic) BlockReturn blockReturn;

@end
