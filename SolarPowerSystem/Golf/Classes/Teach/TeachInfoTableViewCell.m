//
//  TeachInfoTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachInfoTableViewCell.h"
#import "MyButton.h"

@interface TeachInfoTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *labelPublicClass;
@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@property (weak, nonatomic) IBOutlet UILabel *labelDateTime;
@property (weak, nonatomic) IBOutlet UILabel *labelCoachName;
@property (weak, nonatomic) IBOutlet UILabel *labelLocationName;
@property (weak, nonatomic) IBOutlet UIImageView *imageHead;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet MyButton *btnAction;

@end

@implementation TeachInfoTableViewCell{
    NSDictionary *model;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _labelPublicClass.layer.borderColor = [UIColor colorWithRed:109/255.0 green:210/255.0 blue:112/255.0 alpha:1.0].CGColor;
}

- (IBAction)btnAction:(id)sender {
    if (_blockReturn) {
        _blockReturn(model);
    }
}

-(void)loadData:(NSDictionary *)nd{
    if (model == nd) {
        return;
    }
    model = nd;
    ReservationModel *m = nd[@"data"];
    _labelCoachName.text = m.nickName;
    _labelCourseName.text = m.productName;
    NSString *date = m.reservationDate;
    if (Device_Width == 320.0 && date.length > 6) {
        date = [date substringFromIndex:5];
    }
    _labelDateTime.text = [NSString stringWithFormat:@"%@ %@",date,m.reservationTime];
    _labelLocationName.text = m.teachingSite;
    [_imageHead sd_setImageWithURL:[NSURL URLWithString:m.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
    _labelPublicClass.hidden = m.publicClassId > 0 ? NO:YES;
    
    switch (m.reservationStatus) {
        case 1:
            _labelStatus.textColor = [UIColor colorWithRed:85/255.0 green:192/255.0 blue:234/255.0 alpha:1.0];
            _labelStatus.text = @"待上课";
            break;
        case 2:
            _labelStatus.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _labelStatus.text = @"已完成";
            break;
        case 3:
            _labelStatus.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _labelStatus.text = @"未到场";
            break;
        case 4:
            _labelStatus.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _labelStatus.text = @"已取消";
            break;
        case 5:
            _labelStatus.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _labelStatus.text = @"待确认";
            break;
        case 6:
            _labelStatus.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _labelStatus.text = @"待评价";
            break;
            
        default:
//            _btnAction.hidden = YES;
//            _labelStatus.hidden = YES;
            break;
    }
}

@end
