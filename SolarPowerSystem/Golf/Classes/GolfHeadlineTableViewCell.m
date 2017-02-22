//
//  GolfHeadlineTableViewCell.m
//  Golf
//
//  Created by liangqing on 16/8/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "GolfHeadlineTableViewCell.h"
#import "YGYueduVideoHelper.h"
@implementation GolfHeadlineTableViewCell{
    UIImage *defaultImage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    defaultImage = [UIImage imageNamed:@"default_"];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor colorWithHexString:@"#eeeeee"] colorWithAlphaComponent:.5];
    self.selectedBackgroundView = view;
}

-(void)setHeadLineBean:(HeadLineBean *)headLineBean{
    
    if (headLineBean == nil) {
        for (UIView *subView in self.contentView.subviews) {
            subView.hidden = YES;
        }
    }else{
        for (UIView *subView in self.contentView.subviews) {
            subView.hidden = NO;
        }
    }
    
    if (headLineBean == nil || _headLineBean == headLineBean) {
        return;
    }
    
    _headLineBean = headLineBean;
    [Utilities loadImageWithURL:[NSURL URLWithString:_headLineBean.picUrl] inImageView:self.articleImageViews placeholderImage:defaultImage];
    self.articleTitleLabel.text = _headLineBean.linkTitle;
    self.articleDateLabel.text = _headLineBean.createdAt;
    self.articleSourceLabel.text = _headLineBean.accountName;
    self.articleCategoryLabel.text = _headLineBean.categoryName;
}

- (IBAction)videoPlay:(id)sender {
    if (self.blockVideoPlay) {
        self.blockVideoPlay(_headLineBean);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (!selected) {
        return;
    }
    [[API shareInstance] statisticalNewWithBuriedpoint:34 objectID:0 Success:nil failure:nil];//埋点
    NSDictionary *dict = @{@"data_extra":@"2",@"data_id":@(_headLineBean.id),@"data_type":@"yuedu",@"sub_type":@"1"};
    [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dict];
}

@end
