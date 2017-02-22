//
//  VoucherDetailTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/4/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "VoucherDetailTableViewCell.h"

@interface VoucherDetailTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDatetime;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOther;

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgTag;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UIView *line3;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UIView *viewBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgFooter;
@property (weak, nonatomic) IBOutlet UILabel *labelUnit;
@property (weak, nonatomic) IBOutlet UILabel *labelType;

@end

@implementation VoucherDetailTableViewCell

- (void)defaultStyle{
    _imgHeader.image = [UIImage imageNamed:@"img_ticket_top_red"];
    _imgFooter.image = [UIImage imageNamed:@"img_ticket_footer"];
    _viewBg.backgroundColor = [UIColor whiteColor];
    _labelUnit.textColor = [UIColor colorWithHexString:@"#555656"];
    _labelPrice.textColor = [UIColor colorWithHexString:@"#555656"];
    _labelOther.textColor = [UIColor colorWithHexString:@"#555656"];
    _labelDatetime.textColor = [UIColor colorWithHexString:@"#878787"];
    _labelTitle.textColor = [UIColor colorWithHexString:@"#D16F6E"];
    _line1.backgroundColor = [UIColor colorWithHexString:@"#878787"];
    _line2.backgroundColor = [UIColor colorWithHexString:@"#878787"];
    _labelDatetime.backgroundColor = [UIColor whiteColor];
}

- (void)disabledStyle{
    _imgHeader.image = [UIImage imageNamed:@"img_ticket_top_gray"];
    _imgFooter.image = [UIImage imageNamed:@"img_ticket_footer_gray"];
    
    _viewBg.backgroundColor = [UIColor colorWithHexString:@"#c9c9c9"];
    _labelTitle.textColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _labelPrice.textColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _labelOther.textColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _labelDatetime.textColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _labelUnit.textColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _line1.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _line2.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _labelDatetime.backgroundColor = [UIColor colorWithHexString:@"#c9c9c9"];
}

- (void)setIcon:(CouponModel *)modal{
    switch (modal.subType) {
        case 1:
            _labelType.hidden = YES;
            _line3.hidden = YES;
            switch (modal.couponStatus) {
                case 1:
                    _imgIcon.image = [UIImage imageNamed:@"img_home_gray"];
                    break;
                case 2:
                case 3:
                case 4:
                    _imgIcon.image = [UIImage imageNamed:@"img_home_dark"];
                    break;
                    break;
                default:
                    break;
            }
            break;
        case 2:
        case 3:
        case 4:
            _labelType.text = @"可用商品";
            switch (modal.couponStatus) {
                case 1:
                    _imgIcon.image = [UIImage imageNamed:@"img_bag_gray"];
                    break;
                case 2:
                case 3:
                case 4:
                    _imgIcon.image = [UIImage imageNamed:@"img_bag_dark"];
                    break;
                    break;
                default:
                    break;
            }
            break;
        case 5:
            _labelType.text = @"可用球场";
            switch (modal.couponStatus) {
                case 1:
                    _imgIcon.image = [UIImage imageNamed:@"img_flag_gray"];
                    break;
                case 2:
                case 3:
                case 4:
                    _imgIcon.image = [UIImage imageNamed:@"img_flag_dark"];
                    break;
                default:
                    break;
            }
            break;
        case 6:
            _labelType.text = @"可用课程";
            switch (modal.couponStatus) {
                case 1:
                    _imgIcon.image = [UIImage imageNamed:@"img_class_gray"];
                    break;
                case 2:
                case 3:
                case 4:
                    _imgIcon.image = [UIImage imageNamed:@"img_class_dark"];
                    break;
                default:
                    break;
            }
            break;
        case 7:
            _labelType.text = @"可用教练";
            switch (modal.couponStatus) {
                case 1:
                    _imgIcon.image = [UIImage imageNamed:@"img_coach_gray"];
                    break;
                case 2:
                case 3:
                case 4:
                    _imgIcon.image = [UIImage imageNamed:@"img_coach_dark"];
                    break;
                default:
                    break;
            }
            break;
        case 8:
            _labelType.text = @"可用课程";
            switch (modal.couponStatus) {
                case 1:
                    _imgIcon.image = [UIImage imageNamed:@"img_class_gray"];
                    break;
                case 2:
                case 3:
                case 4:
                    _imgIcon.image = [UIImage imageNamed:@"img_class_dark"];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

-(void)setCouponModel:(CouponModel *)model hideLine:(BOOL)hide{
    if (model) {
        [self setIcon:model];
        
        _line3.hidden = hide;
        _labelType.hidden = hide;
        
        _labelPrice.text = [NSString stringWithFormat:@"%d",model.couponAmount];
        _labelOther.text = model.couponDescription;
        _labelTitle.text = model.couponName;
        switch (model.couponStatus) {
            case 1:
                [_labelDatetime setText:[NSString stringWithFormat:@"有效期至 %@",model.expireTime]];
                _imgTag.image = [UIImage imageNamed:@"img_unused_red"];
                [self defaultStyle];
                break;
            case 2:
                [_labelDatetime setText:[NSString stringWithFormat:@"%@ 已使用",model.tranTime]];
                _imgTag.image = [UIImage imageNamed:@"img_used_gray"];
                [self disabledStyle];
                break;
            case 3:
                [_labelDatetime setText:[NSString stringWithFormat:@"%@ 已过期",model.expireTime]];
                _imgTag.image = [UIImage imageNamed:@"img_invalid_gray"];
                [self disabledStyle];
                break;
            case 4:
                [_labelDatetime setText:[NSString stringWithFormat:@"%@ 已赠送",model.expireTime]];
                _imgTag.image = [UIImage imageNamed:@"ic_presented"];
                [self disabledStyle];
                break;
            default:
                break;
        }
        
    }
}

@end
