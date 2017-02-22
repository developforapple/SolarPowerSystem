//
//  YGMallOrderCell.h
//  Golf
//
//  Created by bo wang on 2016/10/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IQKeyboardManager/IQTextView.h>
#import "YGMallOrderCDKeyPanel.h"

@class YGMallOrderModel;
@class YYLabel;

/**
 商城确认订单、订单详情、申请退款中的各种cell类型
 */
@interface YGMallOrderCell : UITableViewCell

+ (CGFloat)preferredHeight;
+ (Class)classForIdentifier:(NSString *)identifier;

@property (strong, readonly, nonatomic) UITableView *tableView;

@property (strong, readonly, nonatomic) YGMallOrderModel *order;
@property (strong, readonly, nonatomic) NSIndexPath *indexPath;
- (void)configureWithOrder:(YGMallOrderModel *)order atIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;

// 内容发生了更新的回调
@property (copy, nonatomic) void (^willUpdateCallback)(void);

@end

#pragma mark - Subclass

// 物流
UIKIT_EXTERN NSString *const kYGMallOrderCell_Logistics;
@interface YGMallOrderCell_Logistics : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *logisticsLabel;
@end

// 退款
UIKIT_EXTERN NSString *const kYGMallOrderCell_Refund;
@interface YGMallOrderCell_Refund : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UIImageView *choiceReasonIndicator;
@property (weak, nonatomic) IBOutlet UIView *refundReasonBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refundReasonBackViewRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *refundReason;

@end

// 收货地址
UIKIT_EXTERN NSString *const kYGMallOrderCell_Address;
@interface YGMallOrderCell_Address : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UIView *phonenumberPanel;
@property (weak, nonatomic) IBOutlet UITextField *phonenumberTextField;

@property (weak, nonatomic) IBOutlet UIView *addressPanel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressPanelRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *personNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phonenumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIView *noneAddressPanel;
@property (weak, nonatomic) IBOutlet UIImageView *decorationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *addIndicator;
@end

// 订单编号
UIKIT_EXTERN NSString *const kYGMallOrderCell_OrderNumber;
@interface YGMallOrderCell_OrderNumber : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@end

// 商品组
UIKIT_EXTERN NSString *const kYGMallOrderCell_Group;
@interface YGMallOrderCell_Group : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UILabel *groupTitleLabel;
@end

// 商品
UIKIT_EXTERN NSString *const kYGMallOrderCell_Commodity;
@interface YGMallOrderCell_Commodity : YGMallOrderCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (weak, nonatomic) IBOutlet YGMallOrderCDKeyPanel *evidencePanel;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;
@property (weak, nonatomic) IBOutlet YYLabel *commodityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *commoditySpecLabel;
@property (weak, nonatomic) IBOutlet UILabel *commodityPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commodityQuantityLabel;
@end

// 配送
UIKIT_EXTERN NSString *const kYGMallOrderCell_Delivery;
@interface YGMallOrderCell_Delivery : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
@end

// 留言
UIKIT_EXTERN NSString *const kYGMallOrderCell_Message;
@interface YGMallOrderCell_Message : YGMallOrderCell
@property (weak, nonatomic) IBOutlet IQTextView *messageTextView;
@end

// 优惠券
UIKIT_EXTERN NSString *const kYGMallOrderCell_Coupon;
@interface YGMallOrderCell_Coupon : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@end

// 合计
UIKIT_EXTERN NSString *const kYGMallOrderCell_Amount;
@interface YGMallOrderCell_Amount : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UILabel *commodityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *commodityAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *freightTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *freightAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@end

// 返云币
UIKIT_EXTERN NSString *const kYGMallOrderCell_Yunbi;
@interface YGMallOrderCell_Yunbi : YGMallOrderCell
@property (weak, nonatomic) IBOutlet UILabel *yunbiLabel1;
@property (weak, nonatomic) IBOutlet UILabel *yunbiLabel2;
@end
