//
//  VoucherNormalTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/4/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "VoucherTableViewCell.h"

@interface VoucherTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelOther;

@property (weak, nonatomic) IBOutlet UIView *viewBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgMore;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgChecker;
@property (weak, nonatomic) IBOutlet UILabel *labelUnit;
@property (weak, nonatomic) IBOutlet UILabel *labelCantUse;

@end

@implementation VoucherTableViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    _viewBg.layer.borderColor = [UIColor colorWithHexString:@"#e2e2e6"].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOther:(NSString *)other{
    _labelOther.text = other;
}

- (void)setPrice:(NSString *)price{
    _labelPrice.text = price;
}

- (void)setTitle:(NSString *)title{
    _labelTitle.text = title;
}

//- (void)layout{
//    
//    CGRect frameTitle = _labelTitle.frame;
//    NSString *title = _labelTitle.text;
//    CGRect frameTitle2 = CGRectMake(frameTitle.origin.x, frameTitle.origin.y, frameTitle.size.width, [title sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(_labelTitle.frame.size.width, 42)].height);
//    _labelTitle.frame = frameTitle2;
//    
//    CGRect frameOther = _labelOther.frame;
//    NSString *other = _labelOther.text;
//    CGRect frameOther2 = CGRectMake(frameOther.origin.x, frameOther.origin.y, frameOther.size.width, [other sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(_labelOther.frame.size.width, 40)].height);
//    _labelOther.frame = frameOther2;
//    
//    CGFloat labelsHeight = frameTitle2.size.height + frameOther2.size.height; //标题和详情label的高度之和
//    
//    //cell高度的一半减去 labels高度值和的一半 就是标题label的y
//    _labelTitle.frame = CGRectMake(frameTitle2.origin.x, 90/2 - (labelsHeight/2), frameTitle2.size.width, frameTitle2.size.height);
//    
//    //日期label的y
//    _labelOther.frame = CGRectMake(frameOther2.origin.x, (frameTitle2.origin.y + frameTitle2.size.height + (frameTitle2.size.height > 17.0 ? 0:4)), frameOther2.size.width, frameOther2.size.height);
//}


// 分别处理不同的展示方式

-(void)setViewType:(VoucherTableViewType)viewType{
    _labelOther.textColor = [UIColor colorWithHexString:@"#8A8A8A"];
    _labelPrice.textColor = [UIColor blackColor];
    _labelTitle.textColor = [UIColor blackColor];
    _labelUnit.textColor = [UIColor blackColor];
    _viewBg.backgroundColor = [UIColor whiteColor];
    _viewBg.layer.borderColor = [UIColor colorWithHexString:@"#e2e2e6"].CGColor;
    _imgHeader.image = [UIImage imageNamed:@"img_ticket_header"];
    _labelCantUse.hidden = YES;
    
    switch (viewType) {
        case VoucherTableViewTypeMore:
            _imgMore.hidden = NO;
            _imgChecker.hidden = YES;
            break;
        case VoucherTableViewTypeChecked:
            _imgMore.hidden = YES;
            _imgChecker.hidden = NO;
            _imgChecker.image = [UIImage imageNamed:@"img_checked"];
            break;
        case VoucherTableViewTypeUnchecked:
            _imgMore.hidden = YES;
            _imgChecker.hidden = NO;
            _imgChecker.image = [UIImage imageNamed:@"img_unchecked"];
            break;
        case VoucherTableViewTypeNone:
            _imgChecker.hidden = YES;
            _imgMore.hidden = YES;
            break;
        case VoucherTableViewTypeDisabled:
            _imgMore.hidden = YES;
            _imgChecker.hidden = YES;
            _imgHeader.image = [UIImage imageNamed:@"img_ticket_header_gray"];
            _viewBg.backgroundColor = [UIColor colorWithHexString:@"#c9c9c9"];
            _viewBg.layer.borderColor = [UIColor colorWithHexString:@"#c9c9c9"].CGColor;
            _labelOther.textColor = [UIColor whiteColor];
            _labelPrice.textColor = [UIColor whiteColor];
            _labelTitle.textColor = [UIColor whiteColor];
            _labelUnit.textColor = [UIColor whiteColor];
            break;
        case VoucherTableViewTypeCantUse:
            _imgMore.hidden = YES;
            _imgChecker.hidden = YES;
            _labelCantUse.hidden = NO;
            break;
        default:
            break;
    }
}

@end
