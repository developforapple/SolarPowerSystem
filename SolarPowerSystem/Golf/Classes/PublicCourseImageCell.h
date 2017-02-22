//
//  PublicCourseImageCell.h
//  Golf
//
//  Created by 黄希望 on 15/6/23.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BridgeWebView.h"

@interface PublicCourseWebCell : UITableViewCell

@property (nonatomic,weak) IBOutlet BridgeWebView *bweb;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *waitingView;

@end

@interface PublicCourseAddressCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *teachingSiteLabel;
@property (nonatomic,weak) IBOutlet UILabel *addressLabel;

@end

@interface PublicCourseDateTimeCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *dateTimeLabel;

@end

@interface PublicCourseCoachInfoCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *coachNameLabel;
@property (nonatomic,weak) IBOutlet UIImageView *starImageView;
@property (nonatomic,weak) IBOutlet UIImageView *headImageView;
@property (nonatomic,weak) IBOutlet UIImageView *coachLevelImg;
@property (nonatomic,assign) float starLevel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;//lyf 加

@end

@interface PublicCourseCommentTotalCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *totalLabel;;

@end

@interface PublicCourseTitleCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *cusTitleLabel;
@property (nonatomic,weak) IBOutlet UIView *topLineView;
@property (nonatomic,weak) IBOutlet UIView *botLineView;

@end

@interface PublicCourseImageListCell : UITableViewCell

@property (nonatomic,strong) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (nonatomic,weak) IBOutlet UIView *bgView;
@property (nonatomic,strong) NSArray *joinList;
@property (nonatomic,copy) BlockReturn blockReturn;

@end

@interface PublicCourseImageCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *headImageView;
@property (nonatomic,weak) IBOutlet UILabel *productNameLabel;

@end
