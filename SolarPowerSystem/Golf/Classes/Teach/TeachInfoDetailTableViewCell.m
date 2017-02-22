//
//  TeachInfoDetailTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachInfoDetailTableViewCell.h"

@interface TeachInfoDetailTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelDatetime;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine;
@property (weak, nonatomic) IBOutlet UILabel *labelPublicCourse;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelSiteName;


@end

@implementation TeachInfoDetailTableViewCell{
    ReservationModel *m;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _imgLine.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_ppline_blue"]];
    _labelPublicCourse.layer.borderColor = [UIColor colorWithRed:109/255.0 green:210/255.0 blue:112/255.0 alpha:1.0].CGColor;
}

- (IBAction)btnPressed:(id)sender {
    if (_blockReturn) {
        _blockReturn(m);
    }
}
- (IBAction)btnImagePressed:(id)sender {
    if (_blockImagePressed) {
        _blockImagePressed(m);
    }
}



-(void)loadData:(ReservationModel *)rm{
    m = rm;
    
    _labelDatetime.text = [NSString stringWithFormat:@"%@预约",rm.createTime];
    
    _labelCourseName.text = rm.productName;
    _labelName.text = rm.nickName;
    
    _labelDate.text = [NSString stringWithFormat:@"%@ %@",rm.reservationDate,rm.reservationWeekname];
    _labelTime.text = rm.reservationTime;
    
    _labelSiteName.text = rm.teachingSite;
    _labelAddress.text = [NSString stringWithFormat:@"%.2fkm %@",rm.distance,rm.address];
    
    if (_imgHead.image == nil) {
        [_imgHead sd_setImageWithURL:[NSURL URLWithString:rm.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
    }
    
    
    
    switch (rm.reservationStatus) {
        case 1:
            _labelStatus.text = @"待上课";
            break;
        case 2:
            _labelStatus.text = @"已完成";
            break;
        case 3:
            _labelStatus.text = @"未到场";
            break;
        case 4:
            _labelStatus.text = @"已取消";
            break;
        case 5:
            _labelStatus.text = @"待确认";
            break;
        case 6:
            _labelStatus.text = @"待评价";
            break;
        default:
            break;
    }
}

@end
