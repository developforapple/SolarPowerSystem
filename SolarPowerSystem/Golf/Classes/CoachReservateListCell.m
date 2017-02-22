//
//  CoachReservateListCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachReservateListCell.h"

@interface CoachReservateListCell ()

@property (nonatomic,weak) IBOutlet UIImageView *headImageV;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UIImageView *lineImageV;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *courseNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *courseDateLabel;
@property (nonatomic,weak) IBOutlet UILabel *courseStatusLabel;
@property (nonatomic,weak) IBOutlet UIButton *statusButton;


@end

@implementation CoachReservateListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_headImageV radius:19 bordLineWidth:0 borderColor:nil];
    [Utilities drawView:_statusButton radius:3 bordLineWidth:0 borderColor:nil];
    _lineImageV.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_ppline_blue"]];
}

- (void)setRm:(ReservationModel *)rm{
    _rm = rm;
    if (_rm) {
        [_headImageV sd_setImageWithURL:[NSURL URLWithString:_rm.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];

        _nameLabel.text = _rm.nickName.length>0 ? _rm.nickName : @"";
        _dateLabel.text = _rm.createTime.length>0 ? _rm.createTime : @"";
        _courseNameLabel.text = _rm.productName.length>0 ? _rm.productName : @"";
        _courseDateLabel.text = _rm.reservationDate.length>0 ? [NSString stringWithFormat:@"%@ %@",_rm.reservationDate,_rm.reservationTime] : @"";
        _courseStatusLabel.text = [self stringWithStatus:_rm.reservationStatus];
        
        if (_rm.reservationStatus == 1) {
            _courseStatusLabel.textColor = MainHighlightColor;
        }else{
            _courseStatusLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        }
        
        if (_rm.reservationStatus == 5) {
            [_statusButton setTitle:@"待确认" forState:UIControlStateNormal];
            _statusButton.hidden = NO;
            _courseStatusLabel.hidden = YES;
        }else{
            _statusButton.hidden = YES;
            _courseStatusLabel.hidden = NO;
        }
    }
}

- (IBAction)buttonPressed:(id)sender{
    if (_blockReturn) {
        _blockReturn (nil);
    }
}

- (NSString*)stringWithStatus:(int)status{
    NSString *value = @"";
    switch (status) {
        case 1:
            value = @"待上课";
            break;
        case 2:
            value = @"已完成";
            break;
        case 3:
            value = @"未到场";
            break;
        case 4:
            value = @"已取消";
            break;
        case 5:
            value = @"待确认";
            break;
        case 6:
            value = @"待评价";
            break;
        default:
            break;
    }
    return value;
}

@end
