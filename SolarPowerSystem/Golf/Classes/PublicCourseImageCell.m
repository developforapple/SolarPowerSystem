//
//  PublicCourseImageCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/23.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseImageCell.h"

@implementation PublicCourseWebCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_waitingView startAnimating];
}

@end

@implementation PublicCourseAddressCell


@end

@implementation PublicCourseDateTimeCell

@end

@implementation PublicCourseCoachInfoCell

- (void)setStarLevel:(float)starLevel{
    _starLevel = starLevel;
    _widthConstraint.constant = [self starLevel:_starLevel];//lyf 加
 
}

//设置星星级别  //浦发红酒300176
- (CGFloat)starLevel:(float)starLevel{
    return 80.0/5 * starLevel;
}

@end

@implementation PublicCourseTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _topLineView.hidden = YES;
    _botLineView.hidden = NO;
}

@end

@implementation PublicCourseCommentTotalCell



@end

@implementation PublicCourseImageListCell


- (void)setJoinList:(NSArray *)joinList{
    _joinList = joinList;
    for (int i=0; i< MIN(_joinList.count, [self maxImageCount]); i++) {
        JoinModel *join = _joinList[i];
        UIImageView *hx = (UIImageView *)[self.bgView viewWithTag:i+1];
        if (i == [self maxImageCount]-1) {
            hx.image = [UIImage imageNamed:@"head_member_more.png"];
        }else{
            if (join.headImage.length>0) {
                [hx sd_setImageWithURL:[NSURL URLWithString:join.headImage] placeholderImage:[UIImage imageNamed:@"pic_zhanwei"]];
            }else{
                hx.image = [UIImage imageNamed:@"head_member"];
            }
        }
    }
}

- (NSInteger)maxImageCount{
    if (Device_Width == 320) {
        return 7;
    }else if (Device_Width == 375){
        return 8;
    }else {
        return 9;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    for (UIImageView *iv in _imageViews) {
        if (CGRectContainsPoint(iv.frame, pt)) {
            if (_blockReturn) {
                _blockReturn (@(iv.tag-1));
            }
        }
    }
}

@end

@implementation PublicCourseImageCell

@end
