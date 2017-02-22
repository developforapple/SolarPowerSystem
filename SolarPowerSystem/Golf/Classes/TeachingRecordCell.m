//
//  TeachingRecordCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingRecordCell.h"

@implementation TeachingRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_teachingBtn radius:3 bordLineWidth:0 borderColor:[UIColor whiteColor]];
}

- (IBAction)buttonPressed:(id)sender{
    if (_blockReturn) {
        _blockReturn (nil);
    }
}

- (void)setRm:(ReservationModel *)rm{
    _rm = rm;
    if (_rm) {
        [_dateTimeLabel setText:_rm.reservationDate.length>0 ? [NSString stringWithFormat:@"%@ %@",_rm.reservationDate,_rm.reservationTime] : @""];
        [_teachingStatusLabel setText:[self stringWithStatus:_rm.reservationStatus]];
        
        if (_rm.reservationStatus == 1) {
            _teachingStatusLabel.textColor = MainHighlightColor;
        }else{
            _teachingStatusLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        }
        
        if (_rm.reservationStatus == 5) {
            [_teachingBtn setTitle:@"待确认" forState:UIControlStateNormal];
            _teachingBtn.hidden = NO;
            _teachingStatusLabel.hidden = YES;
        }else{
            _teachingBtn.hidden = YES;
            _teachingStatusLabel.hidden = NO;
        }
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
