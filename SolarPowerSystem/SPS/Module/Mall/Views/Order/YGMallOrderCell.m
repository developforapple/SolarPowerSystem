//
//  YGMallOrderCell.m
//  Golf
//
//  Created by bo wang on 2016/10/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderCell.h"
#import "YGMallOrderModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CouponModel.h"
#import "YYText.h"

@implementation YGMallOrderCell

+ (CGFloat)preferredHeight
{
    NSLog(@"子类实现这个方法！！！！！");
    return 44.f;
}

+ (Class)classForIdentifier:(NSString *)identifier
{
    Class c = NSClassFromString(identifier);
    if (c && [c isSubclassOfClass:[self class]]) {
        return c;
    }
    return nil;
}

- (UITableView *)tableView
{
    UIView *view = self;
    while ((view = view.superview)) {
        if ([view isKindOfClass:[UITableView class]]) {
            return (UITableView *)view;
        }
    }
    return nil;
}

- (void)configureWithOrder:(YGMallOrderModel *)order atIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    _order = order;
    [self setup];
}

- (void)setup
{
    NSLog(@"子类实现这个方法！！！！！");
}

@end

#pragma mark - 物流信息
NSString *const kYGMallOrderCell_Logistics = @"YGMallOrderCell_Logistics";
@implementation YGMallOrderCell_Logistics
+ (CGFloat)preferredHeight
{
    return 44.f;
}

- (void)setup
{
    self.logisticsLabel.text = [NSString stringWithFormat:@"%@ %@",self.order.delivery_company_name,self.order.delivery_number];
}

- (IBAction)copyLogistics:(id)sender
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    pb.string = self.order.delivery_number;
    [SVProgressHUD showSuccessWithStatus:@"已复制到剪切板"];
}
@end

#import <IQKeyboardManager/IQKeyboardManager.h>
#import "YGMallOrderRefundReasonViewCtrl.h"

#pragma mark - 退款原因
NSString *const  kYGMallOrderCell_Refund = @"YGMallOrderCell_Refund";
@interface YGMallOrderCell_Refund ()
@end

@implementation YGMallOrderCell_Refund

+ (CGFloat)preferredHeight
{
    return 48.f;
}

- (void)setup
{
    if (self.order.tempStatus != YGMallOrderStatusCreatingRefund ||
        [self.order isCreatingCancelRefund]) {
        self.choiceReasonIndicator.hidden = YES;
        
        self.refundReasonBackViewRightConstraint.constant = 13.f;
        self.refundReason.text = self.order.return_memo;
        self.refundReason.highlighted = YES;
    }else{
        self.choiceReasonIndicator.hidden = NO;
        
        BOOL hasReason = self.order.return_memo.length != 0;
        self.refundReasonBackViewRightConstraint.constant = hasReason?26.f:16.f;
        self.refundReason.text = hasReason?self.order.return_memo:@"请选择退款原因";
        self.refundReason.highlighted = hasReason;
        self.refundReasonBackView.hidden = !hasReason;
    }
    [self.contentView layoutIfNeeded];
}

@end

#pragma mark - 收货地址
#import "YGMallAddressListViewCtrl.h"
#import "YGMallAddressEditViewCtrl.h"
#import "YGMallAddressModel.h"

NSString *const kYGMallOrderCell_Address = @"YGMallOrderCell_Address";
@interface YGMallOrderCell_Address ()<ServiceManagerDelegate,UITextFieldDelegate>
@property (strong, nonatomic) YGMallAddressModel *curAddressModel;
@end
@implementation YGMallOrderCell_Address
{
    BOOL _isAddressLoaded;
}

+ (CGFloat)preferredHeight
{
    return 80.f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _isAddressLoaded = NO;
    
    self.decorationImageView.image = [[UIImage imageNamed:@"bg_mall_order_decorationLine"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
}

- (void)setup
{
    self.selectionStyle = self.order.tempStatus==YGMallOrderStatusCreating?UITableViewCellSelectionStyleDefault:UITableViewCellSelectionStyleNone;
    
    if ([self.order isVirtualOrder]) {
        self.noneAddressPanel.hidden = YES;
        self.addressPanel.hidden = YES;
        self.phonenumberPanel.hidden = NO;
        self.decorationImageView.hidden = YES;
        self.addIndicator.hidden = YES;
        self.phonenumberTextField.text = self.order.link_phone;
        return;
    }
    
    if (self.order.link_man.length > 0 && self.order.link_phone.length > 0) {
        self.phonenumberPanel.hidden = YES;
        self.addressPanel.hidden = NO;
        self.noneAddressPanel.hidden = YES;
        self.personNameLabel.text = [NSString stringWithFormat:@"收货人：%@",self.order.link_man];
        self.phonenumberLabel.text = self.order.link_phone;
        self.addressLabel.text = self.order.address;
    }else{
        self.phonenumberPanel.hidden = YES;
        self.addressPanel.hidden = YES;
        self.noneAddressPanel.hidden = NO;
        
        if (!_isAddressLoaded && self.order.tempStatus == YGMallOrderStatusCreating) {
            _isAddressLoaded = YES;
            [YGMallAddressModel fetchDefaultAddress:^(YGMallAddressModel *address) {
                [self setupAddressModel:address];
            }];
        }
    }
    BOOL indicatorVisible = self.order.tempStatus==YGMallOrderStatusCreating;
    self.addIndicator.hidden = self.decorationImageView.hidden = !indicatorVisible;
    self.addressPanelRightConstraint.constant = indicatorVisible?20.f:0.f;
    [self.contentView layoutIfNeeded];
}

- (void)setupAddressModel:(YGMallAddressModel *)addressModel
{
    if (addressModel) {
        _curAddressModel = addressModel;
        RunOnMainQueue(^{
            self.order.link_man = addressModel.link_man;
            self.order.link_phone = addressModel.link_phone;
            self.order.address = [NSString stringWithFormat:@"%@%@%@%@ %@",addressModel.province_name,addressModel.city_name,addressModel.district_name,addressModel.address,addressModel.post_code?:@""];
            [self setup];
        });
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected && self.order.tempStatus == YGMallOrderStatusCreating && ![self.order isVirtualOrder]) {
        ygweakify(self);
        
        if (self.noneAddressPanel.hidden) {
            YGMallAddressListViewCtrl *vc = [YGMallAddressListViewCtrl instanceFromStoryboard];
            vc.addreddId = self.curAddressModel.address_id;
            [vc setDidSelectedAddress:^(YGMallAddressModel *address) {
                ygstrongify(self);
                [self setupAddressModel:address];
            }];
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else{
            YGMallAddressEditViewCtrl *vc = [YGMallAddressEditViewCtrl instanceFromStoryboard];
            [vc setDidEditAddress:^(YGMallAddressModel *address, YGMallAddressEditType type) {
                ygstrongify(self);
                [self setupAddressModel:address];
            }];
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.order.link_phone = textField.text;
}

@end

#pragma mark - 订单编号
NSString *const kYGMallOrderCell_OrderNumber = @"YGMallOrderCell_OrderNumber";
@implementation YGMallOrderCell_OrderNumber
+ (CGFloat)preferredHeight
{
    return 44.f;
}

- (void)setup
{
    YGMallOrderModel *subOrder = self.order.order[self.indexPath.section-1];
    self.orderNumberLabel.text = [NSString stringWithFormat:@"订单号：%ld",(long)subOrder.order_id];
    
    NSString *statusText;
    switch (subOrder.order_state) {
        case YGMallOrderStatusUnpaid:break;
        case YGMallOrderStatusPaid:statusText = @"等待发货";break;
        case YGMallOrderStatusShipped:statusText = @"已发货";break;
        case YGMallOrderStatusReceived:statusText = @"已确认收货";break;
        case YGMallOrderStatusReviewed:statusText = @"已评价";break;
        case YGMallOrderStatusClosed:break;
        case YGMallOrderStatusApplyRefund:statusText = @"退款申请中";break;
        case YGMallOrderStatusRefunded:statusText = @"已退款";break;
        case YGMallOrderStatusCreating:break;
        case YGMallOrderStatusCreatingRefund:break;
    }
    self.orderStatusLabel.text = statusText;
}
@end

#pragma mark - 商品组
NSString *const kYGMallOrderCell_Group = @"YGMallOrderCell_Group";
@implementation YGMallOrderCell_Group
+ (CGFloat)preferredHeight
{
    return 36.f;
}

- (void)setup
{
    NSInteger section = self.indexPath.section;
    YGMallOrderModel *subOrder = self.order.order[section-1];
    self.groupTitleLabel.text = subOrder.agentName;
}
@end

#pragma mark - 商品
#import "YG_MallCommodityViewCtrl.h"
#import "YYLabel.h"

NSString *const kYGMallOrderCell_Commodity = @"YGMallOrderCell_Commodity";
@implementation YGMallOrderCell_Commodity
+ (CGFloat)preferredHeight
{
    return 76.f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.commodityTitleLabel.numberOfLines = 0;
    self.commodityTitleLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    self.commodityTitleLabel.textAlignment = NSTextAlignmentJustified;
    
    self.container.userInteractionEnabled = YES;
    [self.container addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCommodityDetail:)]];
}

- (YGMallOrderCommodity *)commodity
{
    NSInteger section = self.indexPath.section;
    YGMallOrderModel *subOrder = self.order.order[section-1];
    NSInteger row = self.indexPath.row;
    BOOL flag = self.order.tempStatus==YGMallOrderStatusCreatingRefund?1:0;
    YGMallOrderCommodity *commodity = subOrder.commodity[row-1-flag];
    return commodity;
}

- (void)setup
{
    self.container.userInteractionEnabled = self.order.tempStatus != YGMallOrderStatusCreating && self.order.tempStatus != YGMallOrderStatusCreatingRefund;
    
    YGMallOrderCommodity *commodity = [self commodity];
    [self.commodityImageView sd_setImageWithURL:[NSURL URLWithString:commodity.photo_image]];
    self.commoditySpecLabel.text = commodity.spec_name;
    self.commodityQuantityLabel.text = [NSString stringWithFormat:@"× %ld",(long)commodity.quantity];
    self.commodityPriceLabel.text = [NSString stringWithFormat:@"￥%ld",(long)commodity.price/100];

    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:commodity.commodity_name];
    name.yy_font = [UIFont systemFontOfSize:12];
    name.yy_color = RGBColor(51, 51, 51, 1);
    if (commodity.commodity_type == 2) {
        //虚拟卷
        NSMutableAttributedString *string = [NSMutableAttributedString yy_attachmentStringWithContent:[UIImage imageNamed:@"icon_mall_cart_exchange"] contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(18, 14) alignToFont:[UIFont systemFontOfSize:12] alignment:YYTextVerticalAlignmentTop];
        [name insertAttributedString:string atIndex:0];
        
        if (commodity.evidence_list.count != 0) {
            self.evidencePanel.hidden = NO;
            [self.evidencePanel setupWithCommodity:commodity inOrder:self.order];
            CGFloat h = [commodity evidenceHeight:kEvidenceUnitHeight spacing:kEvidenceSpacing];
            self.contentHeightConstraint.constant = 70.f + h;
        }else{
            self.evidencePanel.hidden = YES;
            self.contentHeightConstraint.constant = 70.f;
        }
    }else{
        self.contentHeightConstraint.constant = 70.f;
        self.evidencePanel.hidden = YES;
    }
    name.yy_lineSpacing = 4;
    self.commodityTitleLabel.attributedText = name;
}

- (void)showCommodityDetail:(UITapGestureRecognizer *)gr
{
    YGMallOrderCommodity *commodity = [self commodity];
    YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//    vc.commodityId = commodity.commodity_id;
    vc.cid = commodity.commodity_id;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

@end

#pragma mark - 配送方式
NSString *const kYGMallOrderCell_Delivery = @"YGMallOrderCell_Delivery";
@implementation YGMallOrderCell_Delivery
+ (CGFloat)preferredHeight
{
    return 48.f;
}

- (void)setup
{
    NSInteger section = self.indexPath.section;
    YGMallOrderModel *subOrder = self.order.order[section-1];
    if (subOrder.freight == 0) {
        self.deliveryLabel.text = @"免运费";
    }else{
        self.deliveryLabel.text = [NSString stringWithFormat:@"统一运费￥%ld",(long)subOrder.freight/100];
    }
}
@end

#pragma mark - 留言
#import "YGMallOrderMemoEditViewCtrl.h"

NSString *const kYGMallOrderCell_Message = @"YGMallOrderCell_Message";

@interface YGMallOrderCell_Message ()<UITextViewDelegate>
@end

@implementation YGMallOrderCell_Message
+ (CGFloat)preferredHeight
{
    return 64.f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageTextView.textColor = RGBColor(51, 51, 51, 1);
    self.messageTextView.font = [UIFont systemFontOfSize:14];
    self.messageTextView.contentInset = UIEdgeInsetsZero;
    self.messageTextView.textAlignment = NSTextAlignmentJustified;
    self.messageTextView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.messageTextView.editable = NO;
}

- (void)setup
{
    NSInteger section = self.indexPath.section;
    YGMallOrderModel *subOrder = self.order.order[section-1];
    self.messageTextView.text = subOrder.user_memo;
    if ([self.order canEditUserMemo]) {
        self.messageTextView.placeholder = @"点击此处给商家留言（50字以内）";
    }else{
        self.messageTextView.placeholder = @"没有留言";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected && [self.order canEditUserMemo]) {
        NSInteger section = self.indexPath.section;
        YGMallOrderModel *subOrder = self.order.order[section-1];
        
        ygweakify(self);
        YGMallOrderMemoEditViewCtrl *vc = [YGMallOrderMemoEditViewCtrl instanceFromStoryboard];
        vc.order = subOrder;
        [vc setMemoDidChanged:^(YGMallOrderModel *theOrder) {
            ygstrongify(self);
            [self setup];
        }];
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

@end

#pragma mark - 优惠券

NSString *const kYGMallOrderCell_Coupon = @"YGMallOrderCell_Coupon";
@implementation YGMallOrderCell_Coupon

+ (CGFloat)preferredHeight
{
    return 48.f;
}

- (void)setup
{
    if (self.order.coupon) {
        self.couponLabel.text = [self.order.coupon couponAmountInfo];
        self.couponLabel.textColor = RGBColor(51, 51, 51, 1);
    }else if(self.order.noValidCoupon){
        self.couponLabel.text = @"无优惠券可用";
        self.couponLabel.textColor = RGBColor(153, 153, 153, 1);
    }else{
        self.couponLabel.text = @"不使用优惠券";
        self.couponLabel.textColor = RGBColor(153, 153, 153, 1);
    }
}

@end

#pragma mark - 合计

NSString *const kYGMallOrderCell_Amount = @"YGMallOrderCell_Amount";
@implementation YGMallOrderCell_Amount
+ (CGFloat)preferredHeight
{
    return 138.f;
}

- (void)configureWithOrder:(YGMallOrderModel *)order atIndexPath:(NSIndexPath *)indexPath
{
    [super configureWithOrder:order atIndexPath:indexPath];
    
    ygweakify(self);
    [RACObserve(self.order, coupon)
     subscribeNext:^(id x) {
         ygstrongify(self);
         [self setup];
     }];
}

- (void)setup
{
    NSInteger commodityPrice = self.order.order_total - self.order.freight;
    NSInteger freight = self.order.freight;
    NSInteger coupon = [self.order couponAmount];
    NSInteger pay = [self.order needToPayAmount];
    
    self.commodityAmountLabel.text = [NSString stringWithFormat:@"￥%ld",commodityPrice/100];
    self.freightAmountLabel.text = [NSString stringWithFormat:@"+ ￥%ld",freight/100];
    
    if (coupon != 0) {
        self.couponTitleLabel.hidden = NO;
        self.couponAmountLabel.hidden = NO;
        self.couponAmountLabel.text = [NSString stringWithFormat:@"- ￥%ld",coupon/100];
    }else{
        self.couponTitleLabel.hidden = YES;
        self.couponAmountLabel.hidden = YES;
    }
    self.amountLabel.text = [self.order paymentTitle];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%ld",pay/100];
}
@end


#pragma mark - 云币

NSString *const kYGMallOrderCell_Yunbi = @"YGMallOrderCell_Yunbi";

@implementation YGMallOrderCell_Yunbi

+ (CGFloat)preferredHeight
{
    return 48.f;
}

- (void)setup
{
    NSInteger yunbi = self.order.give_yunbi;
    self.yunbiLabel1.text = [NSString stringWithFormat:@"返%ld",(long)yunbi/100];
    self.yunbiLabel2.text = [NSString stringWithFormat:@"返云币 %ld 个",(long)yunbi/100];
}

@end
