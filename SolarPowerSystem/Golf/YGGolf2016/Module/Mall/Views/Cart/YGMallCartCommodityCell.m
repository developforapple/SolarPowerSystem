//
//  YGMallCartCommodityCell.m
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCartCommodityCell.h"
#import "YGMallCart.h"
#import "YG_MallCommodityViewCtrl.h"

@interface _YGMallCartCommodityCellExtraInfoView : UIView
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@end
@implementation _YGMallCartCommodityCellExtraInfoView@end

@interface YGMallCartCommodityCell () <YGMallQuantityControlDelegate>
@property (strong, readwrite, nonatomic) id commodity;
@property (weak, nonatomic) IBOutlet _YGMallCartCommodityCellExtraInfoView *extraInfoView1;
@property (weak, nonatomic) IBOutlet _YGMallCartCommodityCellExtraInfoView *extraInfoView2;
@end

@implementation YGMallCartCommodityCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.commodityNameLabel.numberOfLines = 0;
    self.commodityNameLabel.textAlignment = NSTextAlignmentJustified;
    
    ygweakify(self);
    [self.commodityImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
        ygstrongify(self);
        [self showCommodityDetail];
    }]];
    [self.commodityNameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
        [self showCommodityDetail];
    }]];
}

- (void)configureWithCommodity:(CommodityModel *)commodity inCart:(YGMallCart *)cart
{
    self.commodity = commodity;
    self.selectionBtn.selected = [cart isCommoditySelected:commodity];
    
    [self.commodityImageView sd_setImageWithURL:[NSURL URLWithString:commodity.photoImage]];
    self.commoditySpecLabel.text = commodity.specName;
    self.commodityPriceLabel.text = [NSString stringWithFormat:@"%d",commodity.sellingPrice];
    
    switch (self.commodity.sellingStatus) {
        case 2:{
            self.commodityStateLabel.text = @"已下架";
            self.commodityStateLabel.hidden = NO;
            self.quantitySelectionView.hidden = YES;
        }   break;
        case 3:{
            self.commodityStateLabel.text = @"已售罄";
            self.commodityStateLabel.hidden = NO;
            self.quantitySelectionView.hidden = YES;
        }   break;
        case 1:
        default:{
            self.commodityStateLabel.text = @"";
            self.commodityStateLabel.hidden = YES;
            self.quantitySelectionView.hidden = cart.isEditing;
            if (!cart.isEditing) {
                self.quantitySelectionView.value = commodity.quantity;
            }
        }   break;
    }
    
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:commodity.commodityName];
    name.yy_font = [UIFont systemFontOfSize:14];
    name.yy_color = RGBColor(74, 74, 74, 1);
    name.yy_lineSpacing = 2;
    self.commodityNameLabel.attributedText = name;
    
    BOOL hasYunbi = commodity.giveYunbi>0;
    BOOL isVistual = commodity.commodityType==2;
    
    self.extraInfoPanel.hidden = !hasYunbi && !isVistual;
    self.extraInfoView1.hidden = YES;
    self.extraInfoView2.hidden = YES;
    
    _YGMallCartCommodityCellExtraInfoView *yunbiView = hasYunbi?self.extraInfoView1:nil;
    _YGMallCartCommodityCellExtraInfoView *virtualView = isVistual?(hasYunbi?self.extraInfoView2:self.extraInfoView1):nil;
    if (yunbiView) {
        [yunbiView.infoBtn setTitle:[NSString stringWithFormat:@"返%d",commodity.giveYunbi] forState:UIControlStateNormal];
        yunbiView.infoLabel.text = [NSString stringWithFormat:@"返云币%d，1云币价值1元",commodity.giveYunbi];
        yunbiView.hidden = NO;
    }
    if (virtualView) {
        [virtualView.infoBtn setTitle:@"兑" forState:UIControlStateNormal];
        virtualView.infoLabel.text = @"凭兑换码使用该商品";
        virtualView.hidden = NO;
    }
    
//    if (commodity.commodityType == 2) {
//        //虚拟卷
//        NSMutableAttributedString *string = [NSMutableAttributedString yy_attachmentStringWithContent:[UIImage imageNamed:@"icon_mall_cart_exchange"] contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(18, 14) alignToFont:[UIFont systemFontOfSize:12] alignment:YYTextVerticalAlignmentTop];
//        [name insertAttributedString:string atIndex:0];
//    }
//    name.yy_lineSpacing = 2;
//    self.commodityNameLabel.attributedText = name;
}

- (void)submitQuantityChanged:(NSInteger)newValue completion:(void (^)(BOOL suc,NSInteger v))completion
{
    NSInteger oldValue = self.commodity.quantity;
    NSInteger diff = oldValue - newValue;
    NSInteger operation = diff<0?1:2;
    
    NSString *ids = [NSString stringWithFormat:@"%ld",(long)self.commodity.commodityId];
    NSString *quantity = [NSString stringWithFormat:@"%d",abs(diff)];
    NSString *sku = [NSString stringWithFormat:@"%d",self.commodity.skuid];
    
    [SVProgressHUD show];
    [ServerService shoppingCartMaintain:[[LoginManager sharedManager] getSessionId] operation:operation commodityIds:ids specIds:sku quantitys:quantity success:^(NSArray *list) {
        [SVProgressHUD dismissWithDelay:.2f];
        self.commodity.quantity = self.quantitySelectionView.value = newValue;
        if (completion) {
            completion(YES,newValue);
        }
    } failure:^(id error) {
        [SVProgressHUD dismissWithDelay:.2f];
        self.commodity.quantity = self.quantitySelectionView.value = oldValue;
        if (completion) {
            completion(NO,oldValue);
        }
    }];
}

- (void)showCommodityDetail
{
    YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//    vc.commodityId = self.commodity.commodityId;
    vc.cid = self.commodity.commodityId;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

#pragma mark - Quantity Delegateaq
- (BOOL)quantityControl:(YGMallQuantityControl *)control shouldChangeValue:(NSInteger)toValue from:(NSInteger)fromValue
{
    if (toValue == 0) {
        if (self.willDeleteCallback) {
            self.willDeleteCallback(self.commodity);
        }
        return NO;
    }
    
    NSInteger remain = self.commodity.stockQuantity-self.commodity.soldQuantity;
    if (toValue > remain && toValue > fromValue) {
        [SVProgressHUD showErrorWithStatus:@"库存不足"];
        return NO;
    }
    
    if (toValue > remain && toValue < fromValue) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"库存剩余%ld件",(long)remain]];
        control.value = remain;
        [self submitQuantityChanged:remain completion:nil];
        return NO;
    }
    if (self.commodity.buyLimit != 0 && toValue > self.commodity.buyLimit) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"限购%d件",self.commodity.buyLimit]];
        return NO;
    }
    return YES;
}

- (void)quantityControl:(YGMallQuantityControl *)control didChangedValue:(NSInteger)value
{
    ygweakify(self);
    [self submitQuantityChanged:value completion:^(BOOL suc, NSInteger v) {
        ygstrongify(self);
        if (self.didChangedQuantityCallback) {
            self.didChangedQuantityCallback(self.commodity);
        }
    }];
}

@end


NSString *const kYGMallCartCommodityCell = @"YGMallCartCommodityCell";
