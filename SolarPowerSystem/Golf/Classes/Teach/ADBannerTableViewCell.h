//
//  ADBannerTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityModel;

@interface ADBannerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgBanner;
@property (strong, nonatomic) ActivityModel *activityModel;
@property (copy, nonatomic) BlockReturn blockReturn;
@property (nonatomic,strong) IBOutlet UIView *bottomLine;
@end
