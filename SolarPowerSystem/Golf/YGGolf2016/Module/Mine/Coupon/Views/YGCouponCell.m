//
//  YGCouponCell.m
//  Golf
//
//  Created by bo wang on 2016/10/24.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGCouponCell.h"
#import "CouponModel.h"
#import "SearchService.h"

NSString *const kYGCouponCell = @"YGCouponCell";

@interface YGCouponCell ()
@property (weak, nonatomic) IBOutlet UIImageView *decorationImageView;
@property (weak, nonatomic) IBOutlet UIView *couponPanel;
@property (weak, nonatomic) IBOutlet UIView *pricePanel;
@property (weak, nonatomic) IBOutlet UILabel *amountUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *availabilityLabel;

@property (weak, nonatomic) IBOutlet UIView *infoPanel;
@property (weak, nonatomic) IBOutlet UILabel *couponTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponDateDescLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoRightToIndicatorConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoRightToPanelConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *selectionIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *verticalLineView;

@end

@implementation YGCouponCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)configureWithCoupon:(CouponModel *)coupon
{
    _coupon = coupon;
    
    self.amountLabel.text = [NSString stringWithFormat:@"%d",coupon.couponAmount];
    self.couponTitleLabel.text = coupon.couponName;
    if (!self.descText) {
        self.descText = [self defaultDescText];
    }
    self.couponDateDescLabel.text = self.descText;
    
    [self update];
}

- (void)setDescText:(NSString *)descText
{
    _descText = descText;
    self.couponDateDescLabel.text = descText;
}

- (void)update
{
    if (self.enabled) {
        self.decorationImageView.highlighted = YES;
        self.couponPanel.backgroundColor = [UIColor whiteColor];
        UIColor *textColor = RGBColor(51, 51, 51, 1);
        self.amountUnitLabel.textColor = textColor;
        self.amountLabel.textColor = textColor;
        self.couponTitleLabel.textColor = textColor;
        self.couponDateDescLabel.textColor = RGBColor(119, 119, 119, 1);
    }else{
        self.decorationImageView.highlighted = NO;
        self.couponPanel.backgroundColor = RGBColor(201, 201, 201, 1);
        self.amountUnitLabel.textColor = [UIColor whiteColor];
        self.amountLabel.textColor = [UIColor whiteColor];
        self.couponTitleLabel.textColor = [UIColor whiteColor];
        self.couponDateDescLabel.textColor = [UIColor whiteColor];
    }
    
    if (self.selectionMode) {
        self.availabilityLabel.hidden = self.usable;
        self.selectionIndicator.hidden = !self.usable;
        self.selectionIndicator.highlighted = self.selected;
        self.infoRightToPanelConstraint.priority = 900.f;
        self.infoRightToIndicatorConstraint.priority = 950.f;
    }else{
        self.availabilityLabel.hidden = YES;
        self.selectionIndicator.hidden = YES;
        self.infoRightToPanelConstraint.priority = 950.f;
        self.infoRightToIndicatorConstraint.priority = 900.f;
    }
    [self.contentView layoutIfNeeded];
}

- (NSString *)defaultDescText
{
    NSString *text;
    CouponModel *coupon = self.coupon;
    if (self.selectionMode) {
        text = [NSString stringWithFormat:@"有效期至 %@\n%@",coupon.expireTime,coupon.couponDescription?:@""];
    }else{
        switch (coupon.couponStatus) {
            case CouponStatusEnabled:{
                text = [NSString stringWithFormat:@"有效期至 %@\n%@",coupon.expireTime,coupon.couponDescription?:@""];
            }   break;
            case CouponStatusUsed:{
                text = [NSString stringWithFormat:@"%@ 已使用\n%@",coupon.tranTime,coupon.couponDescription?:@""];
            }   break;
            case CouponStatusExpired:{
                text = [NSString stringWithFormat:@"%@ 已过期\n%@",coupon.expireTime,coupon.couponDescription?:@""];
            }   break;
            case CouponStatusPresented:{
                text = [NSString stringWithFormat:@"%@ 已赠送\n%@",coupon.expireTime,coupon.couponDescription?:@""];
            }   break;
        }
    }
    return text;
}

- (BOOL)enabled
{
    return self.coupon.couponStatus==CouponStatusEnabled;
}

- (BOOL)usable
{
    return self.coupon.usable;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.selectionIndicator.highlighted = selected;
}

@end


NSString *const kYGCouponInputCell = @"YGCouponInputCell";
@interface YGCouponInputCell ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@end
@implementation YGCouponInputCell

- (IBAction)submit:(UIButton *)btn
{
    [self.textField endEditing:YES];
    
    RunAfter(.1f, ^{
        NSString *text = [self.textField.text stringByTrimmingCharactersInSet:[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]];
        if (text.length == 0) {
            [SVProgressHUD showInfoWithStatus:@"请输入现金券编号"];
            [self.textField becomeFirstResponder];
        }else {
            [SVProgressHUD show];
            [SearchService addCouponWithSessionId:[[LoginManager sharedManager] getSessionId] couponCode:text success:^(CouponModel *coupon) {
                if (coupon) {
                    self.textField.text = nil;
                    [SVProgressHUD showInfoWithStatus:@"添加成功"];
                    if (self.didAddCoupon) {
                        self.didAddCoupon(coupon);
                    }
                }else{
                    [SVProgressHUD showErrorWithStatus:@"添加失败"];
                }
            } failure:^(HttpErroCodeModel *error) {
                [SVProgressHUD dismiss];
            }];
        }
    });
}

@end

NSString *const kYGCouponNonuseCell = @"YGCouponNonuseCell";
@interface YGCouponNonuseCell ()
@property (weak, nonatomic) IBOutlet UIImageView *selectionIndicator;
@end
@implementation YGCouponNonuseCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.selectionIndicator.highlighted = selected;
}

@end
