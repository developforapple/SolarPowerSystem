//
//  YGYueduVideoCell.h
//  Golf
//
//  Created by liangqing on 16/9/1.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGYueduVideoCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UIImageView *articleImageViews;
@property (weak,nonatomic) IBOutlet UILabel *articleTitleLabel;
@property (weak,nonatomic) IBOutlet UILabel *articleDateLabel;
@property (weak,nonatomic) IBOutlet UILabel *articleSourceLabel;
@property (weak,nonatomic) IBOutlet UILabel *articleCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleVideoLengthLabel;

@property (nonatomic,strong) HeadLineBean *headLineBean;
@property (nonatomic,copy) BlockReturn blockPlay;
@end
