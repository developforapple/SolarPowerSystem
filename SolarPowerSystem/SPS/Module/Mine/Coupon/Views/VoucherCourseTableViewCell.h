//
//  VoucherCourseTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/7/1.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoucherCourseTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOldPrice;

@end
