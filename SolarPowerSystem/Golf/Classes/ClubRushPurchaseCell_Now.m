//
//  ClubRushPurchaseCell_Now.m
//  Golf
//
//  Created by 黄希望 on 15/10/12.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubRushPurchaseCell_Now.h"

@implementation ClubRushPurchaseCell_Now{
    UIImage *defaultImage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    defaultImage = [UIImage imageNamed:@"pic_zhanwei"];
    [self changeButtonFrame];
}

- (void)changeButtonFrame{
    for (NSLayoutConstraint *lc in _opeBtn.constraints) {
        if (lc.firstAttribute == NSLayoutAttributeWidth) {
            if (IS_4_7_INCH_SCREEN) {
                lc.constant = 69;
            }else if (IS_5_5_INCH_SCREEN){
                lc.constant = 74;
            }else{
                lc.constant = 54;
            }
            [_opeBtn layoutIfNeeded];
        }
    }
}

- (void)setCsm:(ClubSpreeModel *)csm
{
    if (_csm == csm) {
        return;
    }
    _csm = csm;
    [Utilities loadImageWithURL:[NSURL URLWithString:csm.clubPhoto] inImageView:_clubImageView placeholderImage:defaultImage];
    [_clubNameLabel setText:csm.spreeName.length>0 ? csm.spreeName : @""];
    NSString *datestr = [Utilities getDateStringFromString:csm.teeDate WithFormatter:@"MM月dd日"];
    NSString *teetime = [NSString stringWithFormat:@"开球：%@ %@-%@",datestr,csm.startTime,csm.endTime];
    [_clubTeetimeLabel setText:teetime];
    [_remainderPeopleLabel setText:[NSString stringWithFormat:@"仅剩%d位",csm.stockQuantity-csm.soldQuantity]];
    [_currentPriceLabel setText:[NSString stringWithFormat:@"%d",csm.currentPrice]];
    [_originalPriceLabel setText:[NSString stringWithFormat:@" ¥%d ",csm.originalPrice]];
    [_returnYunbiLabel setText:csm.giveYunbi>0?[NSString stringWithFormat:@" 返%d ",csm.giveYunbi]:@""];
    [_distanceLabel setText:[NSString stringWithFormat:@"%.0fkm",csm.remote]];
    
    [_opeBtn setTitle:@"抢购" forState:UIControlStateNormal];
    [_opeBtn setBackgroundColor:[UIColor colorWithHexString:@"ff6d00"]];
    [Utilities drawView:_opeBtn radius:3 bordLineWidth:0 borderColor:nil];
    _opeBtn.enabled = YES;
    [_remainderPeopleLabel setTextColor:[UIColor colorWithHexString:@"999999"]];
    if (csm.stockQuantity-csm.soldQuantity<=0) {
        [_remainderPeopleLabel setText:@"来晚了，都被抢光了"];
        [_remainderPeopleLabel setTextColor:[UIColor colorWithHexString:@"999999"]];
        [_opeBtn setTitle:@"抢光了" forState:UIControlStateNormal];
        [_opeBtn setBackgroundColor:[UIColor colorWithHexString:@"c8c8c8"]];
        _opeBtn.enabled = NO;
        [Utilities drawView:_opeBtn radius:3 bordLineWidth:0 borderColor:nil];
    }else if (csm.stockQuantity-csm.soldQuantity<=4){
        _remainderPeopleLabel.textColor = [UIColor colorWithHexString:@"f96464"];
    }else{
        _remainderPeopleLabel.textColor = [UIColor colorWithHexString:@"999999"];
    }
    _littleLabelFlag.hidden = csm.stockQuantity-csm.soldQuantity>0 && csm.stockQuantity-csm.soldQuantity<=4 ? NO : YES;
    
    for (NSLayoutConstraint *lc in _originalPriceLabel.superview.constraints) {
        if (lc.firstAttribute == NSLayoutAttributeLeading && lc.firstItem == _originalPriceLabel) {
            lc.constant = _csm.giveYunbi>0 ? 10 : 5;
            [_originalPriceLabel.superview layoutIfNeeded];
            break;
        }
    }
}



@end
