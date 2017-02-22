//
//  CourseBuyView.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/18.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CourseBuyView.h"
#import "TeachingCourseType.h"

@interface CourseBuyView()<YGLoginViewCtrlDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOldPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelValidDate;
@property (weak, nonatomic) IBOutlet UITextView *txtContent;

@property (weak, nonatomic) IBOutlet UILabel *labelFanxian;
@property (weak, nonatomic) IBOutlet UIButton *btnAction;
@property (weak, nonatomic) IBOutlet UILabel *labelBuyGuid;

@end

@implementation CourseBuyView{
    TeachProductDetail *_pd;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self layoutIfNeeded];
    _imgHead.layer.cornerRadius = _imgHead.bounds.size.width / 2;
    _imgHead.layer.borderColor = [UIColor whiteColor].CGColor;
    _imgHead.layer.borderWidth = 1.5;
    _labelFanxian.layer.borderColor = [UIColor colorWithHexString:@"#ffbf74"].CGColor;
}

- (void)okBuy
{
    if (_blockReturn) {
        _blockReturn(_pd);
    }
}

- (IBAction)btnBuy:(id)sender {
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES blockRetrun:^(id data) {
            [self okBuy];
        }];
    }else{
        [self okBuy];
    }
}

- (void)loadData:(TeachProductDetail *)pd teachingCoachModel:(TeachingCoachModel *)tcm{
    // 先调整宽度为屏幕宽度再填充内容
    [self layoutIfNeeded];
    
    _pd = pd;
    [self.imgHead sd_setImageWithURL:[NSURL URLWithString:tcm.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
    _labelCourseName.text = pd.productName;
    _labelName.text = (tcm.nickName == nil || tcm.nickName.length  == 0) ? tcm.displayName:tcm.nickName;
    _labelOldPrice.text = [NSString stringWithFormat:@"%d",pd.originalPrice];
    _labelPrice.text = [NSString stringWithFormat:@"%d",pd.sellingPrice];
    _labelValidDate.text = [NSString stringWithFormat:@"有效期%d天",pd.validDays];
    _labelFanxian.text = pd.giveYunbi > 0 ? ([NSString stringWithFormat:@" 返%d ",pd.giveYunbi]):(@"");
    // 专项课 和 套课
    BOOL isBuy = (pd.classType == TeachingCourseTypeMulti || pd.classType == TeachingCourseTypeSpecial);
    [_btnAction setTitle:(isBuy ? @"立即购买":@"立即预约") forState:(UIControlStateNormal)];
    _labelBuyGuid.text = pd.buyGuide;

    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:pd.productIntro];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] range:NSMakeRange(0, str.length )];
    _txtContent.attributedText = str;
    _txtContent.font = [UIFont systemFontOfSize:14];
    
    [self layoutIfNeeded];
}

- (IBAction)close:(id)sender {
    if (_blockHide) {
        _blockHide(nil);
    }
}

@end
