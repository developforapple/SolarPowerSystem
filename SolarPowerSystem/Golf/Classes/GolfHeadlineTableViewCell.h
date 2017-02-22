//
//  GolfHeadlineTableViewCell.h
//  Golf
//
//  Created by liangqing on 16/8/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYAnimatedImageView.h"
@interface GolfHeadlineTableViewCell : UITableViewCell
@property (nonatomic,strong) HeadLineBean *headLineBean;

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *articleImageViews;
@property (weak, nonatomic) IBOutlet UILabel *articleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleSourceLabel;

@property (nonatomic,copy) BlockReturn blockVideoPlay;

@property (nonatomic,copy) BlockReturn blockMore;
@end
