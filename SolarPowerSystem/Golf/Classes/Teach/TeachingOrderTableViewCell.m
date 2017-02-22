//
//  TeachingOrderTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingOrderTableViewCell.h"
#import "MyButton.h"

@interface TeachingOrderTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelDatetime;
@property (weak, nonatomic) IBOutlet MyButton *btnAction;
@property (weak, nonatomic) IBOutlet UILabel *labelYunbi;
@end

@implementation TeachingOrderTableViewCell{
    TeachingOrderModel *modal;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _labelYunbi.layer.borderColor = [UIColor colorWithHexString:@"#ff6d00"].CGColor;
}


-(void)loadData:(TeachingOrderModel *)data isCoach:(BOOL)isCoach{
    modal = data;
    _labelCourseName.text = data.productName;
    _labelName.text = data.nickName;
    _labelPrice.text = [NSString stringWithFormat:@"%d",data.price];
    _labelDatetime.text = isCoach ? data.orderTime:@"";
    if (isCoach) {
        _labelYunbi.text = @"";
    }else{
        _labelYunbi.text = data.giveYunbi > 0 ? ([NSString stringWithFormat:@" 返%d ",data.giveYunbi]):@"";
    }
    
    switch (data.orderState) {
        case 1:
            _labelStatus.textColor = [UIColor colorWithHexString:@"#249df3"];
            _labelStatus.text = @"教学中";
            break;
        case 2:
            _labelStatus.textColor = [UIColor colorWithHexString:@"#999999"];
            _labelStatus.text = @"已完成";
            break;
        case 3:
            _labelStatus.textColor = [UIColor colorWithHexString:@"#999999"];;
            _labelStatus.text = @"已过期";
            break;
        case 4:
            _labelStatus.textColor = [UIColor colorWithHexString:@"#999999"];;
            _labelStatus.text = @"已取消";
            break;
        case 6: //@"待付款"
             _labelStatus.textColor = [UIColor colorWithHexString:@"#249df3"];
            _labelStatus.text = @"待付款";
            break;
        default:
            _btnAction.hidden = YES;
            _labelStatus.hidden = YES;
            break;
    }
}

- (IBAction)btnPressed:(id)sender {
    if (_blockReturn) {
        _blockReturn(modal);
    }
}

@end
